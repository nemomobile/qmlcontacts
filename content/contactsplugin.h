/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef __contactsplugin_h
#define __contactsplugin_h

#include <QObject>

#include <feedplugin.h>

class McaServiceModel;
class McaFeedModel;
class ContactsServiceModel;

class ContactsPlugin: public QObject, public McaFeedPlugin
{
    Q_OBJECT
    Q_INTERFACES(McaFeedPlugin)

public:
    explicit ContactsPlugin(QObject *parent = NULL);
    ~ContactsPlugin();

    QAbstractItemModel *serviceModel();
    QAbstractItemModel *createFeedModel(const QString& service);
    McaSearchableFeed *createSearchModel(const QString& service,
                                         const QString& searchText);

private:
    ContactsServiceModel *m_serviceModel;
};

#endif  // __contactsplugin_h
