/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>

#include <QVector>
#include <QContactAddress>
#include <QContactAnniversary>
#include <QContactAvatar>
#include <QContactThumbnail>
#include <QContactBirthday>
#include <QContactEmailAddress>
#include <QContactGuid>
#include <QContactName>
#include <QContactNote>
#include <QContactOrganization>
#include <QContactOnlineAccount>
#include <QContactUnionFilter>
#include <QContactFavorite>
#include <QContactPhoneNumber>
#include <QContactUrl>
#include <QContactNote>
#include <QContactPresence>
#include <QSettings>
#include <QContactDetailFilter>
#include <QVersitContactExporter>
#include <QVersitReader>
#include <QContactLocalIdFilter>
#include <QContactManagerEngine>
#include <QFile>

#include "peoplemodel.h"

class PeopleModelPriv
{
public:

    QContactManager *manager;
    QContactFilter currentFilter;
    QList<QContactLocalId> contactIds;
    QMap<QContactLocalId, int> idToIndex;
    QMap<QContactLocalId, QContact *> idToContact;
    QMap<QUuid, QContactLocalId> uuidToId;
    QMap<QContactLocalId, QUuid> idToUuid;

    QVersitWriter m_writer;

    QVector<QStringList> data;
    QSettings *settings;
    QContactGuid currentGuid;
};

PeopleModel::PeopleModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles.insert(AvatarRole, "avatarurl");
    roles.insert(FirstNameRole, "firstname");
    roles.insert(FirstCharacterRole, "firstcharacter");
    roles.insert(LastNameRole, "lastname");
    setRoleNames(roles);

    priv = new PeopleModelPriv;

    QContactSortOrder sort;
    sort.setDetailDefinitionName(QContactName::DefinitionName, QContactName::FieldFirstName);
    sort.setDirection(Qt::AscendingOrder);
    sortOrder.clear();
    sortOrder.append(sort);

    if (QContactManager::availableManagers().contains("tracker")) {
        priv->manager = new QContactManager("tracker");
        qDebug() << "[PeopleModel] Manager is tracker";
    }
    else if (QContactManager::availableManagers().contains("memory")) {
        priv->manager = new QContactManager("memory");
        qDebug() << "[PeopleModel] Manager is memory";
    }else{
        priv->manager = new QContactManager("default");
        qDebug() << "[PeopleModel] Manager is empty";
    }

    priv->settings = new QSettings("MeeGo", "meego-app-contacts");

    //Set up async requests
    fetchAddedContacts.setManager(priv->manager);
    connect(&fetchAddedContacts, SIGNAL(resultsAvailable()), this,
            SLOT(fetchContactsRequest()));

    fetchAllContacts.setManager(priv->manager);
    connect(&fetchAllContacts, SIGNAL(resultsAvailable()), this,
            SLOT(fetchContactsRequest()));

    fetchChangedContacts.setManager(priv->manager);
    connect(&fetchChangedContacts, SIGNAL(resultsAvailable()), this,
            SLOT(fetchContactsRequest()));

    fetchMeCard.setManager(priv->manager);
    connect(&fetchMeCard, SIGNAL(resultsAvailable()), this,
            SLOT(fetchContactsRequest()));

    addMeCard.setManager(priv->manager);
    connect(&addMeCard, SIGNAL(resultsAvailable()), this,
            SLOT(saveContactsRequest()));

    updateMeCard.setManager(priv->manager);
    connect(&updateMeCard, SIGNAL(resultsAvailable()), this,
            SLOT(saveContactsRequest()));

    updateContact.setManager(priv->manager);
    connect(&updateContact, SIGNAL(resultsAvailable()), this,
            SLOT(saveContactsRequest()));

    updateAvatar.setManager(priv->manager);
    connect(&updateAvatar, SIGNAL(resultsAvailable()), this,
            SLOT(saveContactsRequest()));

    updateFavorite.setManager(priv->manager);
    connect(&updateFavorite, SIGNAL(resultsAvailable()), this,
            SLOT(saveContactsRequest()));

    removeContact.setManager(priv->manager);
    connect(&removeContact, SIGNAL(resultsAvailable()), this,
            SLOT(removeContactsRequest()));

   // m_tpManager = new TelepathyManager(true);
   /*  connect(m_tpManager,
             SIGNAL(accountManagerReady()),
             SLOT(onAccountManagerReady()));*/

    //is meCard supported by manager/engine
    /*  if(priv->manager->hasFeature(QContactManager::SelfContact, QContactType::TypeContact))
    {
      QContactManager::Error error(QContactManager::NoError);
      const QContactLocalId meCardId(priv->manager->selfContactId());

      //if we have a valid selfId
      if((error == QContactManager::NoError) && (meCardId != 0)){
        qDebug() << "[PeopleModel] valid selfId, error" << error << "id " << meCardId;
        //check if contact with selfId exists
        QContactLocalIdFilter idListFilter;
        idListFilter.setIds(QList<QContactLocalId>() << meCardId);

        fetchMeCard.setFilter(idListFilter);
        if(!sortOrder.isEmpty())
        fetchMeCard.setSorting(sortOrder);
        fetchMeCard.start();
      }else{
        qWarning() << "[PeopleModel] no valid meCard Id provided";
      }
    }else{
      qWarning() << "PeopleModel::PeopleModel() MeCard Not supported";
    }*/

    connect(priv->manager, SIGNAL(contactsAdded(QList<QContactLocalId>)),
            this, SLOT(contactsAdded(QList<QContactLocalId>)));
    connect(priv->manager, SIGNAL(contactsChanged(QList<QContactLocalId>)),
            this, SLOT(contactsChanged(QList<QContactLocalId>)));
    connect(priv->manager, SIGNAL(contactsRemoved(QList<QContactLocalId>)),
            this, SLOT(contactsRemoved(QList<QContactLocalId>)));
    connect(priv->manager, SIGNAL(dataChanged()), this, SLOT(dataReset()));
    connect(&priv->m_writer, SIGNAL(stateChanged(QVersitWriter::State)),
            this, SLOT(vCardFinished(QVersitWriter::State)));

    dataReset();
}

