/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class SettingsDataStore: public QObject
{
    Q_OBJECT

public:
    explicit SettingsDataStore(QObject *parent = 0);

    static SettingsDataStore *self();
    void setDefaults();
    QString getSettingsStoreFileName();
    void syncDataStore();

    Q_INVOKABLE int getSortOrder() const;
    Q_INVOKABLE void setSortOrder(int orderType);
    Q_INVOKABLE int getDisplayOrder() const;
    Q_INVOKABLE void setDisplayOrder(int orderType);
    int getSavedCountry() const;
    void setCountry(int country);

Q_SIGNALS:
    void sortOrderChanged(int orderType);
    void displayOrderChanged(int orderType);

private:
    QSettings mSettings;
    static SettingsDataStore *mSelf;
};

#endif // SETTINGS_H
