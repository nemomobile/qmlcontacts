/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef PROXYMODEL_H
#define PROXYMODEL_H

#include <QSortFilterProxyModel>
#include "peoplemodel.h"

class ProxyModelPriv;

class ProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_ENUMS(FilterType)

public:
    ProxyModel(QObject *parent = 0);
    virtual ~ProxyModel();

    enum FilterType {
        FilterAll,
        FilterFavorites,
    };

    Q_INVOKABLE virtual void setFilter(FilterType filter);
    Q_INVOKABLE virtual void setSortType(PeopleModel::PeopleRoles sortType);
    Q_INVOKABLE virtual void setDisplayType(PeopleModel::PeopleRoles displayType);
    Q_INVOKABLE void setModel(PeopleModel *model);
    Q_INVOKABLE int getSourceRow(int row);

protected:
    virtual bool filterAcceptsRow(int source_row, const QModelIndex& source_parent) const;
    virtual bool lessThan(const QModelIndex& left, const QModelIndex& right) const;

private slots:
    void readSettings();
    QString findString(int row, PeopleModel *model) const;

private:
    ProxyModelPriv *priv;
    Q_DISABLE_COPY(ProxyModel);
};

#endif // PROXYMODEL_H
