/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef __contactsfeedmodel_h
#define __contactsfeedmodel_h

#include <QObject>
#include <QList>
#include <QDateTime>

#include <feedmodel.h>
#include <actions.h>

class PeopleModel;

class ContactsFeedModel: public McaFeedModel, public McaSearchableFeed
{
    Q_OBJECT

public:
    ContactsFeedModel(const QString &searchText, QObject *parent = 0);
    ~ContactsFeedModel();

    void setSearchText(const QString &text);

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;

protected slots:
    void sourceRowsAboutToBeInserted(const QModelIndex& parent, int first, int last);
    void sourceRowsInserted(const QModelIndex& parent, int first, int last);
    void sourceRowsAboutToBeRemoved(const QModelIndex& parent, int first, int last);
    void sourceRowsRemoved(const QModelIndex& parent, int first, int last);
    void sourceRowsAboutToBeMoved(const QModelIndex &source, int first, int last,
                                  const QModelIndex &dest, int destStart);
    void sourceRowsMoved(const QModelIndex &source, int first, int last,
                         const QModelIndex &dest, int destStart);
    void sourceDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight);
    void sourceModelAboutToBeReset();
    void sourceModelReset();;
    void performAction(QString uniqueid, QString action);

private:
    PeopleModel *m_source;
    McaActions *m_actions;
    QString m_searchText;
    int m_rowCount;
};

#endif  // __contactsfeedmodel_h
