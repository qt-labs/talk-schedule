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
#include <QtQuick/QQuickView>
#include <QtCore/QString>
#include <QtGui/QGuiApplication>

#include "theme.h"
#include "model.h"
#include "sortfiltermodel.h"
#include "fileio.h"
#include <QSslSocket>

static QObject *systeminfo_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new Theme();
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlEngine engine;

    app.setApplicationName("conclave");
    app.setOrganizationName("Qt.Digia");

    qmlRegisterSingletonType<Theme>("qt.conclave.theme", 1, 0, "Theme", systeminfo_provider);
    qmlRegisterType<Model>("qt.conclave.models", 1, 0, "Model");
    qmlRegisterType<SortFilterModel>("qt.conclave.models", 1, 0, "SortFilterModel");
    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");

    QQmlComponent component(&engine);
    component.loadUrl(QUrl("qrc:/qml/main.qml"));
    if ( !component.isReady() ) {
        qWarning("%s", qPrintable(component.errorString()));
        return -1;
    }
    QObject *topLevel = component.create();
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    if ( !window ) {
        qWarning("Error: Your root item has to be a Window.");
        return -1;
    }
    QObject::connect(&engine, SIGNAL(quit()), &app, SLOT(quit()));
    window->show();
    return app.exec();
}
