/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>

#include <QStringList>

#include "proxymodel.h"

class ProxyModelPriv
{
public:
    ProxyModel::FilterType filterType;
    ProxyModel::SortType sortType;
};

ProxyModel::ProxyModel(QObject *parent)
{
    Q_UNUSED(parent);
    priv = new ProxyModelPriv;
    priv->filterType = FilterAll;
    priv->sortType = SortFirstName;
    setDynamicSortFilter(true);
    setFilterKeyColumn(-1);
    setSortRole(PeopleModel::FirstNameRole);
    sort(0, Qt::AscendingOrder);
}

ProxyModel::~ProxyModel()
{
    delete priv;
}

void ProxyModel::setFilter(FilterType filter)
{
    priv->filterType = filter;
    invalidateFilter();
}

void ProxyModel::setSortType(SortType sortType)
{
    priv->sortType = sortType;
    PeopleModel *model = dynamic_cast<PeopleModel *>(sourceModel());

    switch(sortType){
    case SortLastName:
       setSortRole(PeopleModel::LastNameRole);
        model->setSorting(PeopleModel::LastNameRole);
        break;
    case SortFirstName:
    default:
        setSortRole(PeopleModel::FirstNameRole);
        model->setSorting(PeopleModel::FirstNameRole);
        break;
    }

    //REVISIT: Only support sorting by first name for now
    sort(0, Qt::AscendingOrder);
}

void ProxyModel::setModel(PeopleModel *model)
{
    setSourceModel(model);
}

int ProxyModel::getSourceRow(int row)
{
    return mapToSource(index(row, 0)).row();
}

bool ProxyModel::filterAcceptsRow(int source_row,
                                  const QModelIndex& source_parent) const
{
    // TODO: add communication history
    //if (!QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent))
    //    return false;

    if (priv->filterType == FilterAll)
        return true;

    PeopleModel *model = dynamic_cast<PeopleModel *>(sourceModel());
    if (!model)
        return true;

    if (priv->filterType == FilterFavorites) {
        QModelIndex modelIndex = sourceModel()->index(source_row, 0, source_parent);
        //return model->index(source_row, PeopleModel::FavoriteRole).data(DataRole);
        return (model->data(modelIndex, PeopleModel::FavoriteRole) == "Favorite");
    }
    else {
        qWarning() << "[ProxyModel] invalid filter type";
        return true;
    }
}

bool ProxyModel::lessThan(const QModelIndex& left,
                          const QModelIndex& right) const
{
    PeopleModel *model = dynamic_cast<PeopleModel *>(sourceModel());
    if (!model)
        return true;

    if ((priv->sortType != SortFirstName) && (priv->sortType != SortLastName))
        return false;

    int searchRole = PeopleModel::FirstNameRole;
    int secondaryRole = PeopleModel::LastNameRole;
    if (priv->sortType == SortLastName) {
        searchRole = PeopleModel::LastNameRole;
        secondaryRole = PeopleModel::FirstNameRole;
    }

    const QString& lStr = model->data(left.row(), searchRole).toString();
    const bool isleftSelf = model->data(left.row(), PeopleModel::IsSelfRole).toBool();

    const QString& rStr = model->data(right.row(), searchRole).toString();
    const bool isrightSelf = model->data(right.row(), PeopleModel::IsSelfRole).toBool();

    //qWarning() << "[ProxyModel] lessThan isSelf left" << isleftSelf << " right" << isrightSelf;

    //MeCard should always be top of the list
    if(isleftSelf)
        return true;
    if(isrightSelf)
        return false;

    const QString& lStr2 = model->data(left.row(), secondaryRole).toString();
    const QString& rStr2 = model->data(right.row(), secondaryRole).toString();

    //qWarning() << "[ProxyModel] lessThan " << lStr << "VS" << rStr << "compare returns:" << QString::localeAwareCompare(lStr, rStr);

    //If searchRole field is empty, contact belongs at the end of the list
    //Sort contacts with empty searchRoles by secondardyRole
    //REVISIT: What if the secondary role is also empty?
    if (lStr.isEmpty() && rStr.isEmpty()) {
        if (priv->sortType == SortFirstName) {
            return QString::localeAwareCompare(lStr2, rStr2) < 0;
        } else if (priv->sortType == SortLastName) {
            if (lStr2.isEmpty())
                 return QString::localeAwareCompare(lStr2, rStr2) > 0;
            return QString::localeAwareCompare(lStr2, rStr2) < 0;
        }
    }

    if (lStr.isEmpty())
        return false;
    else if (rStr.isEmpty())
        return true;

    return QString::localeAwareCompare(lStr, rStr) < 0;
}
