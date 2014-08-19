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
import QtQuick.Window 2.1
import QtQuick.Layouts 1.1
import qt.conclave.models 1.0

import Enginio 1.0
import "common.js" as Common
import "functions.js" as Functions

Item {
    id: root
    anchors.fill: parent

    property int timeColumnWidth: 200
    property int minTrackHeight: 130
    property int maxTrackHeight: 200
    property int trackHeight: Math.max(minTrackHeight, Math.min(maxTrackHeight, Math.floor((window.height - header.height - timeColumn.height - daysWitcher.height)/5)));
    property bool isViewScrolling: false
    property string confId: window.conferenceId

    DaySwitcher {
        id: daysWitcher
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 60
    }

    Row {
        id: rowLayout
        height: root.height - daysWitcher.height
        anchors.top: daysWitcher.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Column{
            // Add this empty item so track won't overlap with time line
            Item {
                height: timeColumn.height
                width: 100
            }

            TrackHeader {
                id: trackHeader
            }
        }
        Flickable {
            id: flickable1
            height: rowLayout.height
            width: root.width
            clip: true
            contentWidth: timeColumn.width // contentItem.childrenRect.width
            flickableDirection: Flickable.HorizontalFlick
            Column {
                anchors.fill: parent

                Row {
                    id: timeColumn
                    property var timeList: []
                    height: 35
                    Repeater {
                        id: timeColumnList

                        model: timeColumn.timeList

                        delegate: Item {
                            width: timeColumnWidth
                            height: timeColumn.height
                            Text {
                                id: repeaterText;
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                font.family: "Open Sans"
                                font.pixelSize: 25
                                text: Qt.formatTime(timeColumn.timeList[index], "h:mm")}
                        }
                    }
                    SortFilterModel {
                        id: tmp;
                        onModelChanged: {
                            if (tmp.rowCount() > 0) {
                                var earliestTime = tmp.get(0, "start")
                                var latestTime = tmp.get(0, "end") // earliestTime
                                var time

                                var timeHours
                                var earliestHours = Functions.getHour(earliestTime)
                                var latestHours = Functions.getHour(latestTime)

                                // Count here what is the first hour and last hour that needs to be shown in time listView
                                // for example 10.00 11.00 12.00 ... or 08.00 09.00 10.00
                                for (var i = 0; i < tmp.rowCount(); i++) {

                                    time = tmp.get(i, "start")
                                    timeHours = Functions.getHour(time)
                                    earliestHours = Functions.getHour(earliestTime)

                                    if (timeHours < earliestHours )
                                        earliestTime = time

                                    time = tmp.get(i, "end")
                                    timeHours = Functions.getHour(time)
                                    latestHours = Functions.getHour(latestTime)
                                    if (timeHours > latestHours)
                                        latestTime = time
                                }

                                var temp = []
                                var timeCount = Functions.getHour(latestTime) - Functions.getHour(earliestTime)
                                var hours = Functions.getHour(earliestTime)

                                for (var j = 0; j <= timeCount; j++) {
                                    var date = new Date
                                    date.setHours(hours + j)
                                    // HACK, ISOString ignores timezone offset, so add it to date
                                    date.setHours(date.getHours()+ date.getHours() - date.getUTCHours())
                                    date.setMinutes(0)
                                    temp.push(date.toISOString())
                                }
                                timeColumn.timeList = temp
                            }
                        }
                    }

                    Model {
                        id: timeListModel;
                        backendId: backId
                        Component.onCompleted: timeListModel.query({ "objectType": "objects.Event" ,
                                                                       "sort" : [{"sortBy": "start", "direction": "asc"}]});
                        onDataReady: tmp.model = timeListModel
                    }
                }
                ListView {
                    id: listView
                    height: root.height - daysWitcher.height - timeColumn.height - 70
                    width: parent.width
                    interactive: true
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Track {}

                    model: SortFilterModel {
                        id: tracks
                        filterRole: "day"
                        filterRegExp: new RegExp(daysWitcher.dayId)
                    }

                    Model {
                        id: trackModel;
                        backendId: backId
                        onDataReady: tracks.model = trackModel
                    }

                    onContentYChanged: {
                        if (isViewScrolling === false) {
                            isViewScrolling = true;
                            trackHeader.contentY = listView.contentY
                            isViewScrolling = false;
                        }
                    }
                }
            }
        }
    }

    onConfIdChanged: trackModel.query({"objectType": "objects.Track",
                                          "query": { "conference": { "id": confId,"objectType": "objects.Conference" } }});
}
