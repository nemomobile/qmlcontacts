/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "contacts.h"
#include "peoplemodel.h"
#include "proxymodel.h"

void contacts::registerTypes(const char *uri)
{
    qmlRegisterType<PeopleModel>(uri, 0, 0, "PeopleModel");
    qmlRegisterType<ProxyModel>(uri, 0, 0, "ProxyModel");
}

Q_EXPORT_PLUGIN(contacts);
