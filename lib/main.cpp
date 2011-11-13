/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QtDeclarative/qdeclarative.h>
#include <QDeclarativeEngine>
#include <QApplication>
#include <QDeclarativeContext>
#include <QDeclarativeView>
#include "peoplemodel.h"
#include "proxymodel.h"
#include "localeutils.h"
#include "settingsdatastore.h"

int main(int argc, char **argv)
{
    QApplication a(argc, argv);

    qmlRegisterType<PeopleModel>("MeeGo.App.Contacts", 0, 1, "PeopleModel");
    qmlRegisterType<ProxyModel>("MeeGo.App.Contacts", 0, 1, "ProxyModel");

    QDeclarativeView view;

    QDeclarativeContext *rootContext = view.engine()->rootContext();
    Q_ASSERT(rootContext);

    rootContext->setContextProperty(QString::fromLatin1("settingsDataStore"),
                                     SettingsDataStore::self());
    rootContext->setContextProperty(QString::fromLatin1("localeUtils"),
                                     LocaleUtils::self());

    view.setSource(QUrl::fromLocalFile("main.qml"));

    view.show();

    return a.exec();
}

