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

Rectangle {
    id: root
    objectName: "trackSwitcher"
    property bool isViewScrolling: false
    property var firstEvent
    color: Theme.colors.white

    DaySwitcher {
        id: daysWitcher
        anchors.top: parent.top
        width: parent.width
        height: Theme.sizes.titleHeight
    }

    SortFilterModel{
        id: currentDayTracksModel
        sortRole: "trackNumber"
        filterRole: "day"
        filterRegExp: new RegExp(daysWitcher.dayId)
        model: ModelsSingleton.trackModel
        function data(index, role)
        {
            return get(index, role)
        }
    }
    SortFilterModel {
        id: currentDayBreaksModel
        model: ModelsSingleton.breakModel
        sortRole: "start"
        filterRole: "day"
        filterRegExp: new RegExp(daysWitcher.dayId)
        function data(index, role)
        {
            return get(index, role)
        }
    }

    // Keep the connection in case the model would not be ready at startup
    Connections {
        target: ModelsSingleton.trackModel
        onDataReady: currentDayTracksModel.model = ModelsSingleton.trackModel
    }

    Connections {
        target: ModelsSingleton.breakModel
        onDataReady: currentDayBreaksModel.model = ModelsSingleton.breakModel
    }

    Connections {
        target: daysWitcher
        onDayIdChanged: {
            ModelsSingleton.timeListModel.fileNameTag = "TimeObject." + daysWitcher.dayId
            ModelsSingleton.timeListModel.load()
            ModelsSingleton.timeListModel.tracksTodayModel = currentDayTracksModel
        }
    }

    function setFirstEvent(time)
    {
        if (!Functions.isStartTimeAfterNow(firstEvent)) {
            if (time < firstEvent || Functions.isStartTimeAfterNow(time))
                firstEvent = time
        } else {
            if (time < firstEvent && Functions.isStartTimeAfterNow(time))
                firstEvent = time
        }
    }

    function getTimeRange(model)
    {
        var isEndTime = true
        var earliestTime = model.data(0, "start")
        if (firstEvent === undefined)
            firstEvent = earliestTime
        setFirstEvent(earliestTime)
        var latestTime = model.data(0, "end") // earliestTime
        var time

        var timeHours
        var earliestHours = Functions.getHour(earliestTime)
        var latestHours = Functions.getHour(latestTime, isEndTime)

        // Count here what is the first hour and last hour that needs to be shown in time listView
        // for example 10.00 11.00 12.00 ... or 08.00 09.00 10.00
        var modelCountAfterStart = model.rowCount() - 1;
        var halfModelCount = Math.floor(modelCountAfterStart / 2)
        var needOneMoreItem = halfModelCount * 2 !== modelCountAfterStart
        for (var i = 1; i < halfModelCount; i++) {

            var time1 = model.data(i*2 - 1, "start")
            setFirstEvent(time1)
            var time2 = model.data(i*2, "start")
            setFirstEvent(time2)

            time = time1 < time2 ? time1 : time2
            timeHours = Functions.getHour(time)
            earliestHours = Functions.getHour(earliestTime)
            if (timeHours < earliestHours )
                earliestTime = time

            time1 = model.data(i*2 - 1, "end")
            time2 = model.data(i*2, "end")
            time = time1 < time2 ? time2 : time1
            timeHours = Functions.getHour(time, isEndTime)
            latestHours = Functions.getHour(latestTime, isEndTime)
            if (timeHours > latestHours)
                latestTime = time
        }

        if (needOneMoreItem) {
            time = model.data(model.rowCount() - 1, "start")
            setFirstEvent(time)
            timeHours = Functions.getHour(time)
            earliestHours = Functions.getHour(earliestTime)
            if (timeHours < earliestHours )
                earliestTime = time

            time = model.data(model.rowCount() - 1, "end")
            timeHours = Functions.getHour(time, isEndTime)
            latestHours = Functions.getHour(latestTime, isEndTime)
            if (timeHours > latestHours)
                latestTime = time
        }

        var temp = []
        var timeCount = Functions.getHour(latestTime, isEndTime) - Functions.getHour(earliestTime)
        var hours = Functions.getHour(earliestTime)

        for (var j = 0; j <= timeCount; j++) {
            var date = new Date
            date.setHours(hours + j)
            // HACK, ISOString ignores timezone offset, so add it to date
            date.setHours(date.getHours()+ date.getHours() - date.getUTCHours())
            date.setMinutes(0)
            temp.push(date.toISOString())
        }

        return temp
    }

    Connections {
        target: ModelsSingleton.timeListModel
        onDataReady: {
            firstEvent = undefined
            flickable1.contentX = 0
            var temp = []
            var tempTimeEvents = []
            var tempTimeBreaks = []
            if (ModelsSingleton.timeListModel.rowCount() > 0)
                tempTimeEvents = getTimeRange(ModelsSingleton.timeListModel)
            if (currentDayBreaksModel.rowCount() > 0)
                tempTimeBreaks = getTimeRange(currentDayBreaksModel)

            if (tempTimeBreaks.length > 0) {
                var firstEventTime = Functions.getHour(tempTimeEvents[0])
                var lastEventTime = Functions.getHour(tempTimeEvents[tempTimeEvents.length - 1], true)
                var firstBreakTime = Functions.getHour(tempTimeBreaks[0])
                var lastBreakTime = Functions.getHour(tempTimeBreaks[tempTimeBreaks.length - 1], true)

                var earliestTime = firstEventTime < firstBreakTime ? tempTimeEvents[0] : tempTimeBreaks[0]
                var latestTime = lastEventTime < lastBreakTime ? tempTimeBreaks[tempTimeBreaks.length - 1] : tempTimeEvents[tempTimeEvents.length - 1]

                var timeCount = Functions.getHour(latestTime, true) - Functions.getHour(earliestTime)
                var hours = Functions.getHour(earliestTime)

                for (var j = 0; j <= timeCount; j++) {
                    var date = new Date
                    date.setHours(hours + j)
                    // HACK, ISOString ignores timezone offset, so add it to date
                    date.setHours(date.getHours()+ date.getHours() - date.getUTCHours())
                    date.setMinutes(0)
                    temp.push(date.toISOString())
                }
            } else {
                temp = tempTimeEvents
            }

            timeColumn.timeList = temp
            if (!!firstEvent)
                flickable1.contentX = Functions.countTrackPosition(firstEvent)
        }
    }

    TrackHeader {
        id: trackHeader
        z: 3
        anchors.top: daysWitcher.bottom
        anchors.topMargin: Theme.sizes.dayLabelHeight
        anchors.left: parent.left
        width: Theme.sizes.trackHeaderWidth
        model: currentDayTracksModel
        height: listView.height
    }

    Flickable {
        id: flickable1
        anchors.left: trackHeader.right
        anchors.top: daysWitcher.bottom
        height: parent.height
        width: root.width
        clip: true
        contentWidth: timeColumn.width
        flickableDirection: Flickable.HorizontalFlick
        Column {
            spacing: 0
            Row {
                id: timeColumn
                property var timeList: []
                height: Theme.sizes.dayLabelHeight
                z: 2
                Repeater {
                    id: timeColumnList
                    model: timeColumn.timeList
                    delegate: Rectangle {
                        color: Theme.colors.white
                        width: Theme.sizes.timeColumnWidth
                        height: timeColumn.height
                        Text {
                            id: repeaterText;
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pointSize: Theme.fonts.seven_pt
                            text: Qt.formatTime(timeColumn.timeList[index], "h:mm")
                        }
                    }
                }
            }
            ListView {
                id: listView
                height: root.height - daysWitcher.height - timeColumn.height
                width: parent.width
                interactive: true
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                delegate: Track {}
                model: currentDayTracksModel
                Component.onCompleted: breakColumn.height = listView.contentHeight
                Item {
                    id: breakColumn
                    z: 2
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width
                    Repeater {
                        id: breaks
                        model: currentDayBreaksModel
                        Rectangle {
                            color: mouseArea.pressed ? Theme.colors.lightgray : Theme.colors.smokewhite
                            anchors.top: breakColumn.top
                            x: Functions.countTrackPosition(start)
                            width: Functions.countTrackWidth(start, end) - Theme.margins.ten
                            height: Math.min(breakColumn.height, listView.contentHeight - Theme.margins.ten)
                            Text {
                                function info()
                                {
                                    var info = name +  "\n" + Qt.formatTime(start, "h:mm") + " - " + Qt.formatTime(end, "h:mm")
                                    if (!!performer)
                                        info = info + "\n" + Theme.text.by.arg(performer)
                                    if (!!room)
                                        info = info + "\n" + Theme.text.room.arg(room)
                                    return info
                                }

                                width: parent.width
                                verticalAlignment: Text.AlignVCenter
                                height: parent.height
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: Theme.fonts.seven_pt
                                text: info()
                                color: Theme.colors.darkgray
                            }
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                enabled: !!associatedEventId
                                onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"eventId" : associatedEventId}})
                            }
                        }
                    }
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
