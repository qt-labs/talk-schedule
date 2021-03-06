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

#include <QtQml>
#include <QtCore/QString>
#include <QtGui/QGuiApplication>
#include <QtGui/QFont>
#include <QtGui/QFontDatabase>

#include "theme.h"
#include "model.h"
#include "sortfiltermodel.h"
#include "fileio.h"
#include "applicationclient.h"

#define QUOTE_(x) #x
#define QUOTE(x) QUOTE_(x)
#define BACKEND_ID QUOTE(TALK_SCHEDULE_BACKEND_ID)
#define CONSUMER_KEY QUOTE(TWITTER_KEY)
#define CONSUMER_SECRET QUOTE(TWITTER_SECRET)

static QObject *systeminfo_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new Theme();
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("QtDevDays");
    app.setOrganizationName("Qt.Digia");

    QFontDatabase::addApplicationFont(":/fonts/OpenSans-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/OpenSans-Semibold.ttf");
    int openSansID = QFontDatabase::addApplicationFont(":/fonts/OpenSans-Regular.ttf");
    QStringList loadedFontFamilies = QFontDatabase::applicationFontFamilies(openSansID);
    if (!loadedFontFamilies.empty()) {
        QString fontName = loadedFontFamilies.at(0);
        QGuiApplication::setFont(QFont(fontName));
    } else {
        qWarning("Error: fail to load Open Sans font");
    }
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("consumerKey", QString(CONSUMER_KEY));
    engine.rootContext()->setContextProperty("consumerSecret", QString(CONSUMER_SECRET));

    ApplicationClient *client = new ApplicationClient();
    app.installEventFilter(client);
    engine.rootContext()->setContextProperty("applicationClient", client);

    const char *uri = "TalkSchedule";
    // @uri TalkSchedule
    qmlRegisterSingletonType<Theme>(uri, 1, 0, "Theme", systeminfo_provider);
    qmlRegisterType<Model>(uri, 1, 0, "Model");
    qmlRegisterType<SortFilterModel>(uri, 1, 0, "SortFilterModel");
    qmlRegisterType<FileIO>(uri, 1, 0, "FileIO");
    qmlRegisterSingletonType(QUrl("qrc:/qml/components/ModelsSingleton.qml"), uri, 1, 0, "ModelsSingleton");

    engine.load(QUrl("qrc:/qml/main.qml"));
    return app.exec();
}
