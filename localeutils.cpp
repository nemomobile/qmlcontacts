/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QLocale>

#include "localeutils.h"

LocaleUtils *LocaleUtils::mSelf = 0;

LocaleUtils::LocaleUtils(QObject *parent) :
    QObject(parent)
{
}

LocaleUtils *LocaleUtils::self()
{
    if (!mSelf) {
        mSelf = new LocaleUtils();
    }

    return mSelf;
}

QString LocaleUtils::getLanguage() const
{
    return QLocale::system().name();
}

QStringList LocaleUtils::getAddressFieldOrder() const
{
    QStringList fieldOrder;
    QString lang = getLanguage();

    if ((lang == "zh_TW") || (lang == "zh_CN"))
        fieldOrder << "country" << "region" << "locale" << "street" << "zip";
    else if (lang == "ja_JA")
        fieldOrder << "country" << "zip" << "region" << "locale" << "street";
    else
        fieldOrder << "street" << "locale" << "region" << "zip" << "country";

    return fieldOrder;
}

