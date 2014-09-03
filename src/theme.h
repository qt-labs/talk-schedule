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

#ifndef APPLICATIONINFO_H
#define APPLICATIONINFO_H

#include <QtCore/QObject>
#include <QtQml/QQmlPropertyMap>

class Theme : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int trackWidthDivider READ trackWidthDivider CONSTANT)
    Q_PROPERTY(QObject *text READ text CONSTANT)
    Q_PROPERTY(QObject *colors READ colors CONSTANT)
    Q_PROPERTY(QObject *sizes READ sizes CONSTANT)
    Q_PROPERTY(QObject *images READ images CONSTANT)
    Q_PROPERTY(QObject *fonts READ fonts CONSTANT)

public:
    explicit Theme(QObject *parent = 0);

    int trackWidthDivider() const;
    QQmlPropertyMap *text() const { return m_text; }
    QQmlPropertyMap *colors() const { return m_colors; }
    QQmlPropertyMap *sizes() const { return m_sizes; }
    QQmlPropertyMap *images() const { return m_images; }
    QQmlPropertyMap *fonts() const { return m_fonts; }

private:
    int m_trackWidthDivider;
    QQmlPropertyMap *m_text;
    QQmlPropertyMap *m_colors;
    QQmlPropertyMap *m_sizes;
    QQmlPropertyMap *m_images;
    QQmlPropertyMap *m_fonts;
};

#endif // APPLICATIONINFO_H
