/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef CONTACTSS_H
#define CONTACTS_H

#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeExtensionPlugin>
#include <QtDeclarative/QDeclarativeContext>
#include "settingsdatastore.h"
#include "localeutils.h"

class contacts : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:
    void registerTypes(const char *uri);
    void initializeEngine(QDeclarativeEngine *engine, const char *uri);

private:
    QDeclarativeContext *mRootContext;
    SettingsDataStore *mSettingsDataStore;
    LocaleUtils *mLocaleUtils;
};

#endif // CONTACTS_H
