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

#include "theme.h"

#include <QtGui/QGuiApplication>
#include <QtGui/QScreen>

Theme::Theme(QObject *parent)
    : QObject(parent)
    , m_trackWidthDivider(400)
{
    m_text = new QQmlPropertyMap(this);
    m_text->insert(QLatin1String("home"), tr("Home"));
    m_text->insert(QLatin1String("schedule"), tr("Schedule"));
    m_text->insert(QLatin1String("talks"), tr("Presentations"));
    m_text->insert(QLatin1String("favorites"), tr("Favorites"));
    m_text->insert(QLatin1String("feedback"), tr("Send Feedback"));
    m_text->insert(QLatin1String("upcoming"), tr("Upcoming"));
    m_text->insert(QLatin1String("news"), tr("News"));
    m_text->insert(QLatin1String("info"), tr("Useful Information"));

    m_colors = new QQmlPropertyMap(this);
    m_colors->insert(QLatin1String("white"), QVariant("#ffffff"));
    m_colors->insert(QLatin1String("smokewhite"), QVariant("#f2f2f2"));
    m_colors->insert(QLatin1String("lightgrey"), QVariant("#cccccc"));
    m_colors->insert(QLatin1String("gray"), QVariant("#808080"));
    m_colors->insert(QLatin1String("darkgray"), QVariant("#333333"));
    m_colors->insert(QLatin1String("blue"), QVariant("#14aaff"));
    m_colors->insert(QLatin1String("green"), QVariant("#328930"));
    m_colors->insert(QLatin1String("qtgreen"), QVariant("#5caa15"));
    m_colors->insert(QLatin1String("black"), QVariant("#000000"));

    m_sizes = new QQmlPropertyMap(this);
    m_sizes->insert(QLatin1String("trackHeaderHeight"), QVariant(255));
    m_sizes->insert(QLatin1String("trackHeaderWidth"), QVariant(270));
    m_sizes->insert(QLatin1String("timeColumnWidth"), QVariant(600));
    m_sizes->insert(QLatin1String("conferenceHeaderHeight"), QVariant(158));
    m_sizes->insert(QLatin1String("dayWidth"), QVariant(150));
    m_sizes->insert(QLatin1String("favoriteImageHeight"), QVariant(76));
    m_sizes->insert(QLatin1String("favoriteImageWidth"), QVariant(80));
    m_sizes->insert(QLatin1String("titleHeight"), QVariant(60));
    m_sizes->insert(QLatin1String("backHeight"), QVariant(74));
    m_sizes->insert(QLatin1String("backWidth"), QVariant(42));
    m_sizes->insert(QLatin1String("logoHeight"), QVariant(100));
    m_sizes->insert(QLatin1String("logoWidth"), QVariant(286));
    m_sizes->insert(QLatin1String("menuHeight"), QVariant(62));
    m_sizes->insert(QLatin1String("menuWidth"), QVariant(78));
    m_sizes->insert(QLatin1String("dayLabelHeight"), QVariant(40));
    m_sizes->insert(QLatin1String("upcomingEventHeight"), QVariant(45));
    m_sizes->insert(QLatin1String("upcomingEventTimeWidth"), QVariant(150));

    m_images = new QQmlPropertyMap(this);
    m_images->insert(QLatin1String("back"), QVariant("qrc:/images/BackArrow.svg"));
    m_images->insert(QLatin1String("menu"), QVariant("qrc:/images/Menu.svg"));
    m_images->insert(QLatin1String("logo"), QVariant("qrc:/images/DevDaysLogo.svg"));
    m_images->insert(QLatin1String("favorite"), QVariant("qrc:/images/StarSelected.svg"));
    m_images->insert(QLatin1String("notFavorite"), QVariant("qrc:/images/Star.svg"));

    m_fonts = new QQmlPropertyMap(this);
    m_fonts->insert(QLatin1String("six_pt"), QVariant(8));
    m_fonts->insert(QLatin1String("seven_pt"), QVariant(9));
    m_fonts->insert(QLatin1String("eight_pt"), QVariant(10));
    m_fonts->insert(QLatin1String("ten_pt"), QVariant(12));
    m_fonts->insert(QLatin1String("twelve_pt"), QVariant(14));
}

int Theme::trackWidthDivider() const
{
    return m_trackWidthDivider;
}