void PeopleModel::createMeCard(QContact &card)
{
    QContact *contact = new QContact(card);

    QContactGuid guid;
    guid.setGuid(QUuid::createUuid().toString());
    if (!contact->saveDetail(&guid))
        qWarning() << "[PeopleModel] failed to save guid in mecard contact";

    QContactAvatar avatar;
    avatar.setImageUrl(QUrl("icon-m-content-avatar-placeholder"));
    if (!contact->saveDetail(&avatar))
        qWarning() << "[PeopleModel] failed to save avatar in mecard contact";

    QContactName name;
    name.setFirstName(QObject::tr("Me","Default string to describe self if no self contact information found, default created with [Me] as firstname"));
    name.setLastName("");
    if (!contact->saveDetail(&name))
        qWarning() << "[PeopleModel] failed to save mecard name";

    QContactFavorite fav;
	fav.setFavorite(false);
    if (!contact->saveDetail(&fav))
        qWarning() << "[PeopleModel] failed to save mecard favorite to " << fav;

    updateMeCard.setContact(*contact);
    updateMeCard.start();
}

PeopleModel::~PeopleModel()
{
    foreach (QContact *contact, priv->idToContact.values())
        delete contact;
    delete priv->manager;
    delete priv;
}

int PeopleModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return priv->contactIds.size();
}

int PeopleModel::columnCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);
    return 1;
}

