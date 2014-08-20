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
import TalkSchedule 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

Item {
    width: root.width
    height: root.height

    property int minTrackHeight: 120
    property int maxTrackHeight: 200

    property int trackHeight: Math.max(minTrackHeight, Math.min(maxTrackHeight, Math.floor((window.height - header.height - subTitle.height)/5)));

    SubTitle {
        id: subTitle
        titleText: Theme.text.favorites
    }

    ListView {
        id: favoriteList
        interactive: true
        anchors.top: subTitle.bottom
        anchors.topMargin: 5
        height: parent.height - subTitle.height - 75 // header height
        width: parent.width
        clip: true

        delegate: Item {
            property bool isDayLabelVisible:  itemHeight()
            property int labelHeight: isDayLabelVisible ? 35 : 5
            property bool colliding: isColliding()
            height: trackHeight + labelHeight
            width: parent.width
            Label {
                id: dayLabel
                height: labelHeight
                width: parent.width
                anchors.leftMargin: 10
                text: isDayLabelVisible ? Qt.formatDate(events_start, "dddd d.M.yyyy") : ""
                font.family: "Open Sans"
                font.pixelSize: 20
                font.capitalization: Font.AllUppercase
            }
            RowLayout {
                id: rowLayout
                height: trackHeight
                width: parent.width
                anchors.top: dayLabel.bottom
                //anchors.margins: 10
                Rectangle {
                    id: trackHeader
                    height: parent.height
                    width: 100
                    color:events_tracks.backgroundColor

                    Text {
                        anchors { fill: parent;  margins: 10 }
                        text: events_tracks.name
                        color: events_tracks.fontColor
                        font.family: "Open Sans"
                        fontSizeMode: Text.Fit
                        font.pixelSize: 20
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    color: Qt.rgba(255,255,255)
                    height: parent.height
                    width: parent.width

                    ColumnLayout {
                        id: eventColumn
                        anchors.fill: parent
                        anchors.margins: 20

                        // For some reason word wrap does not work correctly
                        // if Text not inside Item
                        Item {
                            width: parent.width - 20
                            height: 50
                            Text {
                                text: events_topic
                                color: "black"
                                width: parent.width
                                font.family: "Open Sans"
                                font.pixelSize: 25
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                            }
                        }
                        Text {
                            text: events_performer
                            color: "#666666"
                            width: parent.width - 20
                            font.family: "Open Sans"
                            font.pixelSize: 14
                            font.capitalization: Font.AllUppercase
                            maximumLineCount: 1
                        }
                        RowLayout{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            Text {
                                text: Qt.formatTime(events_start, "h:mm") + " - " + Qt.formatTime(events_end, "h:mm")
                                color: colliding ? "#ff00ff" : "#666666"
                                font.pixelSize: 14
                                font.underline: colliding ? true : false
                            }
                            Text {
                                text: " I "
                                color: "#666666"
                                font.family: "Open Sans"
                                font.pixelSize: 14
                                font.capitalization: Font.AllUppercase
                            }
                            Text {
                                text: events_tracks.location
                                Layout.fillWidth: true
                                color: "#666666"
                                font.family: "Open Sans"
                                font.pixelSize: 14
                                font.capitalization: Font.AllUppercase
                                maximumLineCount: 1
                                wrapMode: Text.WrapAnywhere
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Item {
                // Add this imageArea to make it easier to click the image
                id: imageArea
                anchors.bottom: rowLayout.bottom
                anchors.right: rowLayout.right
                width: 80
                height: 80
                Image {
                    id: favoriteImage
                    anchors.bottom: imageArea.bottom
                    anchors.right: imageArea.right
                    source: window.favoriteImage
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("start to remove favorite.."+events_id)
                        window.removeFavorite(events_id)
                    }
                }
            }
            Image {
                id: collideImage
                anchors.top: rowLayout.top
                anchors.right: rowLayout.right
                source: isColliding() ? "qrc:/image/collide" : ""
            }

            function isColliding()
            {
                var currentTimeEnd = new Date(events_end)
                var currentTimeStart = new Date(events_start)
                if (sortModel.rowCount() > index+1) {
                    var nextTimeStart = new Date(sortModel.get((index + 1), "events_start"))
                    //    console.log("nextTimeStart "+nextTimeStart)
                    if (currentTimeEnd > nextTimeStart) {
                        //    console.log("time collide with previous item\n")
                        return true
                    }
                }

                if (index - 1 >= 0) {
                    var earlierTimeEnd = new Date(sortModel.get(index - 1, "events_end"))
                    //    console.log("erlier event ends "+earlierTimeEnd)
                    if (earlierTimeEnd > currentTimeStart) {
                        //      console.log("time collide with next item\n")
                        return true
                    }
                }
                return false
            }

            function itemHeight()
            {
                if (index === 0) {
                    //   console.log("first item, sow date")
                    return true
                }
                else if (index > 0) {
                    var date = Qt.formatDate(events_start, "dddd d.M.yyyy")

                    var date2 = Qt.formatDate(sortModel.get(index - 1, "events_start"), "dddd d.M.yyyy")
                    if (date2 != date ) {
                        return true
                    }
                    else{
                        return false
                    }
                }
                return false
            }

            MouseArea {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: imageArea.left
                }
                onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"eventId" : events_id}})
            }
        }

        model: SortFilterModel {
            id:sortModel;
            sortRole: "events_start"
            model: window.favoriteModel
        }

        Connections {
            target: window
            ignoreUnknownSignals: true
            onUpdateFavoriteSignal: {
                sortModel.model = window.favoriteModel
            }
        }
    }
}
