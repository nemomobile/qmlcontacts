/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "settingsdatastore.h"
#include "peoplemodel.h"
#include "localeutils.h"

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

    mSelf->setDefaults();

    return mSelf;
}

void SettingsDataStore::setDefaults()
{
    LocaleUtils localeUtils;

    //Save the country value the first time through
    if (getSavedCountry() == QLocale::AnyCountry)
        setCountry(localeUtils.getCountry());

    //We don't want to set the country defaults each time the
    //application loads - just when the country has changed
    //Check the current country against the stored value
    if (getSavedCountry() != localeUtils.getCountry()) {
        setSortOrder(localeUtils.defaultSortVal());
        setDisplayOrder(localeUtils.defaultDisplayVal());
        setCountry(localeUtils.getCountry());
    }
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
    return mSettings.value("SortOrder", PeopleModel::FirstNameRole).toInt();
}

void SettingsDataStore::setSortOrder(int orderType)
{
    mSettings.setValue("SortOrder", orderType);
    emit sortOrderChanged(orderType);
}

int SettingsDataStore::getDisplayOrder() const
{
    return mSettings.value("DisplayOrder", PeopleModel::FirstNameRole).toInt();
}

void SettingsDataStore::setDisplayOrder(int orderType)
{
    mSettings.setValue("DisplayOrder", orderType);
    emit displayOrderChanged(orderType);
}

int SettingsDataStore::getSavedCountry() const
{
    return mSettings.value("Country", QLocale::AnyCountry).toInt();
}

void SettingsDataStore::setCountry(int country)
{
    mSettings.setValue("Country", country);
}