QVariant PeopleModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid())
        return QVariant();
    return data(index.row(), role);
}
QVariant PeopleModel::data(int row, int role) const
{
    QContactLocalId id = priv->contactIds[row];
    QContact *contact = priv->idToContact[id];

    if (!contact)
        return QVariant();

    switch (role) {
    case FirstNameRole:
    {
        QContactName name = contact->detail<QContactName>();
        if(!name.firstName().isNull()){
            return QString(name.firstName());
        }
        return QString();
    }
    case LastNameRole:
    {
        QContactName name = contact->detail<QContactName>();
        if(!name.lastName().isNull())
            return QString(name.lastName());
        return QString();
    }
    case CompanyNameRole:
    {
        QContactOrganization company = contact->detail<QContactOrganization>();
        if(!company.name().isNull())
            return QString(company.name());
        return QString();
    }
    case BirthdayRole:
    {
        QContactBirthday day = contact->detail<QContactBirthday>();
        if(!day.date().isNull())
            return day.date().toString(Qt::SystemLocaleDate);
        return QString();
    }
    case AvatarRole:
    {
        QContactAvatar avatar = contact->detail<QContactAvatar>();
        if(!avatar.imageUrl().isEmpty()) {
            return QUrl(avatar.imageUrl()).toString();
        }
        return QString();
    }
    case ThumbnailRole:
    {
        QContactThumbnail thumb = contact->detail<QContactThumbnail>();
        return thumb.thumbnail();
    }
    case FavoriteRole:
    {
        QContactFavorite fav = contact->detail<QContactFavorite>();
         if(!fav.isEmpty())
            return QVariant(fav.isFavorite());
        return false;
    }
    case OnlineAccountUriRole:
    {
        QStringList list;
        foreach (const QContactOnlineAccount& account,
                 contact->details<QContactOnlineAccount>()){
            if(!account.accountUri().isNull())
                list << account.accountUri();
        }
        return list;
    }
    case OnlineServiceProviderRole:
    {
        //REVISIT: We should use ServiceProvider, but this isn't supported
        //BUG: https://bugs.meego.com/show_bug.cgi?id=13454
        QStringList list;
        foreach (const QContactOnlineAccount& account,
                 contact->details<QContactOnlineAccount>()){
            if(account.subTypes().size() > 0)
                list << account.subTypes().at(0);
        }
        return list;
    }
    case IsSelfRole:
    {
        if(!contact->id().localId()){
            if(contact->id().localId() == priv->manager->selfContactId())
                return true;
        }
        return false;
    }
    case EmailAddressRole:
    {
        QStringList list;
        foreach (const QContactEmailAddress& email,
                 contact->details<QContactEmailAddress>()){
            if(!email.emailAddress().isNull())
                list << email.emailAddress();
        }
        return list;
    }
    case EmailContextRole:
    {
        QStringList list;
        foreach (const QContactEmailAddress& email,
                 contact->details<QContactEmailAddress>()){
            if(!email.contexts().isEmpty())
                list << email.contexts();
        }
        return list;
    }
    case PhoneNumberRole:
    {
        QStringList list;
        foreach (const QContactPhoneNumber& phone,
                 contact->details<QContactPhoneNumber>()){
            if(!phone.number().isNull())
                list << phone.number();
        }
        return list;
    }
    case PhoneContextRole:
    {
        QStringList list;
        foreach (const QContactPhoneNumber& phone,
                 contact->details<QContactPhoneNumber>()){
            if(!phone.contexts().isEmpty())
                list << phone.contexts();
        }
        return list;
    }
    case AddressRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>()) {
            list << address.street() + "\n" + address.locality() + "\n" +
                    address.region() + "\n" + address.postcode() + "\n" +
                    address.country();
        }
        return list;
    }
    case AddressStreetRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>()){
            if(!address.street().isEmpty())
                list << address.street();
        }
        return list;
    }
    case AddressLocaleRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>()) {
            if(!address.locality().isNull())
                list << address.locality();
        }
        return list;
    }
    case AddressRegionRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>()) {
            if(!address.region().isNull())
                list << address.region();
        }
        return list;
    }
    case AddressCountryRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>()) {
            if(!address.country().isNull())
                list << address.country();
        }
        return list;
    }
    case AddressPostcodeRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>())
            list << address.postcode();
        return list;
    }

    case AddressContextRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact->details<QContactAddress>()) {
            if(!address.contexts().isEmpty())
                list << address.contexts();
            return list;
        }
    }
    case PresenceRole:
    {
        foreach (const QContactPresence& qp,
                 contact->details<QContactPresence>()) {
            if(!qp.isEmpty())
                if(qp.presenceState() == QContactPresence::PresenceAvailable)
                    return qp.presenceState();
        }
        foreach (const QContactPresence& qp,
                 contact->details<QContactPresence>()) {
            if(!qp.isEmpty())
                if(qp.presenceState() == QContactPresence::PresenceBusy)
                    return qp.presenceState();
        }
        return QContactPresence::PresenceUnknown;
    }

    case UuidRole:
    {
        QContactGuid guid = contact->detail<QContactGuid>();
        if(!guid.guid().isNull())
            return guid.guid();
        return QString();
    }

    case WebUrlRole:
    {
        QStringList list;
       foreach(const QContactUrl &url, contact->details<QContactUrl>()){
        if(!url.isEmpty())
            list << url.url();
       }
        return QStringList(list);
    }

    case WebContextRole:
    {
        QStringList list;
       foreach(const QContactUrl &url, contact->details<QContactUrl>()){
        if(!url.contexts().isEmpty())
            list << url.contexts();
       }
        return list;
    }

    case NotesRole:
    {
        QContactNote note = contact->detail<QContactNote>();
        if(!note.isEmpty())
            return note.note();
        return QString();
    }
    case FirstCharacterRole:
    {
        QContactName name = contact->detail<QContactName>();
        if ((sortOrder.isEmpty()) ||
           (sortOrder.at(0).detailFieldName() == QContactName::FieldFirstName)) {
            if(!name.firstName().isNull()){
                return QString(name.firstName().at(0).toUpper());
            }
        }

        if (sortOrder.at(0).detailFieldName() == QContactName::FieldLastName) {
            if(!name.lastName().isNull()){
                return QString(name.lastName().at(0).toUpper());
            }
        }

        return QString(tr("#"));
    }

    default:
        qWarning() << "[PeopleModel] request for data with unknown row" <<
                      row << " role : " << role;
        return QVariant();
    }
}

void PeopleModel::fixIndexMap()
{
    int i=0;
    beginResetModel();
    priv->idToIndex.clear();
    foreach (const QContactLocalId& id, priv->contactIds)
        priv->idToIndex.insert(id, i++);
    endResetModel();
}

