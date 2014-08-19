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

Rectangle {
    property string confId: window.conferenceId
    property string dayId

    color: "white"

    Rectangle {
        id: daySwitcher
        anchors.fill: parent
        color: "white"
        RowLayout {
            id: dayLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 20
            Label {
                id: dayLabel
                width: parent.width/2
                color: "black"
                font.family: "Open Sans"
                font.pixelSize: 22
                font.bold: true
                font.capitalization: Font.AllUppercase
                MouseArea  {
                    anchors.fill: parent
                    onClicked: {
                        dayId = dayModel.get(0,"id")
                        dayLabel.color = "black"
                        dayLabel.font.bold = true
                        dayLabel2.color = "grey"
                        dayLabel2.font.bold = false
                    }
                }
            }
            Label {
                id: divider
                color: "lightgray"
                font.family: "Open Sans"
                font.pixelSize: 22
                text: "|"
            }
            Label {
                id: dayLabel2
                width: parent.width/2
                color: "grey"
                font.family: "Open Sans"
                font.pixelSize: 22
                font.capitalization: Font.AllUppercase
                MouseArea  {
                    anchors.fill: parent
                    onClicked: {
                        if (dayModel.rowCount() > 1 ) {
                            dayId = dayModel.get(1,"id")
                            dayLabel.color = "grey"
                            dayLabel.font.bold = false
                            dayLabel2.color = "black"
                            dayLabel2.font.bold = true
                        }
                    }
                }
            }
        }
    }

    // TODO if there are more than two days, show rest of the days in dropdown list
    DropDownMenu {
        id: dropMenu
        anchors {
            top: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        delegate: ListItem {
            height: dropMenu.delegateHeight
            width: dropMenu.width
            Label {
                id: label
                anchors { fill: parent; margins: 3 }
                color: "white"
                font.family: "Open Sans"
                fontSizeMode: Text.Fit
                font.pixelSize: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDate(date, "ddd d.M.yyyy")
            }
            onClicked: {
                dayLabel.text = Qt.formatDate(date, "dddd d.M.yyyy")
                dayId = id
                dropMenu.close()
            }
        }
        model: SortFilterModel {
            id: dayModel;
            sortRole: "date"
        }

        Model {
            id: day
            backendId: backId
            onDataReady: {
                dayModel.model = day
                dayLabel.text = Qt.formatDate(dayModel.get(0,"date"), "dddd d.M.yyyy")
                if (day.rowCount() > 1 )
                    dayLabel2.text = Qt.formatDate(dayModel.get(1,"date"), "dddd d.M.yyyy")
                dayId = dayModel.get(0,"id")
            }
        }
        width: Math.min(window.width * 0.6, 400)
    }

    onConfIdChanged: {
        day.query({ "objectType": "objects.Day",
                      "query": {
                          "conference": {
                              "id": confId, "objectType": "objects.Conference"
                          }
                      }
                  })
    }
}
