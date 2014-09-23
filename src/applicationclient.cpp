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

#include "applicationclient.h"
#include <QApplication>
#include <Enginio/enginioclient.h>
#include <Enginio/enginiomodel.h>
#include <Enginio/enginioreply.h>
#include <Enginio/enginiooauth2authentication.h>
#include <QJsonObject>
#include "fileio.h"
#include "model.h"
#include <QStringList>
#include <QDebug>
#include <QTimer>

#define QUOTE_(x) #x
#define QUOTE(x) QUOTE_(x)
#define BACKEND_ID QUOTE(TALK_SCHEDULE_BACKEND_ID)

ApplicationClient::ApplicationClient()
    : init(true)
{
    m_settings = new FileIO(this, "settings.txt");

    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(authenticate()));

    m_userData = new FileIO(this);
    authenticator = new EnginioOAuth2Authentication(this);
    m_client = new EnginioClient(this);
    const QByteArray backId = QByteArray(BACKEND_ID);
    m_client->setBackendId(backId);

    m_conferenceModel = new Model(this);
    m_conferenceModel->setFileNameTag("ConferencesObject");

    connect(m_client, SIGNAL(sessionAuthenticated(EnginioReply*)), this, SLOT(authenticationSuccess(EnginioReply*)));
    connect(m_client, SIGNAL(sessionAuthenticationError(EnginioReply*)), this, SLOT(errorClient(EnginioReply*)));
    connect(m_client, SIGNAL(error(EnginioReply*)), this, SLOT(errorClient(EnginioReply*)));
    getUserCredentials();

    m_details = new QQmlPropertyMap(this);
    m_details->insert(QLatin1String("location"), QVariant(""));
    m_details->insert(QLatin1String("title"), QVariant(""));
    m_details->insert(QLatin1String("TwitterTag"), QVariant(""));
    m_details->insert(QLatin1String("infopage"), QVariant(""));
}

void ApplicationClient::errorClient(EnginioReply *reply)
{
    //qDebug() << "Error" << reply->errorString() << m_client->authenticationState();
    emit error(reply->errorString());
    reply->deleteLater();
}

void ApplicationClient::getUserCredentials()
{
    //qDebug() << "Get user credentials";
    QString cachedUserData = m_userData->read();
    QStringList splitData = cachedUserData.split(" ");
    if (splitData.length() != 2) {
        createUser();
    } else {
        currentUsername = splitData.at(0);
        currentPassword = splitData.at(1);
        authenticate();
    }
}

void ApplicationClient::createUser()
{
    //qDebug() << "Create User";
    currentUsername = m_userData->createUUID();
    currentPassword = m_userData->createUUID();
    QJsonObject query;
    query["objectType"] = QString::fromUtf8("users");
    query["username"] = currentUsername;
    query["password"] = currentPassword;
    const EnginioReply *reply = m_client->create(query);
    connect(reply, SIGNAL(finished(EnginioReply*)), this, SLOT(userCreationReply(EnginioReply*)));
}

void ApplicationClient::userCreationReply(EnginioReply *reply)
{
    if (reply->errorType() != Enginio::NoError) {
        //qDebug() << "Failed to create an user" << reply->errorString();
        emit error(reply->errorString());
    } else {
        //qDebug() << "User Created";
        m_userData->write(QString("%1 %2").arg(currentUsername).arg(currentPassword));
        authenticate();
    }
    reply->deleteLater();
}

void ApplicationClient::authenticate()
{
    //qDebug() << "Authenticate" << currentUsername;
    m_client->setIdentity(0);
    authenticator->setUser(currentUsername);
    authenticator->setPassword(currentPassword);
    m_client->setIdentity(authenticator);
}

void ApplicationClient::authenticationSuccess(EnginioReply *reply)
{
    //qDebug() << "Query the conference";
    int timeout = (reply->data().value("expires_in").toInt() - 20*60)*1000;
    timer->setSingleShot(true);
    timer->start(timeout);
    if (init) { // Query the conference only once
        QJsonObject query;
        query["objectType"] = QString::fromUtf8("objects.Conference");
        const EnginioReply *replyConf = m_client->query(query);
        connect(replyConf, SIGNAL(finished(EnginioReply*)), this, SLOT(queryConferenceReply(EnginioReply*)));
        init = false;
    }
}

void ApplicationClient::setCurrentConferenceId(const QString &newConfId)
{
    if (m_currentConferenceId != newConfId) {
        int indexCurrentConf = m_conferenceModel->indexOf("id", newConfId).toInt();
        if (indexCurrentConf != -1) {
            m_currentConferenceId = newConfId;
            m_settings->write(m_currentConferenceId);
            setCurrentConferenceIndex(indexCurrentConf);
            emit currentConferenceIdChanged();
        }
    }
}

void ApplicationClient::queryConferenceReply(EnginioReply *reply)
{
    m_conferenceModel->onFinished(reply);
    // If no conference were retrieved, allow conference query on next authentication
    if (m_conferenceModel->rowCount() == 0)
        init = true;
    setCurrentConferenceId(m_settings->read());
    emit conferencesModelChanged();
}

void ApplicationClient::setCurrentConferenceIndex(const int index)
{
    if (index > m_conferenceModel->rowCount() - 1)
        return;
    m_details->insert(QLatin1String("location"),m_conferenceModel->data(index, "location"));
    m_details->insert(QLatin1String("title"), m_conferenceModel->data(index, "title"));
    m_details->insert(QLatin1String("TwitterTag"), m_conferenceModel->data(index, "TwitterTag"));
    m_details->insert(QLatin1String("infopage"), m_conferenceModel->data(index, "infopage"));
    emit currentConferenceDetailsChanged();
}

bool ApplicationClient::eventFilter(QObject *object, QEvent *event)
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WINPHONE)
    if (event->type() == QEvent::ApplicationStateChange) {
        if (QApplication::applicationState() == Qt::ApplicationActive) {
            authenticate();
            return true;
        }
    }
#endif
    return QObject::eventFilter(object, event);
}
