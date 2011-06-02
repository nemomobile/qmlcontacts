/*
 * libseaside - Library that provides an interface to the Contacts application
 * Copyright (c) 2011, Robin Burchell.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 */

#ifndef PEOPLEMODEL_P_H
#define PEOPLEMODEL_P_H

#include <QObject>
#include <QVector>
#include <QStringList>
#include <QSettings>
#include <QContactGuid>

#include "peoplemodel.h"
#include "localeutils.h"

class PeopleModelPriv : public QObject
{
    Q_OBJECT
public:

    QContactManager *manager;
    QContactFetchHint currentFetchHint;
    QList<QContactSortOrder> sortOrder;
    QContactFilter currentFilter;
    QList<QContactLocalId> contactIds;
    QMap<QContactLocalId, int> idToIndex;
    QMap<QContactLocalId, QContact> idToContact;
    QMap<QUuid, QContactLocalId> uuidToId;
    QMap<QContactLocalId, QUuid> idToUuid;

    QVersitWriter writer;
    QVersitReader reader;

    QVector<QStringList> data;
    QStringList headers;
    QSettings *settings;
    LocaleUtils *localeHelper;
    QContactGuid currentGuid;

    explicit PeopleModelPriv(PeopleModel* /*parent*/){}

    virtual ~PeopleModelPriv()
    {
        delete manager;
        delete settings;
    }

    QList<QContact> contactsPendingSave;

private:
    Q_DISABLE_COPY(PeopleModelPriv);
};

#endif // PEOPLEMODEL_P_H
