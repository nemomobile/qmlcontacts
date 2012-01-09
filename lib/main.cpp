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
#include <QFile>
#include <QDebug>

#include <seasidepeoplemodel.h>
#include <seasideproxymodel.h>
#include <seasideperson.h>
#include <localeutils_p.h> // XXX: this needs to not be public private, fix it

int main(int argc, char **argv)
{
    QApplication a(argc, argv);

    // TODO: this should probably be done in libseaside somehow
    qmlRegisterType<SeasidePeopleModel>("MeeGo.App.Contacts", 0, 1, "PeopleModel");
    qmlRegisterType<SeasideProxyModel>("MeeGo.App.Contacts", 0, 1, "ProxyModel");
    qmlRegisterType<SeasidePerson>("MeeGo.App.Contacts", 0, 1, "Person");

    QDeclarativeView view;

    QDeclarativeContext *rootContext = view.engine()->rootContext();
    Q_ASSERT(rootContext);

    rootContext->setContextProperty(QString::fromLatin1("localeUtils"),
                                    LocaleUtils::self());

    view.setWindowTitle(QObject::tr("Contacts"));

    if (QFile::exists("main.qml"))
        view.setSource(QUrl::fromLocalFile("main.qml"));
    else
        view.setSource(QUrl::fromLocalFile("/usr/share/qmlcontacts/main.qml"));

    if (QCoreApplication::arguments().contains("-fullscreen")) {
        qDebug() << Q_FUNC_INFO << "Starting in fullscreen mode";
        view.showFullScreen();
    } else {
        qDebug() << Q_FUNC_INFO << "Starting in windowed mode";
        view.show();
    }

    return a.exec();
}

