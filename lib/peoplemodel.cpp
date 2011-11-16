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
#include <QContactAvatar>
#include <QContactThumbnail>
#include <QContactBirthday>
#include <QContactEmailAddress>
#include <QContactGuid>
#include <QContactName>
#include <QContactNickname>
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
#include "peoplemodel_p.h"

PeopleModel::PeopleModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles.insert(AvatarRole, "avatarurl");
    roles.insert(FirstNameRole, "firstname");
    roles.insert(FirstCharacterRole, "firstcharacter");
    roles.insert(LastNameRole, "lastname");
    setRoleNames(roles);

    priv = new PeopleModelPriv(this);

    QContactSortOrder sort;
    sort.setDetailDefinitionName(QContactName::DefinitionName, QContactName::FieldFirstName);
    sort.setDirection(Qt::AscendingOrder);
    priv->sortOrder.clear();
    priv->sortOrder.append(sort);

    qDebug() << Q_FUNC_INFO << QContactManager::availableManagers();
    if (!qgetenv("NEMO_CONTACT_MANAGER").isNull())
        priv->manager = new QContactManager(qgetenv("NEMO_CONTACT_MANAGER"));
    else
        priv->manager = new QContactManager;

    qDebug() << Q_FUNC_INFO << "Manager is " << priv->manager->managerName();

    priv->settings = new QSettings("MeeGo", "meego-app-contacts");

    //MeCard feature not added yet
    if (priv->manager->hasFeature(QContactManager::SelfContact, QContactType::TypeContact)) {
        // self contact supported by manager - let's try fetch the me card
        const QContactLocalId meCardId(priv->manager->selfContactId());

        //if we have a valid selfId
        if (meCardId != 0) {
            qDebug() << Q_FUNC_INFO << "valid selfId, id " << meCardId;
            // Fetch self contact to check it
            QContactFetchByIdRequest *meFetchRequest = new QContactFetchByIdRequest(this);
            connect(meFetchRequest,
                    SIGNAL(stateChanged(QContactAbstractRequest::State)),
                    SLOT(onMeFetchRequestStateChanged(QContactAbstractRequest::State)));
            meFetchRequest->setLocalIds(QList<QContactLocalId>() << meCardId);
            meFetchRequest->setManager(priv->manager);
            meFetchRequest->start();
        } else {
            qWarning() << Q_FUNC_INFO << "no valid meCard Id provided";
        }
    } else {
        qWarning() << Q_FUNC_INFO << "MeCard Not supported";
    }

    priv->localeHelper = LocaleUtils::self();

    connect(priv->manager, SIGNAL(contactsAdded(QList<QContactLocalId>)),
            this, SLOT(contactsAdded(QList<QContactLocalId>)));
    connect(priv->manager, SIGNAL(contactsChanged(QList<QContactLocalId>)),
            this, SLOT(contactsChanged(QList<QContactLocalId>)));
    connect(priv->manager, SIGNAL(contactsRemoved(QList<QContactLocalId>)),
            this, SLOT(contactsRemoved(QList<QContactLocalId>)));
    connect(priv->manager, SIGNAL(dataChanged()), this, SLOT(dataReset()));
    connect(&priv->writer, SIGNAL(stateChanged(QVersitWriter::State)),
            this, SLOT(vCardFinished(QVersitWriter::State)));

    dataReset();
}

// for Me card support
void PeopleModel::createMeCard(QContact me)
{
  qDebug() << Q_FUNC_INFO << me;

  QContactGuid guid = me.detail<QContactGuid>();
  if (guid.isEmpty()) {
    guid.setGuid(QUuid::createUuid().toString());
    if (!me.saveDetail(&guid))
      qWarning() << Q_FUNC_INFO << "failed to save guid in mecard contact";
  }

  QContactAvatar avatar;
  avatar.setImageUrl(QUrl("image://themedimage/widgets/common/avatar/avatar-default"));
  if (!me.saveDetail(&avatar))
      qWarning() << Q_FUNC_INFO << "failed to save avatar in mecard contact";

  QContactName name;
  name.setFirstName(QObject::tr(" Me","Default string to describe self if no self contact information found, default created with [Me] as firstname"));
  name.setLastName("");
  if (!me.saveDetail(&name))
    qWarning() << Q_FUNC_INFO << "failed to save mecard name";

    QContactFavorite fav;
    fav.setFavorite(false);
    if (!me.saveDetail(&fav))
        qWarning() << "[PeopleModel] failed to save mecard favorite to " << fav.isFavorite();

  bool isSelf = true;
  if (priv->settings) {
    QString key = guid.guid();
    key += "/self";
    priv->settings->setValue(key, isSelf);
  }

  queueContactSave(me);
}

