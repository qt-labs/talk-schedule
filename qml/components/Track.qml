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

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import TalkSchedule 1.0
import "functions.js" as Functions

ListView {
    id: trackList

    interactive: false
    height: trackHeight
    currentIndex: 0
    orientation: ListView.Horizontal
    clip: false

    delegate: Item {
        id: delegateItem
        height: trackList.height
        property bool isSelected: false
        property int trackWidth: Functions.countTrackWidth(start, end)

        Item {
            id: item
            height: trackList.height
            width: trackWidth
            x: Functions.countTrackPosition(start, topic)

            Rectangle {
                id: colorBackground
                anchors { fill: parent;  bottomMargin: 10; leftMargin: 10;}
                color: Qt.rgba(255,255,255)
            }
            Item {
                // Add this imageArea to make it easier to click the image
                id: imageArea
                anchors.bottom: colorBackground.bottom
                anchors.right: colorBackground.right
                width: 80
                height: 80
                Image {
                    id: favoriteImage
                    anchors.bottom: imageArea.bottom
                    anchors.right: imageArea.right
                    source: favorite ? window.favoriteImage : window.notFavoriteImage
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        if (favorite)
                            window.removeFavorite(id)
                        else
                            window.saveFavorite(id)
                    }
                }
            }

            // For some reason text wrap does not work as expected
            // if Text items are not placed inside Item.
            ColumnLayout {
                id: columnLayout
                anchors.fill: colorBackground
                height: trackList.height
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                Item {
                    width: columnLayout.width
                    height: 50
                    Text {
                        text: topic
                        color: "black"
                        width: columnLayout.width
                        font.family: "Open Sans"
                        font.pixelSize: 25
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                    }
                }
                Text {
                    text: performer
                    color: "#666666"
                    width: colorBackground.width - 20
                    font.family: "Open Sans"
                    font.pixelSize: 14
                    font.capitalization: Font.AllUppercase
                    maximumLineCount: 1
                }
                Item {
                    width: columnLayout.width
                    height: 50
                    Text {
                        width: columnLayout.width
                        text: Qt.formatTime(start, "h:mm") + " - " + Qt.formatTime(end, "h:mm") + " I " + location
                        color: "#666666"
                        font.family: "Open Sans"
                        font.pixelSize: 14
                        font.capitalization: Font.AllUppercase
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                    }
                }
            }

            MouseArea {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: imageArea.left
                }
                onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"eventId" : id}})
            }
        }
    }

    model: SortFilterModel {
        id:tmp;
        sortRole: "start"
        filterRole: "track"
        filterRegExp: new RegExp(id)
        model: window.eventModel
    }

    Connections {
        target: window
        ignoreUnknownSignals: true
        onUpdateFavoriteSignal: tmp.model = window.eventModel
    }
}