void PeopleModel::fetchContactsRequest()
{
    QContactFetchRequest *request = qobject_cast<QContactFetchRequest*>(QObject::sender());

    if (request->error() != QContactManager::NoError) {
        qDebug() << "[PeopleModel] Error" << request->error()
                 << "occurred during fetch request!";
        return;
    }

    if (request == &fetchAddedContacts)
    {
        QList<QContact> addedContactsList = fetchAddedContacts.contacts();

        int size = priv->contactIds.size();
        int added = addedContactsList.size();

        beginInsertRows(QModelIndex(), size, size + added - 1);
        addContacts(addedContactsList, size);
        endInsertRows();

        qDebug() << "[DataGenModel] Done updating model after adding"
                 << added << "contacts";
    }

    else if (request == &fetchAllContacts)
    {
        QList<QContact> contactsList = fetchAllContacts.contacts();
        int size = 0;

        qDebug() << "[PeopleModel] Starting model reset, size: " << contactsList.size();
        beginResetModel();

        foreach (QContact *contact, priv->idToContact.values())
            delete contact;

        priv->contactIds.clear();
        priv->idToContact.clear();
        priv->idToIndex.clear();
        priv->uuidToId.clear();
        priv->idToUuid.clear();

        addContacts(contactsList, size);

        endResetModel();
        qDebug() << "[PeopleModel] Done with model reset";
    }

    else if (request == &fetchChangedContacts)
    {
        // NOTE: this implementation sends one dataChanged signal with
        // the minimal range that covers all the changed contacts, but it
        // could be more efficient to send multiple dataChanged signals,
        // though more work to find them
        int min = priv->contactIds.size();
        int max = 0;

        QList<QContact> changedContactsList = fetchChangedContacts.contacts();

        foreach (QContact changedContact, changedContactsList) {
            int index = priv->idToIndex.value(changedContact.localId());

            if (index < min)
                min = index;

            if (index > max)
                max = index;

            // FIXME: this looks like it may be wrong,
            // could lead to multiple entries
            QContact *contact = priv->idToContact[changedContact.localId()];
            if (contact) {
                *contact = changedContact;
            }
        }

        // FIXME: unfortunate that we can't easily identify what changed
        /*if (min <= max)
            emit dataChanged(index(min, 0), index.data(PeopleModel::LastNameRole));*/

        dataReset(); //REVIST: force list refresh to get around http://bugreports.qt.nokia.com/browse/QTBUG-13664

        qDebug() << "[PeopleModel] Done updating model after contacts update";
    }

    else if (request == &fetchMeCard)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            return;

        const QContactLocalId meCardId(priv->manager->selfContactId());
        QList<QContact> meCardList = fetchMeCard.contacts();
        QContact meContact;

        //if contact doesn't exist, create it
        if ((meCardList.size() == 0) || (meCardList.at(0).localId() != meCardId)) {
            QContactId contactId;

            if (meCardList.size() == 0)
                meContact = *(new QContact());
            else
                meContact = meCardList.at(0);

            qDebug() << "[PeopleModel] self contact does not exist, "
                     << "create meCard with selfId. Local id: "
                     << meContact.localId() <<"is not self id " << meCardId;
            contactId.setLocalId(meCardId);
            meContact.setId(contactId);

            addMeCard.setContact(meContact);
            addMeCard.start();
        } else {
            qDebug() << "PeopleModel::PeopleModel() id is valid"
                     << "and MeCard exists" << meCardId;

            meContact = meCardList.at(0);

            //If it does exist, check that contact has valid firstname
            QString firstname = meContact.detail<QContactName>().firstName();
            qDebug() << "[PeopleModel] meCard has firstname" << firstname;

            //if no firstname, then update meCard
            if (firstname.isEmpty() || firstname.isNull()){
                createMeCard(meContact);
            } else {//else do nothing
                qDebug() << "PeopleModel() VALID MECARD EXISTS";
            }
        }
    }

    else
        qDebug() << "[PeopleModel] Error: unexpected request!";
}

void PeopleModel::saveContactsRequest()
{
    QContactSaveRequest *request = qobject_cast<QContactSaveRequest*>(QObject::sender());

    if (request->error() != QContactManager::NoError) {
        qDebug() << "[PeopleModel] Error" << request->error()
                 << "occurred during save request!";
        return;
    }

    if (request == &addMeCard)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            return;

        QList<QContact> meCardList = addMeCard.contacts();
        if (meCardList.size() < 0) {
            qDebug() << "[PeopleModel] Error - failed to save meCard";
            return;
        }

        QContact card = meCardList.at(0);
        createMeCard(card);
    }

    else if (request == &updateMeCard)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            return;

        QList<QContact> meCardList = updateMeCard.contacts();
        if (meCardList.size() < 0) {
            qDebug() << "[PeopleModel] Error - failed to save meCard";
            return;
        }

        const QContactLocalId meCardId = meCardList.at(0).localId();
        qDebug() << "[PeopleModel] meCardId generated: " << meCardId;
    }

    else if (request == &updateContact)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            return;

        QList<QContact> contactList = updateContact.contacts();

        foreach (QContact new_contact, contactList)
        {
            // make sure data shown to user matches what is
            // really in the database
            QContactLocalId id = new_contact.localId();
            QContact *contact = priv->idToContact[id];
            contact = &new_contact;
        }
    }

    else if (request == &updateAvatar)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            qDebug() << "[PeopleModel] Contact's avatar updated successfully";
    }
    else if (request == &updateFavorite)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            qWarning() << "[PeopleModel] Contact's favorite updated successfully";
        dataReset(); //force list refresh
    }

    else
        qDebug() << "[PeopleModel] Error: unexpected request!";
}

void PeopleModel::removeContactsRequest()
{
    qWarning() << "[PeopleModel] Calling removeContactsRequest";
    QContactRemoveRequest *request = qobject_cast<QContactRemoveRequest*>(QObject::sender());

    if (request->error() != QContactManager::NoError) {
        qDebug() << "[PeopleModel] Error" << request->error()
                 << "occurred during remove request!";
        return;
    }


    if (request == &removeContact)
    {
        if (request->state() != QContactAbstractRequest::FinishedState)
            return;

        qDebug() << "[PeopleModel] Removed" << removeContact.contactIds()
                 << "contacts from tracker";
    }
}

