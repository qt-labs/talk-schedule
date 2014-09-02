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
import QtQuick.Layouts 1.1
import TalkSchedule 1.0

Rectangle {
    id: eventView
    property string eventId
    signal selectFavorite(bool favorite)

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
        titleText: Theme.text.talks
    }

    Flickable {
        id: flickable
        anchors.top: subTitle.bottom
        anchors.bottom: statusBar.top
        anchors.left: subTitle.left
        anchors.right: subTitle.right
        anchors.topMargin: 20
        anchors.bottomMargin: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        contentHeight: columnLayout.height
        clip: true
        Column {
            id: columnLayout
            width: parent.width
            spacing: 10
            Text {
                text: model.data(indexCurrentEvent, "topic")
                color: Theme.colors.black
                width: columnLayout.width
                font.pixelSize: 32
                maximumLineCount: 2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }
            Label {
                id: eventPerformers
                text: model.data(indexCurrentEvent, "performer")
                font.pixelSize: 20
                font.capitalization: Font.AllUppercase
                color: Theme.colors.gray
            }
            Item {
                id: separator
                height: 10
                width: 100
            }
            Label {
                id: eventIntro
                text: model.data(indexCurrentEvent, "intro")
                font.pixelSize: 19
                width: parent.width
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                color: Theme.colors.gray
            }
            Item {
                height: 10
                width: 100
            }
            Label {
                id: eventTags
                text: model.data(indexCurrentEvent, "tags")
                font.pixelSize: 19
                color: Theme.colors.green
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: stack.pop()

        }
    }

    RowLayout {
        id: statusBar
        anchors.bottom: eventView.bottom
        width: eventView.width
        height: Theme.sizes.trackHeaderHeight
        spacing: 5
        Rectangle {
            id: trackSquare
            Layout.preferredHeight: Theme.sizes.trackHeaderHeight
            Layout.preferredWidth: Theme.sizes.trackHeaderWidth
            color: track.backgroundColor
            Text {
                anchors.fill: parent
                anchors.margins: 10
                text: track.name
                color: track.fontColor
                font.pixelSize: 20
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.AllUppercase
            }
        }
        Rectangle {

            Layout.fillWidth: true
            color: Theme.colors.smokewhite
            height: statusBar.height
            RowLayout {
                id: statusBar2
                anchors.fill: parent
                anchors.leftMargin: 10
                Label {
                    height: parent.height
                    text: Qt.formatTime(model.data(indexCurrentEvent, "start"), "hh:mm") + " - " + Qt.formatTime(model.data(indexCurrentEvent, "end"), "hh:mm")
                    color: Theme.colors.gray
                    font.pixelSize: 20
                }
                Label {
                    text: model.data(indexCurrentEvent, "location")
                    height: parent.height
                    color: Theme.colors.darkgray
                    font.pixelSize: 20
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
