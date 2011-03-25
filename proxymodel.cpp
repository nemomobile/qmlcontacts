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
    priv->sortType = SortName;
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

    const QString& lStr = model->data(left.row(), PeopleModel::FirstNameRole).toString();
    const bool isleftSelf = model->data(left.row(), PeopleModel::IsSelfRole).toBool();

    const QString& rStr = model->data(right.row(), PeopleModel::FirstNameRole).toString();
    const bool isrightSelf = model->data(right.row(), PeopleModel::IsSelfRole).toBool();

    //qWarning() << "[ProxyModel] lessThan isSelf left" << isleftSelf << " right" << isrightSelf;

    //MeCard should always be top of the list
    if(isleftSelf)
        return true;
    if(isrightSelf)
        return false;

    if (priv->sortType == SortName) {
        //qWarning() << "[ProxyModel] lessThan " << lStr << "VS" << rStr << "compare returns:" << QString::localeAwareCompare(lStr, rStr);

        //If the first name is empty, the contacts belong at the end of the list
        //REVISIT: Should contacts without a firstname then be sorted by last name? What happens if there's no last name?
        if (lStr.isEmpty() && rStr.isEmpty()) {
            const QString& lStrLast = model->data(left.row(), PeopleModel::LastNameRole).toString();
            const QString& rStrLast = model->data(right.row(), PeopleModel::LastNameRole).toString();
            return QString::localeAwareCompare(lStrLast, rStrLast) < 0;
        }

        else if (lStr.isEmpty())
            return false;

        else if (rStr.isEmpty())
            return true;

        return QString::localeAwareCompare(lStr, rStr) < 0;
    }
    return false;
}
