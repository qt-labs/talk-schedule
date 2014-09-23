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

#ifndef APPLICATIONCLIENT_H
#define APPLICATIONCLIENT_H

#include <QObject>
#include <QString>
#include <QtQml/QQmlPropertyMap>

class EnginioClient;
class EnginioModel;
class EnginioOAuth2Authentication;
class EnginioReply;
class FileIO;
class Model;
class QTimer;

class ApplicationClient: public QObject
{
    Q_OBJECT
    Q_PROPERTY(EnginioClient *client READ client)
    Q_PROPERTY(QString currentConferenceId READ currentConferenceId WRITE setCurrentConferenceId NOTIFY currentConferenceIdChanged)
    Q_PROPERTY(Model *conferencesModel READ conferencesModel NOTIFY conferencesModelChanged())
    Q_PROPERTY(QObject *currentConferenceDetails READ currentConferenceDetails NOTIFY currentConferenceDetailsChanged)
public:
    explicit ApplicationClient();
    Model *conferencesModel() const { return m_conferenceModel; }
    EnginioClient *client() { return m_client; }

    QString currentConferenceId() const { return m_currentConferenceId; }
    void setCurrentConferenceId(const QString &newConfId);

    Q_INVOKABLE void setCurrentConferenceIndex(const int index);

    QQmlPropertyMap *currentConferenceDetails() const { return m_details; }

protected:
    void getUserCredentials();
    void createUser();

    bool eventFilter(QObject *object, QEvent *event);

signals:
    void error(QString errorMessage);
    void askQueryConferences();
    void currentConferenceIdChanged();
    void currentConferenceDetailsChanged();
    void conferencesModelChanged();

public slots:
    void authenticationSuccess(EnginioReply *reply);
    void errorClient(EnginioReply *reply);
    void userCreationReply(EnginioReply *reply);
    void queryConferenceReply(EnginioReply *reply);
    void authenticate();

private:
    EnginioClient *m_client;
    Model *m_conferenceModel;
    FileIO *m_userData;
    FileIO *m_settings;
    QString currentUsername;
    QString currentPassword;
    EnginioOAuth2Authentication *authenticator;
    QString m_currentConferenceId;
    QQmlPropertyMap *m_details;
    QTimer *timer;
    bool init;
};

#endif // APPLICATIONCLIENT_H
