/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>
#include <string.h>
#include <unicode/unistr.h>
#include <unicode/locid.h>
#include <unicode/coll.h>
#include <unicode/uchar.h>
#include <unicode/ulocdata.h>
#include <unicode/ustring.h>

#include "localeutils.h"

LocaleUtils *LocaleUtils::mSelf = 0;

LocaleUtils::LocaleUtils(QObject *parent) :
    QObject(parent)
{
    int collType = LocaleUtils::Default;
    if (getCountry() == QLocale::Germany)
        collType = LocaleUtils::PhoneBook;

    initCollator(collType);
}

LocaleUtils::~LocaleUtils()
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

QLocale::Country LocaleUtils::getCountry() const
{
    return QLocale::system().country();
}

QStringList LocaleUtils::getAddressFieldOrder() const
{
    QStringList fieldOrder;
    QLocale::Country country = getCountry();

    if ((country == QLocale::China) || (country == QLocale::Taiwan))
        fieldOrder << "country" << "region" << "locale" << "street" << "zip";
    else if (country == QLocale::Japan)
        fieldOrder << "country" << "zip" << "region" << "locale" << "street";
    else if ((country == QLocale::DemocraticRepublicOfKorea) ||
             (country == QLocale::RepublicOfKorea))
        fieldOrder << "country" << "region" << "locale" << "street" << "zip";
    else
        fieldOrder << "street" << "locale" << "region" << "zip" << "country";

    return fieldOrder;
}

bool LocaleUtils::needPronounciationFields() const {
    QStringList fieldOrder;
    QLocale::Country country = getCountry();

    if (country == QLocale::Japan)
        return true;
    return false;
}

bool LocaleUtils::checkForAlphaChar(QString str)
{
    const ushort *strShort = str.utf16();
    UnicodeString uniStr = UnicodeString(static_cast<const UChar *>(strShort));

    //REVISIT: Might need to use a locale aware version of char32At()
    return u_hasBinaryProperty(uniStr.char32At(0), UCHAR_ALPHABETIC);
}

bool LocaleUtils::initCollator(int collType, QString locale)
{
    //Get the locale in a ICU supported format
    if (locale == "")
        locale = getLanguage();
   
    switch (collType) {
        case PhoneBook:
            locale += "@collation=phonebook";
            break;
        case Pinyin:
            locale += "@collation=pinyin";
            break;
        case Traditional:
            locale += "@collation=traditional";
            break;
        case Stroke:
            locale += "@collation=stroke";
            break;
        case Direct:
            locale += "@collation=direct";
            break;
        default:
            locale += "@collation=default";
    }

    const char *name = locale.toLatin1().constData();
    Locale localeName = Locale(name);

    UErrorCode status = U_ZERO_ERROR;
    mColl = (RuleBasedCollator *)Collator::createInstance(localeName, status);
    if (!U_SUCCESS(status))
        return false;

    QLocale::Country country = getCountry();
    if ((country == QLocale::DemocraticRepublicOfKorea) ||
        (country == QLocale::RepublicOfKorea)) {

        //ASCII characters should be sorted after KOR characters
        UnicodeString rules = mColl->getRules();
        rules += "< a,A< b,B< c,C< d,D< e,E< f,F< g,G< h,H< i,I< j,J < k,K"
                 "< l,L< m,M< n,N< o,O< p,P< q,Q< r,R< s,S< t,T < u,U< v,V"
                 "< w,W< x,X< y,Y< z,Z";
        mColl = new RuleBasedCollator(rules, status);
        if (!U_SUCCESS(status))
            mColl = (RuleBasedCollator *)Collator::createInstance(localeName, status);
    }

    if (U_SUCCESS(status))
        return true;
    return false;
}

bool LocaleUtils::isLessThan(QString lStr, QString rStr)
{
    if (lStr == "#") {
        return false;
    }
    if (rStr == "#") {
        return true;
    }

    //Convert strings to UnicodeStrings
    const ushort *lShort = lStr.utf16();
    UnicodeString lUniStr = UnicodeString(static_cast<const UChar *>(lShort));
    const ushort *rShort = rStr.utf16();
    UnicodeString rUniStr = UnicodeString(static_cast<const UChar *>(rShort));

    if (!mColl) {
        //No collator set, use fall back
        return QString::localeAwareCompare(lStr, rStr) < 0;
    }

    Collator::EComparisonResult res = mColl->compare(lUniStr, rUniStr);
    if (res == Collator::LESS)
        return true;

    return false;
}

QString LocaleUtils::getExemplarForString(QString str)
{
    QStringList indexes = getIndexBarChars();
    int i = 0;

    for (; i < indexes.size(); i++) {
        if (isLessThan(str, indexes.at(i))) {
            if (i == 0) {
                return str;
            }
            return indexes.at(i-1);
        }
    }
    
    return QString(tr("#"));
}

QString LocaleUtils::getBinForString(QString str)
{
    //REVISIT: Might need to use a locale aware version of toUpper() and at()
    if (!checkForAlphaChar(str))
        return QString(tr("#"));

    QString temp(str.at(0).toUpper());
    
    //REVISIT:  This should return the proper bin - work around for an
    //encoding issue
    QLocale::Country country = getCountry();
    if ((country == QLocale::DemocraticRepublicOfKorea) ||
        (country == QLocale::RepublicOfKorea))
        return temp;


    //The proper bin for these locales does not correspond
    //with a bin listed in the index bar
    if ((country == QLocale::Taiwan) || (country == QLocale::China))
        return temp;

    return getExemplarForString(temp);
}

QStringList LocaleUtils::getIndexBarChars()
{
    UErrorCode  status = U_ZERO_ERROR;
    QStringList list;

    QLocale::Country country = getCountry();
    QString locale = getLanguage();
    const char *name = locale.toLatin1().constData();

    //REVISIT: ulocdata_getExemplarSet() does not return the index characters
    //We need to query the locale data directly using the resource bundle 
    UResourceBundle *resource = ures_open(NULL, name, &status);

    //REVISIT:  This should return the proper bin - work around for an
    //encoding issue
    if ((U_SUCCESS(status) && 
        ((country != QLocale::DemocraticRepublicOfKorea) && 
        (country != QLocale::RepublicOfKorea)))) {
        qint32 size;
        const UChar *indexes = ures_getStringByKey(resource,
                                                   "ExemplarCharactersIndex",
                                                   &size, &status);
        if (U_SUCCESS(status)) {
            UnicodeString uniStr = UnicodeString(indexes, size);
            int i = 0;

            for (i = 0; i < uniStr.length(); i++) {
                QString temp(uniStr.char32At(i));

                if ((temp != QString(" ")) && (temp != QString("[")) &&
                    (temp != QString("]")))
                    list << temp;
            }

            if ((country == QLocale::Taiwan) || (country == QLocale::Japan) ||
                (country == QLocale::DemocraticRepublicOfKorea) ||
                (country == QLocale::RepublicOfKorea))
                list << "A" << "Z";
        }
    }

    ures_close(resource);
    if (list.isEmpty())
        list << "A" << "B" << "C" << "D" << "E" << "F" << "G" << "H"
             << "I" << "J" << "K" << "L" << "M" << "N" << "O" << "P"
             << "Q" << "R" << "S" << "T" << "U" << "V" << "W" << "Y" << "Z";

    list << QString(tr("#"));
    return list;
}

