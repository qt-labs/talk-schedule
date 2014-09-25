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

#include "model.h"

#include <Enginio/enginioreply.h>
#include <QtCore/QDebug>
#include <QtCore/QJsonValue>
#include <QtCore/QJsonArray>
#include <QtCore/QJsonDocument>
#include <QtCore/QFile>
#include <QtCore/QStandardPaths>
#include <QtCore/QDir>
#include <QJSValueIterator>

Model::Model(QObject *parent)
    : QAbstractListModel(parent)
{
}


int Model::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_data.count();
}

QVariant Model::data(const QModelIndex &index, int role) const
{
    QVariant variant = m_data.at(index.row()).value(m_roleNames.value(role));
    // Hack to make it possible to filter by reference
    if (variant.type() == QVariant::Map && m_roleNames.value(role) == "day") {
        return variant.toMap().value("id");
    }
    if (variant.type() == QVariant::Map && m_roleNames.value(role) == "track") {
        return variant.toMap().value("id");
    }
    return variant;
}

void Model::addFavorite( const QString &data)
{
    QMap<QString, QVariant> temp;
    for (int i = 0; i < m_data.count(); i++) {
        temp = m_data.at(i);
        if (temp.keys().contains("id")) {
            if (data == temp["id"]) {
                if (!temp["favorite"].toBool()) {
                    temp["favorite"] = true;
                    m_data.replace(i, temp);
                    Q_EMIT dataChanged(this->index(i), this->index(i));
                }
                break;
            }
        }
    }
}

void Model::removeFavorite(const QString &data)
{
    QMap<QString, QVariant> temp;
    for (int i = 0; i < m_data.count(); i++) {
        temp = m_data.at(i);

        QMapIterator<QString, QVariant> iter(temp);
        while (iter.hasNext()) {
            iter.next();
            if (iter.key() == "id" && iter.value() == data) {
                if (temp["favorite"].toBool()) {
                    temp["favorite"] = false;
                    m_data.replace(i, temp);
                    Q_EMIT dataChanged(this->index(i), this->index(i));
                }
                break;
            }
        }
    }
}

void Model::addRow(const QJsonObject &data)
{
    beginInsertRows(QModelIndex(), m_data.count(), m_data.count());
    m_data.append(data.toVariantMap());
    endInsertRows();
}

void Model::removeRow(int index)
{
    if (m_data.count() > index && index >= 0) {
        beginRemoveRows(QModelIndex(), index, index);
        m_data.removeAt(index);
        endRemoveRows();
    }
}

QVariant Model::indexOf(const QString &role, QVariant value)
{
    QModelIndexList result = match(index(0, 0), roleNames().key(role.toLatin1()), value);
    return result.empty() ? -1 : result.at(0).row();
}

QHash<int, QByteArray> Model::roleNames() const
{
    return m_roleNames;
}

void Model::setConferenceId(const QString &id)
{
    if (id != m_conferenceId) {
        m_conferenceId =  id;
        // The file name tag has been declared before
        load();
        Q_EMIT conferenceIdChanged();
    }
}

void Model::setFileNameTag(const QString &newTag)
{
    if (newTag != m_fileNameTag) {
        m_fileNameTag =  newTag;
        Q_EMIT fileNameTagChanged();
    }
}

QVariant Model::data(int index, const QString &role) const
{
    return data(this->index(index, 0), m_roleNames.key(role.toLatin1()));
}

void Model::onFinished(EnginioReply *reply)
{
    if (reply->errorType() == Enginio::NoError) {
        bool dataHasChanged = parse(reply->data());
        if (dataHasChanged)
            save(reply->data());
    }
    reply->deleteLater();
}

bool Model::save(const QJsonObject &object)
{
    // Don't save and load if no file name tag is specified
    if (fileNameTag().isEmpty())
        return false;

    if (!object.keys().contains("results")) {
        qWarning()<< "Wrong json format";
        return false;
    }

    QString fileName = QString("%1.%2").arg(m_fileNameTag).arg(m_conferenceId);
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir dir(path);
    if (!dir.exists() && !dir.mkpath(path)) {
        qWarning() << "Could not create dir" << path;
        return false;
    }

    QFile file(QString("%1/%2").arg(path).arg(fileName));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "On save couldn't open file" << file.fileName();
        return false;
    }

    QJsonDocument saveDoc(object);
    file.write(saveDoc.toJson());
    file.close();
    currentModelObject[fileNameTag()] = object;
    return true;
}

