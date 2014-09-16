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
import "functions.js" as Functions

Row {
    id: trackDelegate
    property int trackHeight: Theme.sizes.trackHeaderHeight
    height: !dayTracksModel.isEmpty ? trackHeight * (dayTracksModel.numberCollidingEvents + 1) : 0
    width: parent.width
    property string trackName: name
    visible: !dayTracksModel.isEmpty

    DayTracksModel {
        id: dayTracksModel
        dayId: id
        onIsReady: repeater1.model = rowsArray.length
    }

    Connections {
        target: ModelsSingleton.eventModel
        onDataReady: {
            dayTracksModel.modelTracks.model = ModelsSingleton.eventModel
            dayTracksModel.modelTracks.init()
        }
    }

    Column {
        id: column
        width: parent.width
        Repeater {
            id: repeater1
            Item {
                id: row
                width: parent.width
                property var rowModel: dayTracksModel.rowsArray[index]
                height: trackDelegate.trackHeight
                Repeater {
                    id: repeater
                    model: row.rowModel.length
                    Item {
                        id: item
                        property bool favorite: !!getData("favorite") ? getData("favorite") : false
                        property int trackWidth: Functions.countTrackWidth(getData("start"), getData("end"))
                        function getData(role) {
                            return dayTracksModel.modelTracks.get(row.rowModel[index], role)
                        }

                        Connections {
                            target: ModelsSingleton.eventModel
                            onDataChanged: favorite = !!getData("favorite") ? getData("favorite") : false
                        }

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: trackWidth
                        x: Functions.countTrackPosition(getData("start"))

                        Rectangle {
                            id: colorBackground
                            anchors { fill: parent; rightMargin: Theme.margins.ten; bottomMargin: index !== (listView.count - 1) ? Theme.margins.ten : 0}
                            color: mouseArea.pressed ? Theme.colors.lightgray : Theme.colors.smokewhite
                        }
                        Item {
                            // Add this imageArea to make it easier to click the image
                            id: imageArea
                            anchors.bottom: colorBackground.bottom
                            anchors.right: colorBackground.right
                            width: Theme.sizes.favoriteImageWidth + Theme.margins.twenty
                            height: Theme.sizes.favoriteImageHeight + Theme.margins.twenty
                            Image {
                                id: favoriteImage
                                anchors.centerIn: parent
                                source: favorite ? Theme.images.favorite : Theme.images.notFavorite
                                width: Theme.sizes.favoriteImageWidth
                                height: Theme.sizes.favoriteImageHeight
                                sourceSize.height: Theme.sizes.favoriteImageHeight
                                sourceSize.width: Theme.sizes.favoriteImageWidth
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked:{
                                    if (favorite)
                                        ModelsSingleton.removeFavorite(getData("id"))
                                    else
                                        ModelsSingleton.saveFavorite(getData("id"))
                                }
                            }
                        }
                        // For some reason text wrap does not work as expected
                        // if Text items are not placed inside Item.
                        ColumnLayout {
                            id: columnLayout
                            anchors.fill: colorBackground
                            height: trackDelegate.trackHeight
                            anchors.leftMargin: Theme.margins.ten
                            anchors.rightMargin: Theme.margins.ten
                            Item {
                                width: columnLayout.width
                                height: Theme.sizes.trackFieldHeight
                                Text {
                                    text: getData("topic")
                                    color: Theme.colors.black
                                    width: columnLayout.width
                                    font.pointSize: Theme.fonts.eight_pt
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                text: getData("performer")
                                color: Theme.colors.gray
                                width: colorBackground.width - Theme.margins.twenty
                                font.pointSize: Theme.fonts.seven_pt
                                maximumLineCount: 1
                            }
                            Item {
                                width: columnLayout.width
                                height: Theme.sizes.trackFieldHeight
                                Text {
                                    width: columnLayout.width - favoriteImage.width
                                    text: Qt.formatTime(getData("start"), "h:mm") + " - " + Qt.formatTime(getData("end"), "h:mm") + " I " + getData("location")
                                    color: Theme.colors.gray
                                    font.pointSize: Theme.fonts.seven_pt
                                    maximumLineCount: 3
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                        MouseArea {
                            id: mouseArea
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                                right: imageArea.left
                            }
                            onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"eventId" : getData("id")}})
                        }
                    }
                }
            }
        }
    }
}
