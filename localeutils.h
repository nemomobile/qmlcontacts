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

class LocaleUtils: public QObject
{
    Q_OBJECT

public:
    explicit LocaleUtils(QObject *parent = 0);

    static LocaleUtils *self();

    Q_INVOKABLE QStringList getAddressFieldOrder() const;
    Q_INVOKABLE bool isLessThan(QString lStr, QString rStr);

protected:
    QString getLanguage() const;

private:
    static LocaleUtils *mSelf;
};

#endif // LOCALEUTILS_H
