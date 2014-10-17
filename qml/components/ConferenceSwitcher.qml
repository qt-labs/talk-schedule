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
import QtQuick.Controls.Styles 1.2

Rectangle {
    id: conferencesList
    objectName: "switchConf"
    signal initialConferenceSelected

    SubTitle {
        id: subTitle
        titleText: Theme.text.select_conference
    }

    ListView {
        interactive: false
        anchors.top: subTitle.bottom
        anchors.topMargin: Theme.margins.twenty
        height: parent.height - subTitle.height
        width: parent.width
        spacing: Theme.margins.ten
        model: SortFilterModel {
            id: sortModel
            sortRole: "title"
            model: applicationClient.conferencesModel
        }

        Connections {
            target: applicationClient.conferencesModel
            onDataReady: sortModel.model = applicationClient.conferencesModel
        }

        delegate: Item {
            width: parent.width
            height: Theme.sizes.buttonHeight
            Button {
                text: title
                anchors.centerIn: parent
                onClicked: {
                    var item = Qt.resolvedUrl("HomeScreen.qml")
                    var loadedHS = stack.find(function(item){ return item.objectName === "homeScreen" })
                    if (loadedHS !== null) {
                        stack.pop(loadedHS)
                        if (applicationClient.currentConferenceId !== id)
                            applicationClient.currentConferenceId = id
                    } else {
                        applicationClient.currentConferenceId = id
                        initialConferenceSelected()
                    }
                }
                width: Theme.sizes.buttonWidth
                height: Theme.sizes.buttonHeight
                style: ButtonStyle {
                    background: Rectangle {
                        border.width: 2
                        property var backgroundColor: applicationClient.currentConferenceId === id ? Theme.colors.qtgreen : Theme.colors.white
                        property var borderColor: Theme.colors.qtgreen
                        color: control.pressed ? Qt.darker(backgroundColor, 1.1) : backgroundColor
                        border.color: control.pressed ? Qt.darker(borderColor, 1.3) : borderColor
                    }
                    label: Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: control.text
                        color: applicationClient.currentConferenceId === id ? Theme.colors.white : Theme.colors.qtgreen
                        font.pointSize: Theme.fonts.seven_pt
                        font.capitalization: Font.AllUppercase
                    }
                }
            }
        }
    }

}
