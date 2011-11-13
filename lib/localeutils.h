/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef LOCALEUTILS_H
#define LOCALRUTILS_H

#include <QObject>
#include <QStringList>
#include <QLocale>

class LocaleUtils: public QObject
{
    Q_OBJECT

public:
    explicit LocaleUtils(QObject *parent = 0);
    virtual ~LocaleUtils();

    static LocaleUtils *self();

    Q_INVOKABLE QStringList getAddressFieldOrder() const;
    Q_INVOKABLE bool needPronounciationFields() const;
    Q_INVOKABLE QStringList getIndexBarChars();

    int compare(QString lStr, QString rStr);
    bool isLessThan(QString lStr, QString rStr);
    bool checkForAlphaChar(QString str);
    Q_INVOKABLE QString getExemplarForString(QString str);
    QString getBinForString(QString str);
    QLocale::Country getCountry() const;
    int defaultSortVal() const;
    int defaultDisplayVal() const;

protected:
    QString getLanguage() const;
    bool usePhoneBookCol() const;
    int defaultValues(QString type) const;

private:
    static LocaleUtils *mSelf;
};

#endif // LOCALEUTILS_H
