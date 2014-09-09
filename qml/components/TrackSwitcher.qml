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

Item {
    id: root
    objectName: "trackSwitcher"
    property bool isViewScrolling: false
    property var firstEvent

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
        target: daysWitcher
        onDayIdChanged: ModelsSingleton.timeListModel.tracksTodayModel = currentDayTracksModel
    }

    function getTimeRange(model)
    {
        var earliestTime = model.data(0, "start")
        if (Functions.isStartTimeAfterNow(earliestTime)) {
            if (firstEvent === undefined || earliestTime < firstEvent)
                firstEvent = earliestTime
        }
        var latestTime = model.data(0, "end") // earliestTime
        var time

        var timeHours
        var earliestHours = Functions.getHour(earliestTime)
        var latestHours = Functions.getHour(latestTime)

        // Count here what is the first hour and last hour that needs to be shown in time listView
        // for example 10.00 11.00 12.00 ... or 08.00 09.00 10.00
        for (var i = 0; i < model.rowCount(); i++) {

            time = model.data(i, "start")
            if (firstEvent === undefined && Functions.isStartTimeAfterNow(time))
                firstEvent = time

            timeHours = Functions.getHour(time)
            earliestHours = Functions.getHour(earliestTime)

            if (timeHours < earliestHours )
                earliestTime = time

            time = model.data(i, "end")
            timeHours = Functions.getHour(time)
            var timeMinutes = Functions.getMinutes(time)
            if (timeMinutes > 0)
                timeHours = timeHours + 1
            latestHours = Functions.getHour(latestTime)
            if (timeHours > latestHours)
                latestTime = time
        }

        var temp = []
        var timeCount = Functions.getHour(latestTime) - Functions.getHour(earliestTime)
        timeMinutes = Functions.getMinutes(latestTime)
        if (timeMinutes > 0)
            timeCount = timeCount + 1
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
            temp = tempTimeEvents
            if (currentDayBreaksModel.rowCount() > 0)
                tempTimeBreaks = getTimeRange(currentDayBreaksModel)
            var firstEventTime = Functions.getHour(tempTimeEvents[0])
            var lastEventTime = Functions.getHour(tempTimeEvents[tempTimeEvents.length - 1], true)
            var earlierTime = []
            var afterTime = []
            for (var i = 0; i < tempTimeBreaks.length; i++) {
                var breakTimeStart = Functions.getHour(tempTimeBreaks[i])
                var breakTimeEnd = Functions.getHour(tempTimeBreaks[i], true)
                if (breakTimeStart < firstEventTime)
                    earlierTime.push(tempTimeBreaks[i])
                if (breakTimeEnd > lastEventTime)
                    afterTime.push(tempTimeBreaks[i])
            }
            temp = earlierTime.concat(temp)
            temp = temp.concat(afterTime)
            timeColumn.timeList = temp
            if (!!firstEvent)
                flickable1.contentX = Functions.countTrackPosition(firstEvent)
        }
    }

    Item {
        id: breakData
        property real trackScrolling: 0
        anchors.fill: rowLayout
        Item {
            id: breakColumn
            anchors.top: parent.top
            anchors.topMargin: Theme.sizes.dayLabelHeight
            anchors.right: parent.right
            height: Math.min(parent.height - Theme.sizes.dayLabelHeight,
                             listView.contentHeight)
            width: parent.width - Theme.sizes.trackHeaderWidth
            Repeater {
                id: breaks
                model: currentDayBreaksModel
                Rectangle {
                    color: Theme.colors.smokewhite
                    anchors.top: breakColumn.top
                    x: Functions.countTrackPosition(start) - breakData.trackScrolling
                    width: Functions.countTrackWidth(start, end) - Theme.margins.five
                    anchors.bottom: breakColumn.bottom
                    Text {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 20
                        text: name +  "\n" + Qt.formatTime(start, "hh:mm") + " - " + Qt.formatTime(end, "hh:mm")
                        color: Theme.colors.gray
                    }
                }
            }
        }
    }

    Row {
        id: rowLayout
        anchors.fill: parent
        anchors.topMargin: daysWitcher.height
        Column{
            // Add this empty item so track won't overlap with time line
            Item {
                height: Theme.sizes.dayLabelHeight
                width: Theme.margins.ten
            }
            TrackHeader {
                id: trackHeader
                model: currentDayTracksModel
            }
        }

        Flickable {
            id: flickable1
            height: rowLayout.height
            width: root.width
            clip: true
            contentWidth: timeColumn.width
            flickableDirection: Flickable.HorizontalFlick
            onContentXChanged: breakData.trackScrolling = flickable1.contentX
            Column {
                spacing: 0
                Row {
                    id: timeColumn
                    property var timeList: []
                    height: Theme.sizes.dayLabelHeight
                    Repeater {
                        id: timeColumnList
                        model: timeColumn.timeList
                        delegate: Item {
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
}
