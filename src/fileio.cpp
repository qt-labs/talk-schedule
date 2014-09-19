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
#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDir>
#include <QtCore/QStandardPaths>
#include <QUuid>
#include <QDebug>

FileIO::FileIO(QObject *parent, QString filename) :
    QObject(parent)
{
    QString path = QStandardPaths::standardLocations(QStandardPaths::DataLocation).value(0);
    QDir dir(path);
    if (!dir.exists())
         dir.mkpath(path);
    if (!path.isEmpty() && !path.endsWith("/"))
        path += "/";
    mSource = QString("%1%2").arg(path).arg(filename);
}

QString FileIO::read()
{
    if (mSource.isEmpty()) {
        emit error("source is empty");
        return QString();
    }

    QFile file(mSource);
    QString fileContent;
    if (file.open(QIODevice::ReadOnly)) {
        QString line;
        QTextStream t(&file);
        do {
            line = t.readLine();
            fileContent += line;
        } while (!line.isNull());

        file.close();
    } else {
        emit error("Unable to open the file");
        //qDebug() << "unable to open file " << mSource;
        return QString();
    }
    return fileContent;
}

bool FileIO::write(const QString &data)
{
    QFile file(mSource);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
        //qDebug() << "could not open file";
        return false;
    }

    QTextStream out(&file);
    out << data;
    //qDebug() << "data written " << data;
    file.close();

    return true;
}

QString FileIO::createUUID()
{
    QString uuid = QUuid::createUuid().toString();
    // Remove curly brackets
    uuid.remove(0,1);
    uuid.remove(uuid.length() - 1,1);
    return uuid;
}
