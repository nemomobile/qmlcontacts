/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>
#include <QLocale>
#include <unicode/unistr.h>
#include <unicode/locid.h>
#include <unicode/coll.h>
#include <unicode/uchar.h>

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
    else if (lang == "ko_KO")
        fieldOrder << "country" << "region" << "locale" << "street" << "zip";
    else
        fieldOrder << "street" << "locale" << "region" << "zip" << "country";

    return fieldOrder;
}

bool LocaleUtils::checkForAlphaChar(QString str)
{
    const ushort *strShort = str.utf16();
    UnicodeString uniStr = UnicodeString(static_cast<const UChar *>(strShort));

    //REVISIT: Might need to use a locale aware version of char32At()
    return u_hasBinaryProperty(uniStr.char32At(0), UCHAR_ALPHABETIC);
}

bool LocaleUtils::isLessThan(QString lStr, QString rStr)
{
    //Convert strings to UnicodeStrings
    const ushort *lShort = lStr.utf16();
    UnicodeString lUniStr = UnicodeString(static_cast<const UChar *>(lShort));
    const ushort *rShort = rStr.utf16();
    UnicodeString rUniStr = UnicodeString(static_cast<const UChar *>(rShort));

    //Get the locale in a ICU supported format
    QString nameStr = QLocale::system().name();
    const char *name = nameStr.toLatin1().constData();
    Locale localeName = Locale(name);

    UErrorCode status = U_ZERO_ERROR;
    Collator *coll = Collator::createInstance(localeName, status);
    if (!U_SUCCESS(status)) {
        //Unable to get collator, use fall back
        return QString::localeAwareCompare(lStr, rStr) < 0;
    }

    Collator::EComparisonResult res = coll->compare(lUniStr, rUniStr);
    delete coll;

    if (res == Collator::LESS)
        return true;

    return false;
}

QString LocaleUtils::getBinForString(QString str)
{
    //REVISIT: Might need to use a locale aware version of toUpper() and at()
    if (checkForAlphaChar(str))
        return str.at(0).toUpper();

    return QString(tr("#"));
}

