/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include <QDebug>

#include <QStringList>
#include <QFileSystemWatcher>

#include "proxymodel.h"
#include "settingsdatastore.h"
#include "localeutils.h"

class ProxyModelPriv
{
public:
    ProxyModel::FilterType filterType;
    PeopleModel::PeopleRoles sortType;
    PeopleModel::PeopleRoles displayType;
    SettingsDataStore *settings;
    LocaleUtils *localeHelper;
    QFileSystemWatcher *settingsFileWatcher;
};

ProxyModel::ProxyModel(QObject *parent)
{
    Q_UNUSED(parent);
    priv = new ProxyModelPriv;
    priv->filterType = FilterAll;
    priv->settings = SettingsDataStore::self();
    priv->localeHelper = LocaleUtils::self();
    setDynamicSortFilter(true);
    setFilterKeyColumn(-1);

    priv->settingsFileWatcher = new QFileSystemWatcher(this);
    priv->settingsFileWatcher->addPath(priv->settings->getSettingsStoreFileName());
    connect(priv->settingsFileWatcher, SIGNAL(fileChanged(QString)),
            this, SLOT(readSettings()));

    readSettings();
}

ProxyModel::~ProxyModel()
{
    delete priv;
}

void ProxyModel::readSettings() 
{
    priv->settings->syncDataStore();
    setSortType((PeopleModel::PeopleRoles) priv->settings->getSortOrder());

    priv->settings->getDisplayOrder();
    setDisplayType((PeopleModel::PeopleRoles) priv->settings->getDisplayOrder());
}

void ProxyModel::setFilter(FilterType filter)
{
    priv->filterType = filter;
    invalidateFilter();
}

void ProxyModel::setSortType(PeopleModel::PeopleRoles sortType)
{
    priv->sortType = sortType;
    setSortRole(sortType);

    PeopleModel *model = dynamic_cast<PeopleModel *>(sourceModel());
    if (model)
        model->setSorting(sortType);

    reset(); //Clear the current sort method and then re-sort
    sort(0, Qt::AscendingOrder);
}

void ProxyModel::setDisplayType(PeopleModel::PeopleRoles displayType)
{
    priv->displayType = displayType;
}

void ProxyModel::setModel(PeopleModel *model)
{
    setSourceModel(model);
    readSettings();
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

    if ((priv->sortType != PeopleModel::FirstNameRole) 
        && (priv->sortType != PeopleModel::LastNameRole))
        return false;

    int searchRole = PeopleModel::FirstNameRole;
    int secondaryRole = PeopleModel::LastNameRole;

    if (priv->sortType == PeopleModel::LastNameRole) {
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
        if (lStr2.isEmpty())
            return false;
        else if (rStr2.isEmpty())
            return true;
    }

    if (lStr.isEmpty())
        return false;
    else if (rStr.isEmpty())
        return true;

    return priv->localeHelper->isLessThan(lStr, rStr);
}