bool Model::load()
{
    // Don't save and load if no file name tag is specified
    if (fileNameTag().isEmpty())
        return false;

    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QFile file(QString("%1/%2.%3").arg(path).arg(m_fileNameTag).arg(m_conferenceId));
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "On load couldn't open file" << file.fileName();
        return false;
    }

    QByteArray data = file.readAll();
    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    parse(loadDoc.object());
    currentModelObject[fileNameTag()] = loadDoc.object();
    return true;
}

bool Model::appendAndSaveFavorites(const QString &data, bool isAdded)
{
    if (fileNameTag().isEmpty())
        return false;

    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QFile file(QString("%1/%2.%3").arg(path).arg(m_fileNameTag).arg(m_conferenceId));
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "On load couldn't open file" << file.fileName();
        return false;
    }

    QString fileContent;
    QString line;
    QTextStream t(&file);
    do {
        line = t.readLine();
        fileContent += line;
    } while (!line.isNull());

    file.close();

    QJsonObject object = QJsonDocument::fromJson(fileContent.toUtf8()).object();
    QJsonArray array = object.value("results").toArray();
    if (isAdded) {
        QJsonObject newFav;
        QJsonObject fav;
        fav["id"] = data;
        fav["objectType"] = QString::fromUtf8("objects.Event");
        newFav["favoriteEvent"] = fav;
        newFav["events_id"] = data;
        array.append(newFav);
    } else {
        for (int i = 0; i < array.count(); i++) {
            QJsonObject tempObject = array.at(i).toObject();
            if (tempObject.value("favoriteEvent").toObject().value("id") == data) {
                array.removeAt(i);
                break;
            }
        }
    }
    object["results"] = array;
    return save(object);
}

bool Model::parse(const QJsonObject &object)
{
    bool dataHasChanged = true;

    dataHasChanged = fileNameTag().isEmpty() || object != currentModelObject[fileNameTag()];

    if (dataHasChanged) {
        beginResetModel();
        m_data.clear();
        m_roleNames.clear();
        endResetModel();

        QJsonArray array = object.value("results").toArray();
        if (array.count() > 0) {
            // Go through the keys in array to find out all the key values
            // If all values has no content in cloud, that key might sometimes be missing
            // so you cannot take keys from arbitrary place from array
            int previousCount = 0;
            int arrayIndex = 0;
            for (int i = 0; i < array.count(); i++) {
                QStringList tempKeys = array.at(i).toVariant().toMap().keys();
                if (previousCount < tempKeys.count() ){
                    previousCount = tempKeys.count();
                    arrayIndex = i;
                }
            }
            QStringList keys = array.at(arrayIndex).toVariant().toMap().keys();
            for (int index = 0; index < keys.count(); ++index)
                m_roleNames.insert(Qt::UserRole + index, keys.at(index).toLatin1());

            // Hack, insert favorites as those will be created in application
            m_roleNames.insert(2002, "favorite");
            beginInsertRows(QModelIndex(), m_data.count(), m_data.count() + array.count() - 1);
            foreach (QJsonValue value, array) {
                QJsonObject temp;
                if (value.isObject()) {

                    // Hack to make it possible to sort by reference
                    QVariant var = value.toVariant().toMap().value("events");
                    if (var.isValid()) {

                        QJsonObject obj = value.toObject();
                        int ind= 0;
                        for (QJsonObject::const_iterator i = obj.constBegin(); i != obj.constEnd(); ++i) {

                            if (i.key() == "events") {
                                QJsonObject eventObject = i.value().toObject();
                                for (QJsonObject::const_iterator i2 = eventObject.constBegin(); i2 != eventObject.constEnd();
                                     ++i2) {
                                    QString key = "events_"+i2.key();
                                    temp[key] = i2.value();
                                    m_roleNames.insert(Qt::UserRole + 400+ind, key.toLatin1());
                                    ind++;
                                }
                            }
                            ind++;
                        }

                        m_data.append(temp.toVariantMap());
                    } else {
                        m_data.append(value.toVariant().toMap());
                    }
                } else {

                    m_data.append(value.toVariant().toMap());
                }
            }
            endInsertRows();
        }
    }
    Q_EMIT dataReady();
    return dataHasChanged;
}
