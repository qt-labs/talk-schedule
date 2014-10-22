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
{
    // Reference values from the Nexus 5
    qreal refDpi = 216.;
    qreal refHeight = 1776.;
    qreal refWidth = 1080.;
    QRect rect = qApp->primaryScreen()->geometry();
    qreal height = qMax(rect.width(), rect.height());
    qreal width = qMin(rect.width(), rect.height());
    qreal dpi = qApp->primaryScreen()->logicalDotsPerInch();
    m_ratio = qMin(height/refHeight, width/refWidth);
    m_ratioFont = qMin(height*refDpi/(dpi*refHeight), width*refDpi/(dpi*refWidth));

    int tempTimeColumnWidth = 600;
    int tempTrackHeaderWidth = 270;
    // check if the font size is acceptable
    if (m_ratioFont < 1.) {
        m_ratioFont = 1;
        // check if sizes are acceptable
        int margins = applyRatio(30);
        int tempWidthContent = applyRatio(tempTimeColumnWidth) + applyRatio(tempTrackHeaderWidth) + margins;
        qreal tempRatio = tempWidthContent / width;
        if (tempRatio < 1)
            m_ratio /= tempRatio;
    }

    m_text = new QQmlPropertyMap(this);
    m_text->insert(QLatin1String("home"), tr("%1 Home"));
    m_text->insert(QLatin1String("schedule"), tr("Schedule"));
    m_text->insert(QLatin1String("talks"), tr("%1 Presentations"));
    m_text->insert(QLatin1String("details"), tr("Presentation Details"));
    m_text->insert(QLatin1String("favorites"), tr("%1 Favorites"));
    m_text->insert(QLatin1String("feedback"), tr("Send Feedback"));
    m_text->insert(QLatin1String("upcoming"), tr("Upcoming: %1 %2"));
    m_text->insert(QLatin1String("news"), tr("Tweets"));
    m_text->insert(QLatin1String("writeYourCommentHere"), tr("Write your comments here"));
    m_text->insert(QLatin1String("by"), tr("by %1"));
    m_text->insert(QLatin1String("room"), tr("Room %1"));
    m_text->insert(QLatin1String("room_space"), tr(" | Room %1"));
    m_text->insert(QLatin1String("twitterLink"), tr("https://twitter.com/"));
    m_text->insert(QLatin1String("select_conference"), tr("Select a conference"));
    m_text->insert(QLatin1String("switchConf"), tr("Switch Conference"));
    m_text->insert(QLatin1String("floorPlan"), tr("Floor Plan"));
    m_text->insert(QLatin1String("networkErrorInit"), tr("Network Error: check your device's network connection"));
    m_text->insert(QLatin1String("endedEvent"), tr("The conference has now ended"));
    m_text->insert(QLatin1String("toWebsite"), tr("Website (external)"));
    m_text->insert(QLatin1String("noCachedData"), tr("No Cached Data"));

    m_colors = new QQmlPropertyMap(this);
    m_colors->insert(QLatin1String("white"), QVariant("#ffffff"));
    m_colors->insert(QLatin1String("smokewhite"), QVariant("#f2f2f2"));
    m_colors->insert(QLatin1String("lightgray"), QVariant("#cccccc"));
    m_colors->insert(QLatin1String("gray"), QVariant("#808080"));
    m_colors->insert(QLatin1String("darkgray"), QVariant("#333333"));
    m_colors->insert(QLatin1String("blue"), QVariant("#14aaff"));
    m_colors->insert(QLatin1String("green"), QVariant("#328930"));
    m_colors->insert(QLatin1String("qtgreen"), QVariant("#5caa15"));
    m_colors->insert(QLatin1String("black"), QVariant("#000000"));
    m_colors->insert(QLatin1String("gray_menu"), QVariant("#e5e5e5"));
    m_colors->insert(QLatin1String("white_menu"), QVariant("#ffffff"));

    m_sizes = new QQmlPropertyMap(this);
    m_sizes->insert(QLatin1String("trackHeaderHeight"), QVariant(applyRatio(270)));
    m_sizes->insert(QLatin1String("trackHeaderWidth"), QVariant(applyRatio(tempTrackHeaderWidth)));
    m_sizes->insert(QLatin1String("trackHeaderHeight_Event"), QVariant(applyRatio(135)));
    m_sizes->insert(QLatin1String("timeColumnWidth"), QVariant(applyRatio(tempTimeColumnWidth)));
    m_sizes->insert(QLatin1String("conferenceHeaderHeight"), QVariant(applyRatio(158)));
    m_sizes->insert(QLatin1String("dayWidth"), QVariant(applyRatio(150)));
    m_sizes->insert(QLatin1String("favoriteImageHeight"), QVariant(applyRatio(76)));
    m_sizes->insert(QLatin1String("favoriteImageWidth"), QVariant(applyRatio(80)));
    m_sizes->insert(QLatin1String("titleHeight"), QVariant(applyRatio(60)));
    m_sizes->insert(QLatin1String("backHeight"), QVariant(applyRatio(74)));
    m_sizes->insert(QLatin1String("backWidth"), QVariant(applyRatio(42)));
    m_sizes->insert(QLatin1String("logoHeight"), QVariant(applyRatio(100)));
    m_sizes->insert(QLatin1String("logoWidth"), QVariant(applyRatio(286)));
    m_sizes->insert(QLatin1String("menuHeight"), QVariant(applyRatio(62)));
    m_sizes->insert(QLatin1String("menuWidth"), QVariant(applyRatio(78)));
    m_sizes->insert(QLatin1String("dayLabelHeight"), QVariant(applyRatio(70)));
    m_sizes->insert(QLatin1String("upcomingEventHeight"), QVariant(applyRatio(130)));
    m_sizes->insert(QLatin1String("homeTitleHeight"), QVariant(applyRatio(70)));
    m_sizes->insert(QLatin1String("upcomingEventTimeWidth"), QVariant(applyRatio(240)));
    m_sizes->insert(QLatin1String("trackFieldHeight"), QVariant(applyRatio(50)));
    m_sizes->insert(QLatin1String("buttonHeight"), QVariant(applyRatio(130)));
    m_sizes->insert(QLatin1String("buttonWidth"), QVariant(applyRatio(400)));
    m_sizes->insert(QLatin1String("buttonHeightFeedback"), QVariant(applyRatio(110)));
    m_sizes->insert(QLatin1String("buttonWidthFeedback"), QVariant(applyRatio(330)));
    m_sizes->insert(QLatin1String("ratingImageHeight"), QVariant(applyRatio(57)));
    m_sizes->insert(QLatin1String("ratingImageWidth"), QVariant(applyRatio(60)));
    m_sizes->insert(QLatin1String("infoButtonSize"), QVariant(applyRatio(160)));
    m_sizes->insert(QLatin1String("reloadButtonSize"), QVariant(applyRatio(50)));
    m_sizes->insert(QLatin1String("twitterAvatarSize"), QVariant(applyRatio(80)));
    m_sizes->insert(QLatin1String("menuPopupWidth"), QVariant(applyRatio(550)));
    m_sizes->insert(QLatin1String("menuItemHeight"), QVariant(applyRatio(110)));

    m_images = new QQmlPropertyMap(this);
    m_images->insert(QLatin1String("back"), QVariant("qrc:/images/BackArrow.svg"));
    m_images->insert(QLatin1String("menu"), QVariant("qrc:/images/Menu.svg"));
    m_images->insert(QLatin1String("logo"), QVariant("qrc:/images/DevDaysLogo.svg"));
    m_images->insert(QLatin1String("favorite"), QVariant("qrc:/images/StarSelected.svg"));
    m_images->insert(QLatin1String("notFavorite"), QVariant("qrc:/images/Star.svg"));
    m_images->insert(QLatin1String("noRating"), QVariant("qrc:/images/NoRating.svg"));
    m_images->insert(QLatin1String("loading"), QVariant("qrc:/images/icon-loading.svg"));
    m_images->insert(QLatin1String("anonymous"), QVariant("qrc:/images/anonymous.svg"));
    m_images->insert(QLatin1String("twitter"), QVariant("qrc:/images/Twitter.svg"));
    m_images->insert(QLatin1String("levelA"), QVariant("qrc:/images/LevelA.svg"));
    m_images->insert(QLatin1String("levelB"), QVariant("qrc:/images/LevelB.svg"));
    m_images->insert(QLatin1String("levelC"), QVariant("qrc:/images/LevelC.svg"));
    m_images->insert(QLatin1String("sfoFloor"), QVariant("qrc:/images/sfo_floor.png"));

    m_fonts = new QQmlPropertyMap(this);
    m_fonts->insert(QLatin1String("six_pt"), QVariant(applyFontRatio(9)));
    m_fonts->insert(QLatin1String("seven_pt"), QVariant(applyFontRatio(10)));
    m_fonts->insert(QLatin1String("eight_pt"), QVariant(applyFontRatio(12)));
    m_fonts->insert(QLatin1String("ten_pt"), QVariant(applyFontRatio(14)));
    m_fonts->insert(QLatin1String("twelve_pt"), QVariant(applyFontRatio(16)));

    m_margins = new QQmlPropertyMap(this);
    m_margins->insert(QLatin1String("five"), QVariant(applyRatio(5)));
    m_margins->insert(QLatin1String("seven"), QVariant(applyRatio(7)));
    m_margins->insert(QLatin1String("ten"), QVariant(applyRatio(10)));
    m_margins->insert(QLatin1String("fifteen"), QVariant(applyRatio(15)));
    m_margins->insert(QLatin1String("twenty"), QVariant(applyRatio(20)));
    m_margins->insert(QLatin1String("thirty"), QVariant(applyRatio(30)));
    m_margins->insert(QLatin1String("forty"), QVariant(applyRatio(40)));
}

int Theme::applyFontRatio(const int value)
{
    return int(value * m_ratioFont);
}

int Theme::applyRatio(const int value)
{
    return qMax(2, int(value * m_ratio));
}
