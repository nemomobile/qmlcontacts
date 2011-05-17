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

QString ProxyModel::findString(int row, PeopleModel *model) const {
    QString lStr = QString("");

    if ((priv->sortType != PeopleModel::FirstNameRole)
        && (priv->sortType != PeopleModel::LastNameRole))
        return lStr;

    int searchRole = PeopleModel::FirstNameRole;
    int secondaryRole = PeopleModel::LastNameRole;

    if (priv->sortType == PeopleModel::LastNameRole) {
        searchRole = PeopleModel::LastNameRole;
        secondaryRole = PeopleModel::FirstNameRole;
    }

    QList<int> roleOrder;
    roleOrder << searchRole << secondaryRole
              << PeopleModel::CompanyNameRole
              << PeopleModel::PhoneNumberRole
              << PeopleModel::OnlineAccountUriRole
              << PeopleModel::EmailAddressRole
              << PeopleModel::WebUrlRole;

    for (int i = 0; i < roleOrder.size(); ++i) {
        lStr = model->data(row, roleOrder.at(i)).toString();
        if (!lStr.isEmpty())
            return lStr;
    }

    lStr = QString("");
    return lStr;
}

bool ProxyModel::lessThan(const QModelIndex& left,
                          const QModelIndex& right) const
{
    PeopleModel *model = dynamic_cast<PeopleModel *>(sourceModel());
    if (!model)
        return true;

    int leftRow = left.row();
    int rightRow = right.row();

    const bool isleftSelf = model->data(leftRow, PeopleModel::IsSelfRole).toBool();
    const bool isrightSelf = model->data(rightRow, PeopleModel::IsSelfRole).toBool();

    //qWarning() << "[ProxyModel] lessThan isSelf left" << isleftSelf << " right" << isrightSelf;

    //MeCard should always be top of the list
    if(isleftSelf)
        return true;
    if(isrightSelf)
        return false;

    QString lStr = findString(leftRow, model);
    QString rStr = findString(rightRow, model);

    //qWarning() << "[ProxyModel] lessThan " << lStr << "VS" << rStr;

    if (lStr.isEmpty())
        return false;
    else if (rStr.isEmpty())
        return true;

    if (!priv->localeHelper->checkForAlphaChar(lStr))
        return false;
    if (!priv->localeHelper->checkForAlphaChar(rStr))
        return true;

    return priv->localeHelper->isLessThan(lStr, rStr);
}
