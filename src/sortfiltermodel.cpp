/****************************************************************************
**
** Copyright (C) 2014 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "sortfiltermodel.h"
#include <QtCore/QDateTime>
#include <QtCore/QDebug>

SortFilterModel::SortFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent),
      m_maximumCount(0)
{
    connect(this, SIGNAL(sourceModelChanged()), SIGNAL(modelChanged()));
    connect(this, SIGNAL(sortRoleChanged()), SLOT(manualSort()));
    setDynamicSortFilter(false);
}

void SortFilterModel::setModel(QObject *model)
{
    QAbstractItemModel* tmpModel = qobject_cast<QAbstractItemModel*>(model);
    if (tmpModel == NULL)
        return;
    setSourceModel(tmpModel);

    setSortRole(m_sortRole);
    setFilterRole(m_filterRole);
}

QString SortFilterModel::sortRole() const
{
    return m_sortRole;
}

void SortFilterModel::setSortRole(const QString &role)
{
    m_sortRole = role;
    QSortFilterProxyModel::setSortRole(roleNames().key(role.toLatin1()));
    Q_EMIT sortRoleChanged();
}

QString SortFilterModel::filterRole() const
{
    return m_filterRole;
}

void SortFilterModel::setFilterRole(const QString &role)
{
    m_filterRole = role;
    QSortFilterProxyModel::setFilterRole(roleNames().key(role.toLatin1()));
    Q_EMIT filterRoleChanged();
}

int SortFilterModel::maximumCount() const
{
    return m_maximumCount;
}

void SortFilterModel::setMaximumCount(const int &newCount)
{
    if (newCount != m_maximumCount) {
        m_maximumCount = newCount;
        emit maximumCountChanged();
    }
}

QVariant SortFilterModel::get(int row, const QString &role)
{
    return data(index(row, 0), roleNames().key(role.toLatin1()));
}

void SortFilterModel::set(int row, const QVariant &data, const QString &role)
{
    setData(index(row, 0), data, roleNames().key(role.toLatin1()));
}

QVariant SortFilterModel::indexOf(const QString &role, QVariant value)
{
    QModelIndexList result = match(index(0, 0), roleNames().key(role.toLatin1()), value);
    return result.empty() ? 0 : result.at(0).row();
}

int SortFilterModel::rowCount(const QModelIndex &parent) const
{
    int tempRowCount = QSortFilterProxyModel::rowCount(parent);
    if (maximumCount() > 0)
        tempRowCount = qMin(maximumCount(), tempRowCount);
    return tempRowCount;
}

void SortFilterModel::manualSort()
{
    sort(0, sortOrder());
}

void SortFilterModel::filter()
{
    QSortFilterProxyModel::invalidate();
    manualSort();
}

bool SortFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (filterRole() == "fromNow" && sourceModel()->roleNames().values().contains("start")) {
        QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
        QDateTime date = sourceModel()->data(index, sourceModel()->roleNames().key("start")).toDateTime();
        QDateTime currentDateTime = QDateTime::currentDateTime();
        int localTimeZoneOffset = currentDateTime.offsetFromUtc();
        currentDateTime.setMSecsSinceEpoch(currentDateTime.currentMSecsSinceEpoch() + localTimeZoneOffset*1000);
        return date >= currentDateTime;
    } else {
        return QSortFilterProxyModel::filterAcceptsRow(source_row, source_parent);
    }
}
