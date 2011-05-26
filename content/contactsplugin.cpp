/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>

#include <QtPlugin>

#include "contactsplugin.h"
#include "contactsservicemodel.h"
#include "contactsfeedmodel.h"

ContactsPlugin::ContactsPlugin(QObject *parent): QObject(parent), McaFeedPlugin()
{
    qDebug("ContactsPlugin constructor");
    m_serviceModel = new ContactsServiceModel(this);
}

ContactsPlugin::~ContactsPlugin()
{
}

QAbstractItemModel *ContactsPlugin::serviceModel()
{
    return m_serviceModel;
}

QAbstractItemModel *ContactsPlugin::createFeedModel(const QString& service)
{
    qDebug() << "ContactsPlugin::createFeedModel: " << service;
    return NULL;
}

McaSearchableFeed *ContactsPlugin::createSearchModel(const QString& service,
                                                     const QString& searchText)
{
    // service ignored currently because there is only one contacts
    qDebug() << "ContactsPlugin::createSearchModel: " << service << searchText;
    return new ContactsFeedModel(searchText, this);
}

Q_EXPORT_PLUGIN2(contactsplugin, ContactsPlugin)
