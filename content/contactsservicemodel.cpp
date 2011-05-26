/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>

#include <actions.h>

#include "contactsservicemodel.h"

ContactsServiceModel::ContactsServiceModel(QObject *parent):
        McaServiceModel(parent)
{
}

ContactsServiceModel::~ContactsServiceModel()
{
}

//
// public member functions
//

int ContactsServiceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 1;
}

QVariant ContactsServiceModel::data(const QModelIndex &index, int role) const
{
    // invalid if not the one true contacts
    if (index.row() != 0)
        return QVariant();

    qDebug() << "ContactsServiceModel::data role=" << role;
    switch (role) {
    case CommonDisplayNameRole:
        // the display name for contacts service content
        return tr("Contacts");

    case RequiredCategoryRole:
        // i18n ok
        return "contacts";

    case RequiredNameRole:
        // i18n ok
        return "contacts";

    case CommonConfigErrorRole:
        // assuming we will only show properly configured accounts for now
        return false;

    case CommonActionsRole:
        // until we start sending "true" for CommonConfigErrorRole, not needed
    default:
        qWarning() << "Unhandled data role requested!";
    case CommonIconUrlRole:
        // expect app to have no icon header for contacts, or supply it itself
        return QVariant();
    }
}
