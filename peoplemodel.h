/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef PEOPLEMODEL_H
#define PEOPLEMODEL_H

#include <QVersitReader>
#include <QVersitWriter>
#include <QProcess>
#include <QAbstractListModel>

#include <QUuid>
//#include <QContactManager>
#include <QContactManagerEngine>
//#include "telepathymanager.h"

using namespace QtMobility;

class PeopleModelPriv;

class PeopleModel: public QAbstractListModel
{
    Q_OBJECT
    // Q_PROPERTY(QString uuid READ currentUuid WRITE setCurrentUuid)
    Q_ENUMS(PeopleRoles)
    Q_ENUMS(FilterRoles)

public:
    PeopleModel(QObject *parent = 0);
    ~PeopleModel();

    enum FilterRoles{
        AllFilter = 0,
        FavoritesFilter,
        OnlineFilter,
        ContactFilter
    };

    enum PeopleRoles{
        ContactRole = Qt::UserRole + 500,
        FirstNameRole, //533
        LastNameRole,
        CompanyNameRole,
        FavoriteRole,
        UuidRole,
        PresenceRole,
        AvatarRole,
        ThumbnailRole,
        IsSelfRole,
        BirthdayRole,
        AnniversaryRole,
        OnlineAccountUriRole,
        OnlineServiceProviderRole,
        EmailAddressRole,
        EmailContextRole,
        PhoneNumberRole,
        PhoneContextRole,
        AddressRole,
        AddressStreetRole,
        AddressLocaleRole,
        AddressRegionRole,
        AddressCountryRole,
        AddressPostcodeRole,
        AddressContextRole,
        WebUrlRole,
        WebContextRole,
        NotesRole,
        FirstCharacterRole
    };

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;
    Q_INVOKABLE virtual QVariant data(const QModelIndex & index, int role) const;
    Q_INVOKABLE QVariant data(const int row, int role) const;

    Q_INVOKABLE bool createPersonModel(QString avatarUrl, QString thumbUrl, QString firstName, QString lastName,
                                       QString companyname, QStringList phonenumbers, QStringList phonecontexts,
                                       QString favorite, QStringList accounturis, QStringList serviceproviders,
                                       QStringList emailaddys, QStringList emailcontexts, QStringList street,
                                       QStringList city, QStringList state, QStringList zip, QStringList country,
                                       QStringList addresscontexts, QStringList urllinks, QStringList urlcontexts,
                                       QDate birthday, QString notetext);

    Q_INVOKABLE void deletePerson(QString uuid);

    Q_INVOKABLE void editPersonModel(QString contactId, QString avatarUrl, QString firstName, QString lastName, QString companyname,
                                     QStringList phonenumbers, QStringList phonecontexts, QString favorite,
                                     QStringList accounturis, QStringList serviceproviders, QStringList emailaddys,
                                     QStringList emailcontexts, QStringList street, QStringList city, QStringList state,
                                     QStringList zip, QStringList country, QStringList addresscontexts,
                                     QStringList urllinks,  QStringList urlcontexts, QDate birthday, QString notetext);

    Q_INVOKABLE QMap<QString, QString> availableAccounts() const;
    Q_INVOKABLE QStringList availableContacts(QString accountId) const;

    Q_INVOKABLE void launch (QString cmd) {
        QProcess::startDetached (cmd);
    }

    Q_INVOKABLE void exportContact(QString uuid, QString filename);
    Q_INVOKABLE void sort(int flags);

    Q_INVOKABLE void setCurrentUuid(const QString& uuid);
    QString currentUuid();

    void setAvatar(const QString& path);
    QString avatar();

    QString firstname();
    QString lastname();

    Q_INVOKABLE void setFavorite(const QString& uuid, bool favorite);
    Q_INVOKABLE void toggleFavorite(const QString& uuid);
    void setCompany(const QUuid& uuid, QString company);
    void setisSelf(const QUuid& uuid, bool self);
    Q_INVOKABLE void setSorting(int role);
    Q_INVOKABLE void setFilter(int role);
    Q_INVOKABLE void searchContacts(const QString text);
    Q_INVOKABLE void clearSearch();

public slots:
    void createMeCard(QContact &contact);

signals:
    void avatarChanged(const QString url);
    void resetModel();

protected:
    void fixIndexMap();
    void addContacts(const QList<QContact> contactsList, int size);

protected slots:
    void contactsAdded(const QList<QContactLocalId>& contactIds);
    void contactsChanged(const QList<QContactLocalId>& contactIds);
    void contactsRemoved(const QList<QContactLocalId>& contactIds);
    void dataReset();

    void fetchContactsRequest();
    void vCardFinished(QVersitWriter::State state);
    void saveContactsRequest();
    void removeContactsRequest();

private:
    PeopleModelPriv *priv;

    QContactFetchRequest fetchAddedContacts;
    QContactFetchRequest fetchAllContacts;
    QContactFetchRequest fetchChangedContacts;
    QContactFetchRequest fetchMeCard;

    QContactSaveRequest addMeCard;
    QContactSaveRequest updateMeCard;
    QContactSaveRequest updateContact;
    QContactSaveRequest updateAvatar;
    QContactSaveRequest updateFavorite;

    QContactRemoveRequest removeContact;
    QList<QContactSortOrder> sortOrder;
   // TelepathyManager tpManager;
};

#endif // PEOPLEMODEL_H
