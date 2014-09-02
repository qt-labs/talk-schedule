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
    id: topSwitcher
    property string dayId
    property int daysCount: 0
    property int margins: 30
    color: Theme.colors.smokewhite

    GridLayout {
        id: dayRow
        anchors.fill: parent
        anchors.leftMargin: margins
        anchors.rightMargin: margins
        columns: daysCount * 2 + 3
        rows: 2
        Item { Layout.fillWidth: true; width: 5; Layout.preferredHeight: 1 }
        Label {
            id: locationLabel
            text: ModelsSingleton.conferenceLocation
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 14
            font.capitalization: Font.AllUppercase
            color: Theme.colors.black
            Layout.fillWidth: false
            Layout.alignment: Text.AlignVCenter | Text.AlignHCenter
        }
        Repeater {
            model: daysCount * 2
            Label {
                id: label
                property bool isDivider: Functions.isEvenNumber(index)
                property string currentDayId: isDivider ? "invalid" : dayModel.get((index-1)/2, "id")
                font.pointSize: 14
                text: isDivider ? "|" : Qt.formatDate(dayModel.get((index-1)/2, "date"), "ddd dd.MM")
                font.capitalization: Font.AllUppercase
                font.weight: dayId === currentDayId ? Font.DemiBold : Font.Normal
                height: topSwitcher.height
                color: isDivider ? Theme.colors.gray :
                                   dayId === currentDayId ? Theme.colors.blue : Theme.colors.black
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: false
                MouseArea  {
                    enabled: !label.isDivider
                    anchors.fill: parent
                    onClicked: if (!label.isDivider) dayId = currentDayId
                }
                Layout.alignment: Text.AlignVCenter | Text.AlignHCenter
            }
        }
        Item { Layout.fillWidth: true; width: 5; Layout.preferredHeight: 1 }
        Item { Layout.fillWidth: true; width: 5; Layout.preferredHeight: 1 }
        Repeater {
            model: daysCount * 2 + 1
            Item {
                property bool isDivider: !Functions.isEvenNumber(index)
                property int expectedWidth: Theme.sizes.dayWidth
                Layout.preferredWidth: isDivider ? 5 : (index === 0 ) ?  expectedWidth/2 : expectedWidth
                Layout.preferredHeight: 1
            }
        }
        Item { Layout.fillWidth: true; width: 5; Layout.preferredHeight: 1 }
    }

    SortFilterModel {
        id: dayModel
        sortRole: "date"
        model: ModelsSingleton.day
        Component.onCompleted: {
            dayId = dayModel.get(0,"id")
            daysCount = dayModel.rowCount()
        }
    }

    // Keep the connection in case the model would not be ready at startup
    Connections {
        target: ModelsSingleton.day
        onDataReady: {
            dayModel.model = ModelsSingleton.day
            dayId = dayModel.get(0,"id")
            daysCount = dayModel.rowCount()
        }
    }
}