void PeopleModel::addContacts(const QList<QContact> contactsList,
                              int size)
{
    foreach (QContact contact, contactsList) {
        QContactLocalId id = contact.localId();

        //Do NOT load MeCard
        if(contact.localId() != priv->manager->selfContactId()){

            priv->contactIds.push_back(id);
            priv->idToIndex.insert(id, size++);
            QContact *new_contact = new QContact(contact);
            priv->idToContact.insert(id, new_contact);

            QContactGuid guid = new_contact->detail<QContactGuid>();
            if (!guid.isEmpty() && !guid.guid().isNull()) {
                QUuid uuid(guid.guid());
                priv->uuidToId.insert(uuid, id);
                priv->idToUuid.insert(id, uuid);
            }

        }
    }
}

void PeopleModel::contactsAdded(const QList<QContactLocalId>& contactIds)
{
    qDebug() << "[PeopleModel] contacts added:" << contactIds;
    if (contactIds.size() == 0)
        return;

    QContactLocalIdFilter filter;
    filter.setIds(contactIds);
    fetchAddedContacts.setFilter(filter);
    if(!sortOrder.isEmpty())
        fetchAddedContacts.setSorting(sortOrder);
    fetchAddedContacts.start();
}

void PeopleModel::contactsChanged(const QList<QContactLocalId>& contactIds)
{
    if (contactIds.size() == 0)
        return;

    qDebug() << "[PeopleModel] contacts changed:" << contactIds;
    QContactLocalIdFilter filter;
    filter.setIds(contactIds);
    fetchChangedContacts.setFilter(filter);
    if(!sortOrder.isEmpty())
        fetchChangedContacts.setSorting(sortOrder);
    fetchChangedContacts.start();
}

void PeopleModel::contactsRemoved(const QList<QContactLocalId>& contactIds)
{
    qDebug() << "[PeopleModel] contacts removed:" << contactIds;
    // FIXME: the fact that we're only notified after removal may mean that we must
    //   store the full contact in the model, because the data could be invalid
    //   when the view goes to access it

    QList<int> removed;
    foreach (const QContactLocalId& id, contactIds)
        removed.push_front(priv->idToIndex.value(id));
    qSort(removed);

    // NOTE: this could check for adjacent rows being removed and send fewer signals
    int size = removed.size();
    for (int i=0; i<size; i++) {
        // remove in reverse order so the other index numbers will not change
        int index = removed.takeLast();
        beginRemoveRows(QModelIndex(), index, index);
        QContactLocalId id = priv->contactIds.takeAt(index);
        delete priv->idToContact[id];
        priv->idToContact.remove(id);
        priv->idToIndex.remove(id);

        QUuid uuid = priv->idToUuid[id];
        if (!uuid.isNull()) {
            priv->idToUuid.remove(id);
            priv->uuidToId.remove(uuid);
        }
        endRemoveRows();
    }
    fixIndexMap();
}

void PeopleModel::dataReset()
{
    QContactDetailFilter temp = priv->currentFilter;
    qDebug() << "[PeopleModel] data reset " << temp.value().toString();
    fetchAllContacts.setFilter(priv->currentFilter);
    if(!sortOrder.isEmpty())
        fetchAllContacts.setSorting(sortOrder);
    fetchAllContacts.start();
}

bool PeopleModel::createPersonModel(QString avatarUrl, QString thumbUrl, QString firstName, QString lastName, QString companyname,
                                    QStringList phonenumbers, QStringList phonecontexts, bool favorite,
                                    QStringList accounturis, QStringList serviceproviders, QStringList emailaddys,
                                    QStringList emailcontexts, QStringList street, QStringList city, QStringList state,
                                    QStringList zip, QStringList country, QStringList addresscontexts,
                                    QStringList urllinks,  QStringList urlcontexts, QDate birthday, QString notetext)
{
    QContact contact;

    QContactGuid guid;
    guid.setGuid(QUuid::createUuid());
    contact.saveDetail(&guid);

    QContactAvatar avatar;
    avatar.setImageUrl(avatarUrl);
    contact.saveDetail(&avatar);

    if (!QUrl(thumbUrl).path().isNull()) {
        QContactThumbnail thumb;
        QImage thumbImage(QUrl(thumbUrl).path());
        thumb.setThumbnail(thumbImage);
        contact.saveDetail(&thumb);
    }

    QContactName name;
    name.setFirstName(firstName);
    name.setLastName(lastName);
    contact.saveDetail(&name);

    QContactOrganization company;
    company.setName(companyname);
    contact.saveDetail(&company);

    for(int i=0; i < phonenumbers.size(); i++){
        QContactPhoneNumber phone;
        phone.setContexts(phonecontexts.at(i));
        phone.setNumber(phonenumbers.at(i));
        contact.saveDetail(&phone);
    }

    QContactFavorite fav;
    fav.setFavorite(favorite);
    contact.saveDetail(&fav);

    for(int i =0; i < accounturis.size(); i++){
        QContactOnlineAccount account;
        account.setAccountUri(accounturis.at(i));

        //REVISIT: We should use setServiceProvider, but this isn't supported
        //setProtocol() would be a better choice, but it also isn't working as expected
        //BUG: https://bugs.meego.com/show_bug.cgi?id=13454
        //account.setServiceProvider(serviceproviders.at(i));
        account.setSubTypes(serviceproviders.at(i));

        contact.saveDetail(&account);
    }

    for(int i =0; i < emailaddys.size(); i++){
        QContactEmailAddress email;
        email.setEmailAddress(emailaddys.at(i));
        email.setContexts(emailcontexts.at(i));
        contact.saveDetail(&email);
    }

    for(int i =0; i < street.size(); i++){
        QContactAddress address;
        address.setStreet(street.at(i));
        address.setLocality(city.at(i));
        address.setRegion(state.at(i));
        address.setCountry(country.at(i));
        address.setPostcode(zip.at(i));
        address.setContexts(addresscontexts.at(i));
        contact.saveDetail(&address);
    }

    for(int i =0; i < urllinks.size(); i++){
        QContactUrl url;
        url.setUrl(urllinks.at(i));
        url.setContexts(urlcontexts.at(i));
        contact.saveDetail(&url);
    }

    QContactBirthday birthdate;
    if(!birthday.isNull()){
        birthdate.setDate(birthday);
        contact.saveDetail(&birthdate);
    }

    QContactNote note;
    note.setNote(notetext);
    contact.saveDetail(&note);

    //ASYNC this
    if(!priv->manager->saveContact(&contact))
        qWarning() << "[PeopleModel] New contact failed on save";

    return true;
}

