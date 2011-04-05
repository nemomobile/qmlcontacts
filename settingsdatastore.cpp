/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "settingsdatastore.h"
#include "proxymodel.h"

SettingsDataStore *SettingsDataStore::mSelf = 0;

SettingsDataStore::SettingsDataStore(QObject *parent) :
    QObject(parent), mSettings("MeeGo", "MeeGoContacts")
{
}

SettingsDataStore *SettingsDataStore::self()
{
    if (!mSelf) {
        mSelf = new SettingsDataStore();
    }

    return mSelf;
}

QString SettingsDataStore::getSettingsStoreFileName()
{
    return mSettings.fileName();
}

void SettingsDataStore::syncDataStore()
{
    mSettings.sync();
}

int SettingsDataStore::getSortOrder() const
{
    return mSettings.value("SortOrder", ProxyModel::SortFirstName).toInt();
}

void SettingsDataStore::setSortOrder(int orderType)
{
    mSettings.setValue("SortOrder", orderType);
    emit sortOrderChanged(orderType);
}

int SettingsDataStore::getDisplayOrder() const
{
    return mSettings.value("DisplayOrder", ProxyModel::SortFirstName).toInt();
}

void SettingsDataStore::setDisplayOrder(int orderType)
{
    mSettings.setValue("DisplayOrder", orderType);
    emit displayOrderChanged(orderType);
}

