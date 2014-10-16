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

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import TalkSchedule 1.0

Rectangle {
    id: eventView
    property string eventId
    signal selectFavorite(bool favorite)
    objectName: "event"

    property var indexCurrentEvent: ModelsSingleton.eventModel.indexOf("id", eventId)
    property var model: ModelsSingleton.eventModel
    property var favorite: model.data(indexCurrentEvent, "favorite")
    property var track: model.data(indexCurrentEvent, "tracks")

    color: Theme.colors.white

    Connections {
        target: ModelsSingleton.eventModel
        onDataChanged: favorite = model.data(indexCurrentEvent, "favorite")
    }

    SubTitle {
        id: subTitle
        titleText: Theme.text.details
    }

    Flickable {
        id: flickable
        anchors.top: subTitle.bottom
        anchors.bottom: statusBar.top
        anchors.left: subTitle.left
        anchors.right: subTitle.right
        anchors.topMargin: Theme.margins.twenty
        anchors.bottomMargin: Theme.margins.twenty
        anchors.leftMargin: Theme.margins.ten
        anchors.rightMargin: Theme.margins.ten
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: columnLayout.height
        clip: true
        Column {
            id: columnLayout
            width: parent.width
            spacing: Theme.margins.twenty
            Text {
                text: model.data(indexCurrentEvent, "topic")
                color: Theme.colors.black
                width: columnLayout.width
                font.pointSize: Theme.fonts.ten_pt
                maximumLineCount: 2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }
            Label {
                id: eventPerformers
                text: model.data(indexCurrentEvent, "performer")
                font.pointSize: Theme.fonts.eight_pt
                color: Theme.colors.gray
            }
            Button {
                id: buttonFeedback
                text: Theme.text.feedback
                height: Theme.sizes.buttonHeightFeedback
                width: Theme.sizes.buttonWidthFeedback
                style: ButtonStyle {
                    background: Rectangle {
                        border.width: 2
                        border.color: Theme.colors.qtgreen
                        color: control.pressed ? Qt.darker(Theme.colors.qtgreen, 1.1) : Theme.colors.qtgreen
                    }
                    label: Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: control.text
                        color: Theme.colors.white
                        font.capitalization: Font.AllUppercase
                        font.pointSize: Theme.fonts.seven_pt
                    }
                }
                onClicked: {
                    var itemFe = Qt.resolvedUrl("Feedback.qml")
                    stack.push({
                                   "item" : itemFe,
                                   "properties" : {
                                       "eventId" : eventId,
                                       "eventPerformer": model.data(indexCurrentEvent, "performer"),
                                       "eventTopic": model.data(indexCurrentEvent, "topic")
                                   }
                               })
                }
            }
            Item {
                id: separator
                height: Theme.margins.ten
                width: parent.width
            }
            Label {
                id: eventIntro
                text: model.data(indexCurrentEvent, "intro")
                font.pointSize: Theme.fonts.eight_pt
                width: parent.width
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                color: Theme.colors.gray
            }
            Item {
                height: Theme.margins.ten
                width: parent.width
            }
            Label {
                id: eventTags
                text: model.data(indexCurrentEvent, "tags")
                font.pointSize: Theme.fonts.seven_pt
                color: Theme.colors.green
            }
        }
    }

    RowLayout {
        id: statusBar
        anchors.bottom: eventView.bottom
        width: eventView.width
        height: Theme.sizes.trackHeaderHeight_Event
        spacing: Theme.margins.ten
        baselineOffset: Theme.sizes.trackHeaderHeight_Event*4/9
        Rectangle {
            id: trackSquare
            Layout.fillHeight: true
            Layout.preferredWidth: Theme.sizes.trackHeaderWidth
            color: track.backgroundColor
            baselineOffset: parent.baselineOffset
            Text {
                id: trackName
                anchors.left: parent.left
                anchors.leftMargin: Theme.margins.ten
                text: track.name
                color: track.fontColor
                font.pointSize: Theme.fonts.seven_pt
                horizontalAlignment: Text.AlignLeft
                anchors.baseline: parent.baseline
                font.capitalization: Font.AllUppercase
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.colors.smokewhite
            baselineOffset: parent.baselineOffset
            RowLayout {
                id: statusBar2
                anchors.fill: parent
                anchors.leftMargin: Theme.margins.ten
                baselineOffset: parent.baselineOffset
                Label {
                    height: parent.height
                    text: Qt.formatDate(model.data(indexCurrentEvent, "start"), "dddd d. MMM") +
                          "\n" +
                          Qt.formatTime(model.data(indexCurrentEvent, "start"), "hh:mm") +
                          " - " +
                          Qt.formatTime(model.data(indexCurrentEvent, "end"), "hh:mm")
                    color: Theme.colors.gray
                    font.pointSize: Theme.fonts.seven_pt
                    font.capitalization: Font.AllUppercase
                    anchors.baseline: parent.baseline
                }
                Label {
                    anchors.baseline: parent.baseline
                    text: Theme.text.room.arg(model.data(indexCurrentEvent, "location"))
                    height: parent.height
                    color: mouseRoom.pressed ? Theme.colors.green : Theme.colors.qtgreen
                    font.pointSize: Theme.fonts.eight_pt
                    MouseArea {
                        id: mouseRoom
                        anchors.fill: parent
                        onClicked: window.showFloor()
                    }
                }
                Item {
                    Layout.alignment: Qt.AlignRight
                    height: statusBar.height
                    width: statusBar.height
                    Image {
                        id: favorImage
                        anchors.centerIn: parent
                        source: favorite ? Theme.images.favorite : Theme.images.notFavorite
                        width: Theme.sizes.favoriteImageWidth
                        height: Theme.sizes.favoriteImageHeight
                        sourceSize.height: Theme.sizes.favoriteImageHeight
                        sourceSize.width: Theme.sizes.favoriteImageWidth
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: favorite ? ModelsSingleton.removeFavorite(eventId) : ModelsSingleton.saveFavorite(eventId)
                    }
                }
            }
        }
    }
}