void PeopleModel::deletePerson(QString uuid)
{
    qWarning() << "[PeopleModel] attempted to remove " +uuid;
    // if(priv->manager->selfContactId() != priv->uuidToId[uuid])
    //  {
    qWarning() << "[PeopleModel] attempted to remove " +uuid;
    removeContact.setContactId(priv->uuidToId[uuid]);
    removeContact.start();
    //  }else{
    //   qWarning() << "[PeopleModel] attempted to remove MeCard";
    // }
}

void PeopleModel::editPersonModel(QString uuid, QString avatarUrl, QString firstName, QString lastName, QString companyname,
                                  QStringList phonenumbers, QStringList phonecontexts, bool favorite,
                                  QStringList accounturis, QStringList serviceproviders, QStringList emailaddys,
                                  QStringList emailcontexts, QStringList street, QStringList city, QStringList state,
                                  QStringList zip, QStringList country, QStringList addresscontexts,
                                  QStringList urllinks,  QStringList urlcontexts, QDate birthday, QString notetext)
{
    QContactLocalId id = priv->uuidToId[uuid];
    QContact *contact = priv->idToContact[id];
    if (!contact) {
        // we are creating a new contact
        contact = new QContact;

        QContactGuid guid;
        guid.setGuid(QUuid::createUuid().toString());
        if (!contact->saveDetail(&guid))
            qWarning() << "[PeopleModel] failed to save guid in new contact";

        QContactAvatar avatar;
        avatar.setImageUrl(QUrl("icon-m-content-avatar-placeholder"));
        if (!contact->saveDetail(&avatar))
            qWarning() << "[PeopleModel] failed to save avatar in new contact";
    }

    //REVIST: Don't call createPersonModel to get what is currently in the model.
    //We can always assume that the strings passed in reflect what is currently in the model
    //QContact *oldModel = new QContact();// = createPersonModel(guid.guid());

    QContactAvatar avatar = contact->detail<QContactAvatar>();
    if (avatar.imageUrl() != avatarUrl) {
        avatar.setImageUrl(avatarUrl);
        contact->saveDetail(&avatar);
    }

    QContactName name = contact->detail<QContactName>();
    if ((name.firstName() != firstName) || (name.lastName() != lastName)) {
        name.setFirstName(firstName);
        name.setLastName(lastName);
        name.setMiddleName("");
        name.setPrefix("");
        name.setSuffix("");
        if (!contact->saveDetail(&name))
            qWarning() << "[PeopleModel] failed to update name";
    }

    QContactOrganization company = contact->detail<QContactOrganization>();
    if (company.name() != companyname) {
        company.setName(companyname);
        if (!contact->saveDetail(&company))
            qDebug() << "[PeopleModel] failed to update company";
    }

    //Remove all existing phones; then add all phones from edit page
    foreach (QContactDetail detail, contact->details<QContactPhoneNumber>()) {
        if (!contact->removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove phone number";
    }

    for(int i=0; i < phonenumbers.size(); i++){
        QContactPhoneNumber phone;
        phone.setContexts(phonecontexts.at(i));
        phone.setNumber(phonenumbers.at(i));
        contact->saveDetail(&phone);
    }

    QContactFavorite fav = contact->detail<QContactFavorite>();
    fav.setFavorite(favorite);
    contact->saveDetail(&fav);

    //Remove all existing IM accounts; then add all IM accounts from edit page
    foreach (QContactDetail detail, contact->details<QContactOnlineAccount>()) {
        if (!contact->removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove im account";
    }

    for (int i =0; i < accounturis.size(); i++){
        QContactOnlineAccount account;
        account.setAccountUri(accounturis.at(i));

        //REVISIT: We should use setServiceProvider, but this isn't supported
        //setProtocol() would be a better choice, but it also isn't working as expected
        //BUG: https://bugs.meego.com/show_bug.cgi?id=13454
        //account.setServiceProvider(serviceproviders.at(i));
        account.setSubTypes(serviceproviders.at(i));

        contact->saveDetail(&account);
    }

    //Remove all existing email addresses; then add all email addresses from edit page
    foreach (QContactDetail detail, contact->details<QContactEmailAddress>()) {
        if (!contact->removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove email address";
    }

    for (int i =0; i < emailaddys.size(); i++){
        QContactEmailAddress email;
        email.setEmailAddress(emailaddys.at(i));
        email.setContexts(emailcontexts.at(i));
        contact->saveDetail(&email);
    }

    //Remove all existing addresses; then add all addresses from edit page
    foreach (QContactDetail detail, contact->details<QContactAddress>()) {
        if (!contact->removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove addresses";
    }

    for(int i =0; i < street.size(); i++){
        QContactAddress address;
        address.setStreet(street.at(i));
        address.setLocality(city.at(i));
        address.setRegion(state.at(i));
        address.setCountry(country.at(i));
        address.setPostcode(zip.at(i));
        address.setContexts(addresscontexts.at(i));
        contact->saveDetail(&address);
    }

    //Remove all existing URLs; then add all URLs from edit page
    foreach (QContactDetail detail, contact->details<QContactUrl>()) {
        if (!contact->removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove addresses";
    }

    for(int i =0; i < urllinks.size(); i++){
        QContactUrl url;
        url.setUrl(urllinks.at(i));
        url.setContexts(urlcontexts.at(i));
        contact->saveDetail(&url);
    }

    QContactBirthday birthdate = contact->detail<QContactBirthday>();
    if (birthdate.date() != birthday) {
        birthdate.setDate(birthday);
        contact->saveDetail(&birthdate);
    }

    QContactNote note = contact->detail<QContactNote>();
    if (note.note() != notetext) {
        note.setNote(notetext);
        contact->saveDetail(&note);
    }

    updateContact.setContact(*contact);
    updateContact.start();
}

void PeopleModel::setCurrentUuid(const QString& uuid)
{
    priv->currentGuid.setGuid(uuid);
    qDebug() << "sets current uuid to " << uuid << "test " << priv->currentGuid.guid();
}

void PeopleModel::setAvatar(const QString& path)
{  
    QContactLocalId id = priv->uuidToId[priv->currentGuid.guid()];
    QContact *contact = priv->idToContact[id];
    if (!contact)
        return;

    QContactAvatar avatar = contact->detail<QContactAvatar>();
    if (path.isEmpty())
        avatar.setImageUrl(QUrl("icon-m-content-avatar-placeholder"));
    else
        avatar.setImageUrl(QUrl(path));
    if (!contact->saveDetail(&avatar))
        qWarning() << "[PeopleModel] failed to save avatar";

    updateAvatar.setContact(*contact);
    updateAvatar.start();
}

void PeopleModel::setFavorite(const QString& uuid, bool favorite)
{
    QContactLocalId id = priv->uuidToId[uuid];
    QContact *contact = priv->idToContact[id];
    if (!contact)
        return;

    QContactFavorite fav = contact->detail<QContactFavorite>();
    fav.setFavorite(favorite);

    if (!contact->saveDetail(&fav)) {
        qWarning() << Q_FUNC_INFO << "failed to save favorite to " << fav;
		return;
    }

    updateFavorite.setContact(*contact);
    updateFavorite.start();

    QList<QContactLocalId> list;
    list.append(priv->uuidToId[uuid]);

    // writing doesn't cause a change event, so manually call
    contactsChanged(list);
}

void PeopleModel::toggleFavorite(const QString& uuid)
{
    QContactLocalId id = priv->uuidToId[uuid];
    QContact *contact = priv->idToContact[id];
    if (!contact)
        return;

    QContactFavorite fav = contact->detail<QContactFavorite>();
    fav.setFavorite(!fav.isFavorite());

    if (!contact->saveDetail(&fav))
        qWarning() << "[PeopleModel] failed to set favorite to " << fav;

    updateFavorite.setContact(*contact);
    updateFavorite.start();

    QList<QContactLocalId> list;
    list.append(priv->uuidToId[uuid]);

    // writing doesn't cause a change event, so manually call
    contactsChanged(list);
}

void PeopleModel::setCompany(const QUuid& uuid, QString company)
{
    Q_UNUSED(uuid);
    Q_UNUSED(company);
    qWarning() << "[PeopleModel::setCompany] DEPRECATED FUNCTION";
}

void PeopleModel::setisSelf(const QUuid& uuid, bool self)
{
    if (!priv->settings)
        return;

    QString key = uuid.toString();
    key += "/self";
    priv->settings->setValue(key, self);
    priv->settings->sync();

    QList<QContactLocalId> list;
    list.append(priv->uuidToId[uuid]);

    // writing to QSettings doesn't cause a change event, so manually call
    contactsChanged(list);
}

void PeopleModel::exportContact(QString uuid,  QString filename){
    QVersitContactExporter exporter;
    QList<QContact> contacts;
    QList<QVersitDocument> documents;

    QContactLocalId id = priv->uuidToId[uuid];
    QContact person = *priv->idToContact[id];

    if(person.isEmpty()){
        qWarning() << "[PeopleModel] no contact found to export with uuid " + uuid;
        return;
    }

    contacts.append(person);
    exporter.exportContacts(contacts);
    documents = exporter.documents();

    QFile * file = new QFile(filename);
    if(file->open(QIODevice::ReadWrite)){
        priv->m_writer.setDevice(file);
        priv->m_writer.startWriting(documents);
    }else{
        qWarning() << "[PeopleModel] vCard export failed for contact with uuid " + uuid;
    }
}

void PeopleModel::vCardFinished(QVersitWriter::State state){
    if(state == QVersitWriter::FinishedState || state == QVersitWriter::CanceledState){
        delete priv->m_writer.device();
        priv->m_writer.setDevice(0);
    }
}

void PeopleModel::setSorting(int role){
    QContactSortOrder sort;

    switch(role){
    case LastNameRole:
        sort.setDetailDefinitionName(QContactName::DefinitionName, 
                                     QContactName::FieldLastName);
        break;
    case FirstNameRole:
    default:
        sort.setDetailDefinitionName(QContactName::DefinitionName, 
                                     QContactName::FieldFirstName);
        break;
    }

    sort.setDirection(Qt::AscendingOrder);
    sortOrder.clear();
    sortOrder.append(sort);
}

int PeopleModel::getSortingRole(){
    if ((sortOrder.isEmpty()) ||
       (sortOrder.at(0).detailFieldName() == QContactName::FieldFirstName))
        return PeopleModel::FirstNameRole;
    else if (sortOrder.at(0).detailFieldName() == QContactName::FieldLastName)
        return PeopleModel::LastNameRole;

    return PeopleModel::FirstNameRole;
}

void PeopleModel::setFilter(int role, bool dataResetNeeded){
    switch(role){
    case FavoritesFilter:
    {
        QContactDetailFilter favFilter;
        favFilter.setDetailDefinitionName(QContactFavorite::DefinitionName, QContactFavorite::FieldFavorite);
        favFilter.setValue("true");
        priv->currentFilter = favFilter;
        break;
    }
    case OnlineFilter:
    {
        QContactDetailFilter availableFilter;
        availableFilter.setDetailDefinitionName(QContactPresence::DefinitionName, QContactPresence::FieldPresenceState);
        availableFilter.setValue(QContactPresence::PresenceAvailable);
        priv->currentFilter = availableFilter;
        break;
    }
    case AllFilter:
    {
        priv->currentFilter = QContactFilter();
        break;
    }
    case ContactFilter:
    {
        QContactDetailFilter contactFilter;
        contactFilter.setDetailDefinitionName(QContactGuid::DefinitionName, QContactGuid::FieldGuid);
        contactFilter.setValue(priv->currentGuid.guid());
        priv->currentFilter = contactFilter;
        break;
    }
    default:
    {
        priv->currentFilter = QContactFilter();
        break;
    }
    }

    if (dataResetNeeded)
        dataReset();
}

void PeopleModel::searchContacts(const QString text){

        qWarning() << "#################[PeopleModel] searchContact " + text;
        QList<QContactFilter> filterList;
        QContactUnionFilter unionFilter;

        QContactDetailFilter nameFilter;
        nameFilter.setDetailDefinitionName(QContactName::DefinitionName);
        nameFilter.setValue(text);
        nameFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(nameFilter);

        QContactDetailFilter labelFilter;
        labelFilter.setDetailDefinitionName(QContactDisplayLabel::DefinitionName);
        labelFilter.setValue(text);
        labelFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(labelFilter);

        QContactDetailFilter companyFilter;
        companyFilter.setDetailDefinitionName(QContactOrganization::DefinitionName);
        companyFilter.setValue(text);
        companyFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(companyFilter);

        QContactDetailFilter phoneFilter;
        phoneFilter.setDetailDefinitionName(QContactPhoneNumber::DefinitionName);
        phoneFilter.setValue(text);
        phoneFilter.setMatchFlags(QContactFilter::MatchContains | QContactFilter::MatchPhoneNumber);
        filterList.append(phoneFilter);

        QContactDetailFilter emailFilter;
        emailFilter.setDetailDefinitionName(QContactEmailAddress::DefinitionName);
        emailFilter.setValue(text);
        emailFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(emailFilter);

        QContactDetailFilter addressFilter;
        addressFilter.setDetailDefinitionName(QContactAddress::DefinitionName);
        addressFilter.setValue(text);
        addressFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(addressFilter);

        QContactDetailFilter urlFilter;
        urlFilter.setDetailDefinitionName(QContactUrl::DefinitionName);
        urlFilter.setValue(text);
        urlFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(urlFilter);

        unionFilter.setFilters(filterList);
        priv->currentFilter = unionFilter;
        dataReset();
}

void PeopleModel::clearSearch(){
     setFilter(AllFilter);
}