PeopleModel::~PeopleModel()
{
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
    if (row < 0 || row >= priv->contactIds.count())
        return QVariant();

    QContactLocalId id = priv->contactIds[row];
    QContact &contact = priv->idToContact[id];

      if(contact.isEmpty())
		return QVariant();

    switch (role) {
    case ContactRole:
    {
        return contact.id().localId();
    }
    case FirstNameRole:
    {
        QContactName name = contact.detail<QContactName>();
        if(!name.firstName().isNull()){
            return QString(name.firstName());
        }
        return QString();
    }
    case FirstNameProRole:
    {
        QContactNickname nickname = contact.detail<QContactNickname>();
        if(!nickname.nickname().isNull()) {
            QStringList list = nickname.nickname().split("\n"); 
            if (list.size() > 1)
                return QString(list.at(1));
        }
        return QString();
    }
    case LastNameRole:
    {
        QContactName name = contact.detail<QContactName>();
        if(!name.lastName().isNull())
            return QString(name.lastName());
        return QString();
    }
    case LastNameProRole:
    {
        QContactNickname nickname = contact.detail<QContactNickname>();
        if(!nickname.nickname().isNull()) {
            QStringList list = nickname.nickname().split("\n"); 
            if (list.size() > 0)
                return QString(list.at(0));
        }
        return QString();
    }
    case CompanyNameRole:
    {
        QContactOrganization company = contact.detail<QContactOrganization>();
        if(!company.name().isNull())
            return QString(company.name());
        return QString();
    }
    case BirthdayRole:
    {
        QContactBirthday day = contact.detail<QContactBirthday>();
        if(!day.date().isNull())
            return day.date().toString(Qt::SystemLocaleDate);
        return QString();
    }
    case AvatarRole:
    {
        QContactAvatar avatar = contact.detail<QContactAvatar>();
        if(!avatar.imageUrl().isEmpty()) {
            return QUrl(avatar.imageUrl()).toString();
        }
        return QString();
    }
    case ThumbnailRole:
    {
        QContactThumbnail thumb = contact.detail<QContactThumbnail>();
        return thumb.thumbnail();
    }
    case FavoriteRole:
    {
        QContactFavorite fav = contact.detail<QContactFavorite>();
        if(!fav.isEmpty())
            return QVariant(fav.isFavorite());
        return false;
    }
    case OnlineAccountUriRole:
    {
        QStringList list;
        foreach (const QContactOnlineAccount& account,
                 contact.details<QContactOnlineAccount>()){
            if(!account.accountUri().isNull())
                list << account.accountUri();
        }
        return list;
    }
    case OnlineServiceProviderRole:
    {
        QStringList list;
        foreach (const QContactOnlineAccount& account,
                 contact.details<QContactOnlineAccount>()){
            if(!account.serviceProvider().isNull())
                list << account.serviceProvider();
        }
        return list;
    }
    case IsSelfRole:
    {
        if (isSelfContact(contact.id().localId()))
            return true;
        return false;
    }
    case EmailAddressRole:
    {
        QStringList list;
        foreach (const QContactEmailAddress& email,
                 contact.details<QContactEmailAddress>()){
            if(!email.emailAddress().isNull())
                list << email.emailAddress();
        }
        return list;
    }
    case EmailContextRole:
    {
        QStringList list;
        foreach (const QContactEmailAddress& email,
                 contact.details<QContactEmailAddress>()) {
            if (email.contexts().count() > 0)
                list << email.contexts().at(0);
        }
        return list;
    }
    case PhoneNumberRole:
    {
        QStringList list;
        foreach (const QContactPhoneNumber& phone,
                 contact.details<QContactPhoneNumber>()){
            if(!phone.number().isNull())
                list << phone.number();
        }
        return list;
    }
    case PhoneContextRole:
    {
        QStringList list;
        foreach (const QContactPhoneNumber& phone,
                 contact.details<QContactPhoneNumber>()) {
            if (phone.contexts().count() > 0)
                list << phone.contexts().at(0);
            else if (phone.subTypes().count() > 0)
                list << phone.subTypes().at(0);
        }
        return list;
    }
    case AddressRole:
    {
        QStringList list;
        QStringList fieldOrder = priv->localeHelper->getAddressFieldOrder();

        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>()) {
            QString aStr;
            QString temp;
            QString addy = address.street();
            QStringList streetList = addy.split("\n");

            for (int i = 0; i < fieldOrder.size(); ++i) {
                temp = "";
                if (fieldOrder.at(i) == "street") {
                    if (streetList.count() == 2)
                        temp += streetList.at(0);
                    else
                        temp += addy;
                } else if (fieldOrder.at(i) == "street2") {
                    if (streetList.count() == 2)
                        temp += streetList.at(1);
                }
                else if (fieldOrder.at(i) == "locale")
                    temp += address.locality();
                else if (fieldOrder.at(i) == "region")
                    temp += address.region();
                else if (fieldOrder.at(i) == "zip")
                    temp += address.postcode();
                else if (fieldOrder.at(i) == "country")
                    temp += address.country();

                if (i > 0)
                    aStr += "\n" + temp.trimmed();
                else
                    aStr += temp.trimmed();
            }

            if (aStr == "")
                aStr = address.street() + "\n" + address.locality() + "\n" +
                       address.region() + "\n" + address.postcode() + "\n" +
                       address.country();
           list << aStr;
        }
        return list;
    }
    case AddressStreetRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>()){
            if(!address.street().isEmpty())
                list << address.street();
        }
        return list;
    }
    case AddressLocaleRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>()) {
            if(!address.locality().isNull())
                list << address.locality();
        }
        return list;
    }
    case AddressRegionRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>()) {
            if(!address.region().isNull())
                list << address.region();
        }
        return list;
    }
    case AddressCountryRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>()) {
            if(!address.country().isNull())
                list << address.country();
        }
        return list;
    }
    case AddressPostcodeRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>())
            list << address.postcode();
        return list;
    }

    case AddressContextRole:
    {
        QStringList list;
        foreach (const QContactAddress& address,
                 contact.details<QContactAddress>()) {
            if (address.contexts().count() > 0)
                list << address.contexts().at(0);
        }
        return list;
    }
    case PresenceRole:
    {
        foreach (const QContactPresence& qp,
                 contact.details<QContactPresence>()) {
            if(!qp.isEmpty())
                if(qp.presenceState() == QContactPresence::PresenceAvailable)
                    return qp.presenceState();
        }
        foreach (const QContactPresence& qp,
                 contact.details<QContactPresence>()) {
            if(!qp.isEmpty())
                if(qp.presenceState() == QContactPresence::PresenceBusy)
                    return qp.presenceState();
        }
        return QContactPresence::PresenceUnknown;
    }

    case UuidRole:
    {
        QContactGuid guid = contact.detail<QContactGuid>();
        if(!guid.guid().isNull())
            return guid.guid();
        return QString();
    }

    case WebUrlRole:
    {
        QStringList list;
       foreach(const QContactUrl &url, contact.details<QContactUrl>()){
        if(!url.isEmpty())
            list << url.url();
       }
        return QStringList(list);
    }

    case WebContextRole:
    {
        QStringList list;
       foreach(const QContactUrl &url, contact.details<QContactUrl>()){
        if(!url.contexts().isEmpty())
            list << url.contexts();
       }
        return list;
    }

    case NotesRole:
    {
        QContactNote note = contact.detail<QContactNote>();
        if(!note.isEmpty())
            return note.note();
        return QString();
    }
    case FirstCharacterRole:
    {
        if (isSelfContact(contact.id().localId()))
            return QString(tr("#"));

        //REVISIT: Move this or parts of this to localeutils.cpp
        QContactName name = contact.detail<QContactName>();
        QString nameStr1;
        QString nameStr2;
        if ((priv->sortOrder.isEmpty()) ||
           (priv->sortOrder.at(0).detailFieldName() == QContactName::FieldFirstName)) {
            if (priv->localeHelper->needPronounciationFields()) {
                QContactNickname nickname = contact.detail<QContactNickname>();
                QStringList list = nickname.nickname().split("\n");
                if (list.size() > 1)
                    nameStr1 = list.at(1);
                if (list.size() > 0)
                    nameStr2 = list.at(0);
            }

            if (nameStr1 == "")
                nameStr1 = name.firstName();
            if (nameStr2 == "")
                nameStr2 = name.lastName();
        }

        if (priv->sortOrder.at(0).detailFieldName() == QContactName::FieldLastName) {
            if (priv->localeHelper->needPronounciationFields()) {
                QContactNickname nickname = contact.detail<QContactNickname>();
                QStringList list = nickname.nickname().split("\n");
                if (list.size() > 0)
                    nameStr1 = list.at(0);
                if (list.size() > 1)
                    nameStr2 = list.at(1);
            }

            if (nameStr1 == "")
                nameStr1 = name.lastName();
            if (nameStr2 == "")
                nameStr2 = name.firstName();
        }

        if (!nameStr1.isNull())
            return priv->localeHelper->getBinForString(nameStr1);

        if (!nameStr2.isNull())
            return priv->localeHelper->getBinForString(nameStr2);

        QContactOrganization company = contact.detail<QContactOrganization>();
        if (!company.name().isNull())
            return priv->localeHelper->getBinForString(company.name());

        foreach (const QContactPhoneNumber& phone,
                 contact.details<QContactPhoneNumber>()){
            if(!phone.number().isNull())
                return priv->localeHelper->getBinForString(phone.number());
        }

        foreach (const QContactOnlineAccount& account,
                 contact.details<QContactOnlineAccount>()){
            if(!account.accountUri().isNull())
                return priv->localeHelper->getBinForString(account.accountUri());
        }

        foreach (const QContactEmailAddress& email,
                 contact.details<QContactEmailAddress>()){
            if(!email.emailAddress().isNull())
                return priv->localeHelper->getBinForString(email.emailAddress());
        }

        foreach (const QContactUrl &url, contact.details<QContactUrl>()){
            if (!url.isEmpty())
                return priv->localeHelper->getBinForString(url.url());
        }

        return priv->localeHelper->getBinForString(QString(""));
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

void PeopleModel::addContacts(const QList<QContact> contactsList,
                              int size)
{
    foreach (const QContact &contact, contactsList) {
        //qDebug() << Q_FUNC_INFO << "Adding contact " << contact.id() << " local " << contact.localId();
        QContactLocalId id = contact.localId();

        // Make sure we don't duplicate contacts
        if (!priv->idToIndex.contains(id)) {
          priv->contactIds.push_back(id);
          priv->idToIndex.insert(id, size++);
        }
        priv->idToContact.insert(id, contact);

        QContactGuid guid = contact.detail<QContactGuid>();
        if (!guid.isEmpty()) {
            QUuid uuid(guid.guid());
            priv->uuidToId.insert(uuid, id);
            priv->idToUuid.insert(id, uuid);
        }
    }
}

// helper function to check validity of sender and stuff.
template<typename T> inline T *checkRequest(QObject *sender, QContactAbstractRequest::State requestState)
{
    qDebug() << Q_FUNC_INFO << "Request state: " << requestState;
    T *request = qobject_cast<T *>(sender);
    if (!request) {
        qWarning() << Q_FUNC_INFO << "NULL request pointer";
        return 0;
    }

    if (request->error() != QContactManager::NoError) {
        qDebug() << Q_FUNC_INFO << "Error" << request->error()
                 << "occurred during request!";
        request->deleteLater();
        return 0;
    }

    if (requestState != QContactAbstractRequest::FinishedState &&
        requestState != QContactAbstractRequest::CanceledState)
    {
        // ignore
        return 0;
    }

    return request;
}

void PeopleModel::contactsAdded(const QList<QContactLocalId>& contactIds)
{
    if (contactIds.size() == 0)
        return;

    QContactLocalIdFilter filter;
    filter.setIds(contactIds);

    QContactFetchRequest *fetchRequest = new QContactFetchRequest(this);
    fetchRequest->setManager(priv->manager);
    connect(fetchRequest,
            SIGNAL(stateChanged(QContactAbstractRequest::State)),
            SLOT(onAddedFetchChanged(QContactAbstractRequest::State)));
    fetchRequest->setFilter(filter);
    qDebug() << Q_FUNC_INFO << "Fetching new contacts " << contactIds;

    if (!fetchRequest->start()) {
        qWarning() << Q_FUNC_INFO << "Fetch request failed";
        delete fetchRequest;
        return;
    }
}

void PeopleModel::onAddedFetchChanged(QContactAbstractRequest::State requestState)
{
    QContactFetchRequest *fetchRequest = checkRequest<QContactFetchRequest>(sender(), requestState);
    if (!fetchRequest)
        return;

    QList<QContact> addedContactsList = fetchRequest->contacts();

    int size = priv->contactIds.size();
    int added = addedContactsList.size();

    beginInsertRows(QModelIndex(), size, size + added - 1);
    addContacts(addedContactsList, size);
    endInsertRows();

    qDebug() << Q_FUNC_INFO << "Done updating model after adding"
        << added << "contacts";
    fetchRequest->deleteLater();
}

void PeopleModel::contactsChanged(const QList<QContactLocalId>& contactIds)
{
    if (contactIds.size() == 0)
        return;

    QContactLocalIdFilter filter;
    filter.setIds(contactIds);

    QContactFetchRequest *fetchRequest = new QContactFetchRequest(this);
    fetchRequest->setManager(priv->manager);
    connect(fetchRequest,
            SIGNAL(stateChanged(QContactAbstractRequest::State)),
            SLOT(onChangedFetchChanged(QContactAbstractRequest::State)));
    fetchRequest->setFilter(filter);

    qDebug() << Q_FUNC_INFO << "Fetching changed contacts " << contactIds;

    if (!fetchRequest->start()) {
        qWarning() << Q_FUNC_INFO << "Fetch request failed";
        delete fetchRequest;
        return;
    }
}

void PeopleModel::onChangedFetchChanged(QContactAbstractRequest::State requestState)
{
    QContactFetchRequest *fetchRequest = checkRequest<QContactFetchRequest>(sender(), requestState);
    if (!fetchRequest)
        return;

    // NOTE: this implementation sends one dataChanged signal with
    // the minimal range that covers all the changed contacts, but it
    // could be more efficient to send multiple dataChanged signals,
    // though more work to find them
    int min = priv->contactIds.size();
    int max = 0;

    QList<QContact> changedContactsList = fetchRequest->contacts();

    foreach (const QContact &changedContact, changedContactsList) {
        qDebug() << Q_FUNC_INFO << "Fetched changed contact " << changedContact.id();
        int index =priv->idToIndex.value(changedContact.localId());

        if (index < min)
            min = index;

        if (index > max)
            max = index;

        // FIXME: this looks like it may be wrong,
        // could lead to multiple entries
       priv->idToContact[changedContact.localId()] = changedContact;
    }

    // FIXME: unfortunate that we can't easily identify what changed
    if (min <= max)
        emit dataChanged(index(min, 0), index(max, 0));

    qDebug() << Q_FUNC_INFO << "Done updating model after contacts update";
    fetchRequest->deleteLater();
    dataReset();
}

void PeopleModel::contactsRemoved(const QList<QContactLocalId>& contactIds)
{
    qDebug() << Q_FUNC_INFO << "contacts removed:" << contactIds;
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
        QContactLocalId id = this->priv->contactIds.takeAt(index);

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
    qDebug() << Q_FUNC_INFO << "data reset";
    QContactFetchRequest *fetchRequest = new QContactFetchRequest(this);
    fetchRequest->setManager(priv->manager);
    connect(fetchRequest,
            SIGNAL(stateChanged(QContactAbstractRequest::State)),
            SLOT(onDataResetFetchChanged(QContactAbstractRequest::State)));
    fetchRequest->setFilter(priv->currentFilter);

    if (!fetchRequest->start()) {
        qWarning() << Q_FUNC_INFO << "Fetch request failed";
        delete fetchRequest;
        return;
    }
}

void PeopleModel::onDataResetFetchChanged(QContactAbstractRequest::State requestState)
{
    QContactFetchRequest *fetchRequest = checkRequest<QContactFetchRequest>(sender(), requestState);
    if (!fetchRequest)
        return;

    QList<QContact> contactsList = fetchRequest->contacts();
    int size = 0;

    qDebug() << Q_FUNC_INFO << "Starting model reset";
    beginResetModel();

    priv->contactIds.clear();
   priv->idToContact.clear();
   priv->idToIndex.clear();
   priv->uuidToId.clear();
    priv->idToUuid.clear();

    addContacts(contactsList, size);

    endResetModel();
    qDebug() << Q_FUNC_INFO << "Done with model reset";
    fetchRequest->deleteLater();
}

bool PeopleModel::createPersonModel(QString avatarUrl, QString thumbUrl, QString firstName, QString firstPro,
                                    QString lastName, QString lastPro, QString companyname,
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
    name.setFirstName(firstName.trimmed());
    name.setLastName(lastName.trimmed());
    contact.saveDetail(&name);

    //REVISIT: Should use something other than nickname
    //here.  When exporting a vCard, the pronounciations
    //should go into the X-PHONETIC-FIRST-NAME and
    //X-PHONETIC-LAST-NAME fields, not the nickname field.
    //******See bug: BMC#13923
    if (priv->localeHelper->getCountry() == QLocale::Japan) {
        QContactNickname nickname;
        nickname.setNickname(lastPro.trimmed() + "\n" + firstPro.trimmed());
        contact.saveDetail(&nickname);
    }

    QContactOrganization company;
    company.setName(companyname);
    contact.saveDetail(&company);

    for(int i=0; i < phonenumbers.size(); i++){
        QContactPhoneNumber phone;
        QString context = phonecontexts.at(i);
        // Mobile is a subType for QContact, not a context
        if(context == QContactPhoneNumber::SubTypeMobile)
          phone.setSubTypes(context);
        else
          phone.setContexts(context);
        phone.setNumber(phonenumbers.at(i));
        contact.saveDetail(&phone);
    }

    QContactFavorite fav;
    fav.setFavorite(favorite);
    contact.saveDetail(&fav);

    for(int i =0; i < accounturis.size(); i++){
        QContactOnlineAccount account;
        account.setAccountUri(accounturis.at(i));
        account.setServiceProvider(serviceproviders.at(i));

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

    queueContactSave(contact);

    return true;
}

void PeopleModel::deletePerson(const QString& uuid)
{
    if (isSelfContact(uuid)) {
        qWarning() << Q_FUNC_INFO << "attempted to remove MeCard";
        return;
    }

    removeContact(priv->uuidToId[uuid]);
}

void PeopleModel::editPersonModel(QString uuid, QString avatarUrl, QString firstName, QString firstPro,
                                  QString lastName, QString lastPro, QString companyname,
                                  QStringList phonenumbers, QStringList phonecontexts, bool favorite,
                                  QStringList accounturis, QStringList serviceproviders, QStringList emailaddys,
                                  QStringList emailcontexts, QStringList street, QStringList city, QStringList state,
                                  QStringList zip, QStringList country, QStringList addresscontexts,
                                  QStringList urllinks,  QStringList urlcontexts, QDate birthday, QString notetext)
{
    QContactLocalId id = priv->uuidToId[uuid];
    QContact &contact = priv->idToContact[id];

    if (contact.isEmpty()) {
       qWarning() << "[PeopleModel] Unable to find contact, cannot complete edit on uuid " << uuid;
       return;
    }

    //REVIST: Don't call createPersonModel to get what is currently in the model.
    //We can always assume that the strings passed in reflect what is currently in the model
    //QContact *oldModel = new QContact();// = createPersonModel(guid.guid());

    QContactAvatar avatar = contact.detail<QContactAvatar>();
    if (avatar.imageUrl() != avatarUrl) {
        avatar.setImageUrl(avatarUrl);
        contact.saveDetail(&avatar);
    }

    QContactName name = contact.detail<QContactName>();
    if ((name.firstName() != firstName) || (name.lastName() != lastName)) {
        name.setFirstName(firstName.trimmed());
        name.setLastName(lastName.trimmed());
        name.setMiddleName("");
        name.setPrefix("");
        name.setSuffix("");
        if (!contact.saveDetail(&name))
            qWarning() << "[PeopleModel] failed to update name";
    }

    //REVISIT: Should use something other than nickname
    //here.  When exporting a vCard, the pronounciations
    //should go into the X-PHONETIC-FIRST-NAME and
    //X-PHONETIC-LAST-NAME fields, not the nickname field.
    //******See bug: BMC#13923
    if (priv->localeHelper->getCountry() == QLocale::Japan) {
        QContactNickname nickname = contact.detail<QContactNickname>();
        QStringList list = nickname.nickname().split("\n"); 
        bool needsUpdate = false;

        if ((list.size() > 0) && (list.at(0) != lastPro.trimmed()))
            needsUpdate = true; 
        if ((list.size() > 1) && (list.at(1) != firstPro.trimmed()))
            needsUpdate = true; 

        if (needsUpdate == true) {
            nickname.setNickname(lastPro.trimmed() + "\n" + firstPro.trimmed());
            if (!contact.saveDetail(&nickname))
                qDebug() << "[PeopleModel] failed to update nickname";
        }
    }

    QContactOrganization company = contact.detail<QContactOrganization>();
    if (company.name() != companyname) {
        company.setName(companyname);
        if (!contact.saveDetail(&company))
            qDebug() << "[PeopleModel] failed to update company";
    }

    //Remove all existing phones; then add all phones from edit page
    foreach (QContactDetail detail, contact.details<QContactPhoneNumber>()) {
        if (!contact.removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove phone number";
    }

    for(int i=0; i < phonenumbers.size(); i++){
        QContactPhoneNumber phone;
        QString context = phonecontexts.at(i);
        // Mobile is a subType for QContact, not a context
        if(context == QContactPhoneNumber::SubTypeMobile)
          phone.setSubTypes(context);
        else
          phone.setContexts(context);
        phone.setNumber(phonenumbers.at(i));
        contact.saveDetail(&phone);
    }

    QContactFavorite fav = contact.detail<QContactFavorite>();
    fav.setFavorite(favorite);
    contact.saveDetail(&fav);


    //Remove all existing IM accounts; then add all IM accounts from edit page
    foreach (QContactDetail detail, contact.details<QContactOnlineAccount>()) {
        if (!contact.removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove im account";
    }

    for (int i =0; i < accounturis.size(); i++){
        QContactOnlineAccount account;
        account.setAccountUri(accounturis.at(i));
        account.setServiceProvider(serviceproviders.at(i));

        contact.saveDetail(&account);
    }

    //Remove all existing email addresses; then add all email addresses from edit page
    foreach (QContactDetail detail, contact.details<QContactEmailAddress>()) {
        if (!contact.removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove email address";
    }

    for (int i =0; i < emailaddys.size(); i++){
        QContactEmailAddress email;
        email.setEmailAddress(emailaddys.at(i));
        email.setContexts(emailcontexts.at(i));
        contact.saveDetail(&email);
    }

    //Remove all existing addresses; then add all addresses from edit page
    foreach (QContactDetail detail, contact.details<QContactAddress>()) {
        if (!contact.removeDetail(&detail))
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
        contact.saveDetail(&address);
    }

    //Remove all existing URLs; then add all URLs from edit page
    foreach (QContactDetail detail, contact.details<QContactUrl>()) {
        if (!contact.removeDetail(&detail))
            qWarning() << "[PeopleModel] failed to remove addresses";
    }

    for(int i =0; i < urllinks.size(); i++){
        QContactUrl url;
        url.setUrl(urllinks.at(i));
        url.setContexts(urlcontexts.at(i));
        contact.saveDetail(&url);
    }

    QContactBirthday birthdate = contact.detail<QContactBirthday>();
    if (birthdate.date() != birthday) {
        birthdate.setDate(birthday);
        contact.saveDetail(&birthdate);
    }

    QContactNote note = contact.detail<QContactNote>();
    if (note.note() != notetext) {
        note.setNote(notetext);
        contact.saveDetail(&note);
    }

    queueContactSave(contact);
}

void PeopleModel::setCurrentUuid(const QString& uuid)
{
    priv->currentGuid.setGuid(uuid);
    qDebug() << "sets current uuid to " << uuid << "test " << priv->currentGuid.guid();
}

void PeopleModel::toggleFavorite(const QString& uuid)
{
    QContactLocalId id = priv->uuidToId[uuid];
    QContact &contact = priv->idToContact[id];

 if (contact.isEmpty())
        return;

    QContactFavorite fav = contact.detail<QContactFavorite>();
    fav.setFavorite(!fav.isFavorite());

    if (!contact.saveDetail(&fav)) {
        qWarning() << Q_FUNC_INFO << "failed to save favorite";
        return;
    }

    queueContactSave(contact);
}

void PeopleModel::exportContact(QString uuid,  QString filename){
    QVersitContactExporter exporter;
    QList<QContact> contacts;
    QList<QVersitDocument> documents;

    QContactLocalId id = priv->uuidToId[uuid];
    QContact &person = priv->idToContact[id];

    if(person.isEmpty()){
        qWarning() << "[PeopleModel] no contact found to export with uuid " + uuid;
        return;
    }

    contacts.append(person);
    exporter.exportContacts(contacts);
    documents = exporter.documents();

    QFile * file = new QFile(filename);
    if(file->open(QIODevice::ReadWrite)){
        priv->writer.setDevice(file);
        priv->writer.startWriting(documents);
    }else{
        qWarning() << "[PeopleModel] vCard export failed for contact with uuid " + uuid;
    }
}

void PeopleModel::vCardFinished(QVersitWriter::State state){
    if(state == QVersitWriter::FinishedState || state == QVersitWriter::CanceledState){
        delete priv->writer.device();
        priv->writer.setDevice(0);
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
    priv->sortOrder.clear();
    priv->sortOrder.append(sort);
}

int PeopleModel::getSortingRole(){
    if ((priv->sortOrder.isEmpty()) ||
       (priv->sortOrder.at(0).detailFieldName() == QContactName::FieldFirstName))
        return PeopleModel::FirstNameRole;
    else if (priv->sortOrder.at(0).detailFieldName() == QContactName::FieldLastName)
        return PeopleModel::LastNameRole;

    return PeopleModel::FirstNameRole;
}

void PeopleModel::setFilter(int role, bool dataResetNeeded){
    switch(role){
    case FavoritesFilter:
    {
        QContactDetailFilter favFilter;
        favFilter.setDetailDefinitionName(QContactFavorite::DefinitionName, QContactFavorite::FieldFavorite);
        favFilter.setValue(true);
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

        qDebug() << "[PeopleModel] searchContact " + text;
        QList<QContactFilter> filterList;
        QContactUnionFilter unionFilter;

        QContactDetailFilter nameFilter;
        nameFilter.setDetailDefinitionName(QContactName::DefinitionName, QContactName::FieldFirstName);
        nameFilter.setValue(text);
        nameFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(nameFilter);

        QContactDetailFilter lastFilter;
        lastFilter.setDetailDefinitionName(QContactName::DefinitionName, QContactName::FieldLastName);
        lastFilter.setValue(text);
        lastFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(lastFilter);

        QContactDetailFilter companyFilter;
        companyFilter.setDetailDefinitionName(QContactOrganization::DefinitionName, QContactOrganization::FieldName);
        companyFilter.setValue(text);
        companyFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(companyFilter);

        //removes (). checks last 7 numbers
        QContactDetailFilter phoneNumFilter;
        phoneNumFilter.setDetailDefinitionName(QContactPhoneNumber::DefinitionName, QContactPhoneNumber::FieldNumber);
        phoneNumFilter.setValue(text);
        phoneNumFilter.setMatchFlags(QContactFilter::MatchPhoneNumber);
        filterList.append(phoneNumFilter);

        //checks for contains only
        QContactDetailFilter phoneFilter;
        phoneFilter.setDetailDefinitionName(QContactPhoneNumber::DefinitionName, QContactPhoneNumber::FieldNumber);
        phoneFilter.setValue(text);
        phoneFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(phoneFilter);

        QContactDetailFilter emailFilter;
        emailFilter.setDetailDefinitionName(QContactEmailAddress::DefinitionName, QContactEmailAddress::FieldEmailAddress);
        emailFilter.setValue(text);
        emailFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(emailFilter);

        QContactDetailFilter addressFilter;
        addressFilter.setDetailDefinitionName(QContactAddress::DefinitionName, QContactAddress::FieldStreet);
        addressFilter.setValue(text);
        addressFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(addressFilter);

        QContactDetailFilter countryFilter;
        countryFilter.setDetailDefinitionName(QContactAddress::DefinitionName, QContactAddress::FieldCountry);
        countryFilter.setValue(text);
        countryFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(countryFilter);

        QContactDetailFilter localeFilter;
        localeFilter.setDetailDefinitionName(QContactAddress::DefinitionName, QContactAddress::FieldLocality);
        localeFilter.setValue(text);
        localeFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(localeFilter);

        QContactDetailFilter zipFilter;
        zipFilter.setDetailDefinitionName(QContactAddress::DefinitionName, QContactAddress::FieldPostcode);
        zipFilter.setValue(text);
        zipFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(zipFilter);

        QContactDetailFilter regionFilter;
        regionFilter.setDetailDefinitionName(QContactAddress::DefinitionName, QContactAddress::FieldRegion);
        regionFilter.setValue(text);
        regionFilter.setMatchFlags(QContactFilter::MatchContains);
        filterList.append(regionFilter);

        QContactDetailFilter urlFilter;
        urlFilter.setDetailDefinitionName(QContactUrl::DefinitionName);
        urlFilter.setValue(text);
        urlFilter.setMatchFlags(QContactFilter::MatchExactly);
        filterList.append(urlFilter);

        unionFilter.setFilters(filterList);
        priv->currentFilter = unionFilter;
        dataReset();
}

void PeopleModel::clearSearch(){
     setFilter(AllFilter);
}


/*! Queues a \a contact for asynchronous saving after calls
 * to QContact::saveDetail(), etc.
 */
void PeopleModel::queueContactSave(QContact contactToSave)
{
    priv->contactsPendingSave.append(contactToSave);

    if (contactToSave.localId()) {
        // we save the contact to our model as well; if it existed previously.
        // this covers our QContactManager being slow at informing us about saves
        // with the slight problem that our data may be a little inconsistent if
        // the QContactManager decides to save differently from what we asked
        // it to - but this is ok, because the save request finishing will fix that.
        int rowId =priv->idToIndex.value(contactToSave.localId());
        qDebug() << Q_FUNC_INFO << "Faked save for " << contactToSave.localId() << " row " << rowId;
       priv->idToContact[contactToSave.localId()] = contactToSave;
        emit dataChanged(index(rowId, 0), index(rowId, 0));
    }

    // TODO: in a more complicated implementation, we'd only save
    // on a timer instead of flushing all the time
    savePendingContacts();
}

void PeopleModel::savePendingContacts()
{
    QContactSaveRequest *saveRequest = new QContactSaveRequest(this);
    connect(saveRequest,
            SIGNAL(stateChanged(QContactAbstractRequest::State)),
            SLOT(onSaveStateChanged(QContactAbstractRequest::State)));
    saveRequest->setContacts(priv->contactsPendingSave);
    saveRequest->setManager(priv->manager);

    foreach (const QContact &contact, priv->contactsPendingSave)
        qDebug() << Q_FUNC_INFO << "Saving " << contact.id();

    if (!saveRequest->start()) {
        qWarning() << Q_FUNC_INFO << "Save request failed: " << saveRequest->error();
        delete saveRequest;
    }

    priv->contactsPendingSave.clear();
}

void PeopleModel::onSaveStateChanged(QContactAbstractRequest::State requestState)
{
    QContactSaveRequest *saveRequest = checkRequest<QContactSaveRequest>(sender(), requestState);
    if (!saveRequest)
        return;

    QList<QContact> contactList = saveRequest->contacts();

    foreach (const QContact &new_contact, contactList) {
        qDebug() << Q_FUNC_INFO << "Successfully saved " << new_contact.id();

        // make sure data shown to user matches what is
        // really in the database
        QContactLocalId id = new_contact.localId();
       priv->idToContact[id] = new_contact;
    }

    saveRequest->deleteLater();
}

/*! Removes a given \a contactId asynchronously.
 */
void PeopleModel::removeContact(QContactLocalId contactId)
{
    QContactRemoveRequest *removeRequest = new QContactRemoveRequest(this);
    removeRequest->setManager(priv->manager);
    connect(removeRequest,
            SIGNAL(stateChanged(QContactAbstractRequest::State)),
            SLOT(onRemoveStateChanged(QContactAbstractRequest::State)));
    removeRequest->setContactId(contactId);
    qDebug() << Q_FUNC_INFO << "Removing " << contactId;

    if (!removeRequest->start()) {
        qWarning() << Q_FUNC_INFO << "Remove request failed";
        delete removeRequest;
    }
}

void PeopleModel::onRemoveStateChanged(QContactAbstractRequest::State requestState)
{
    QContactRemoveRequest *removeRequest = checkRequest<QContactRemoveRequest>(sender(), requestState);
    if (!removeRequest)
        return;

    qDebug() << Q_FUNC_INFO << "Removed" << removeRequest->contactIds();
    removeRequest->deleteLater();
}

// For Me card support
void PeopleModel::onMeFetchRequestStateChanged(QContactAbstractRequest::State requestState)
{
    QContactFetchByIdRequest *fetchRequest = checkRequest<QContactFetchByIdRequest>(sender(), requestState);
    if (!fetchRequest)
        return;

    // Check if we need to save Me contact again
    if (fetchRequest->contacts().size() == 0) {
        qDebug() << Q_FUNC_INFO << "No Me contact, saving one";
        createMeCard();
    } else {
        QContact &me = fetchRequest->contacts().first();
        QContactName name = me.detail<QContactName>();
        if (name.firstName().isEmpty()) {
            qDebug() << Q_FUNC_INFO << "Empty first name for Me contact; updating it";
            createMeCard(me);
        }
    }

    fetchRequest->deleteLater();
}

bool PeopleModel::isSelfContact(const QContactLocalId id) const
{
    if (!priv->manager->hasFeature(QContactManager::SelfContact, QContactType::TypeContact))
        return false;

    if (id == priv->manager->selfContactId())
        return true;
    return false;
}

bool PeopleModel::isSelfContact(const QUuid id) const
{
    return isSelfContact(priv->uuidToId[id]);
}

bool PeopleModel::isSelfContact(const QString id) const
{
    QUuid uuid(id);
    return isSelfContact(priv->uuidToId[uuid]);
}

void PeopleModel::fetchOnlineOnly(const QVariantList &stringids)
{
    QList<QContactLocalId> ids;
    for(int iter = 0; iter < stringids.count(); iter++)
        ids.append(qvariant_cast<QContactLocalId>(stringids.at(iter)));

    QContactLocalIdFilter contactFilter;
    if (ids.count() >= 1) {
        contactFilter.setIds(ids);
        priv->currentFilter = contactFilter;
        dataReset();
    }
}
