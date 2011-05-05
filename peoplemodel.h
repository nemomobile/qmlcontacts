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
#include <QContactManagerEngine>

QTM_USE_NAMESPACE
class PeopleModelPriv;

class PeopleModel: public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(PeopleRoles)
    Q_ENUMS(FilterRoles)

public:
    PeopleModel(QObject *parent = 0);
    virtual ~PeopleModel();

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

    //From QAbstractListModel
    virtual int rowCount(const QModelIndex&) const;
    virtual int columnCount(const QModelIndex& parent) const;
    virtual QVariant data(const QModelIndex&, int) const;

    void queueContactSave(QContact contact);
    void removeContact(QContactLocalId contactId);

    //QML API
    Q_INVOKABLE QVariant data(const int row, int role) const;

    Q_INVOKABLE bool createPersonModel(QString avatarUrl, QString thumbUrl, QString firstName, QString lastName,
                                       QString companyname, QStringList phonenumbers, QStringList phonecontexts,
                                       bool favorite, QStringList accounturis, QStringList serviceproviders,
                                       QStringList emailaddys, QStringList emailcontexts, QStringList street,
                                       QStringList city, QStringList state, QStringList zip, QStringList country,
                                       QStringList addresscontexts, QStringList urllinks, QStringList urlcontexts,
                                       QDate birthday, QString notetext);

    Q_INVOKABLE void deletePerson(const QString& uuid);

    Q_INVOKABLE void editPersonModel(QString contactId, QString avatarUrl, QString firstName, QString lastName, QString companyname,
                                     QStringList phonenumbers, QStringList phonecontexts, bool favorite,
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

    Q_INVOKABLE void toggleFavorite(const QString& uuid);
    bool isSelfContact(const QContactLocalId id);
    bool isSelfContact(const QUuid id);
    Q_INVOKABLE void setSorting(int role);
    Q_INVOKABLE void setFilter(int role, bool dataResetNeeded = true);
    Q_INVOKABLE int getSortingRole();
    Q_INVOKABLE void searchContacts(const QString text);
    Q_INVOKABLE void clearSearch();

protected:
    void fixIndexMap();
    void addContacts(const QList<QContact> contactsList, int size);

private slots:
    void onSaveStateChanged(QContactAbstractRequest::State requestState);
    void onRemoveStateChanged(QContactAbstractRequest::State requestState);
    void onDataResetFetchChanged(QContactAbstractRequest::State requestState);
    void onAddedFetchChanged(QContactAbstractRequest::State requestState);
    void onChangedFetchChanged(QContactAbstractRequest::State requestState);
    void onMeFetchRequestStateChanged(QContactAbstractRequest::State requestState);

    void contactsAdded(const QList<QContactLocalId>& contactIds);
    void contactsChanged(const QList<QContactLocalId>& contactIds);
    void contactsRemoved(const QList<QContactLocalId>& contactIds);
    void dataReset();
    void savePendingContacts();
    void createMeCard();
    void vCardFinished(QVersitWriter::State state);

private:
    PeopleModelPriv *priv;
    Q_DISABLE_COPY(PeopleModel);
};

#endif // PEOPLEMODEL_H
