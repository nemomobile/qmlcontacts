/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QtDeclarative/QDeclarativeEngine>
#include <QDeclarativeContext>
#include "contacts.h"
#include "peoplemodel.h"
#include "proxymodel.h"
#include "settingsdatastore.h"

void contacts::registerTypes(const char *uri)
{
    qmlRegisterType<PeopleModel>(uri, 0, 0, "PeopleModel");
    qmlRegisterType<ProxyModel>(uri, 0, 0, "ProxyModel");
}

void contacts::initializeEngine(QDeclarativeEngine *engine, const char *uri)
{
    qDebug() << "MeeGo Contacts initializeEngine" << uri;
    Q_ASSERT(engine);

    mRootContext = engine->rootContext();
    Q_ASSERT(mRootContext);

    mRootContext->setContextProperty(QString::fromLatin1("settingsDataStore"),
                                      SettingsDataStore::self());
}

Q_EXPORT_PLUGIN(contacts);
