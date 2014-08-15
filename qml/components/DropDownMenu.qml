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

Item {
    id: root

    property int delegateHeight: 65
    property int maxHeight: window.height * 0.8
    property alias model: list.model
    property alias delegate: list.delegate

    function show() {
        opacity = 1.0
        height = Math.min(list.count * delegateHeight, maxHeight)
    }

    function close() {
        opacity = 0.0
        height = 0
    }

    height: 0
    opacity: 0.0
    visible: opacity > 0.0
    z: 1

    Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad } }
    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad } }

    Rectangle {
        color: "black"
        height: window.height
        opacity: 0.7
        parent: root.parent
        visible: root.visible
        width: window.width
        MouseArea {
            anchors.fill: parent
            preventStealing: true
            propagateComposedEvents: false
            onClicked: root.close()

        }
    }

    ListView {
        id: list
        anchors.fill: parent
        /*delegate: ListItem {
            height: delegateHeight
            width: root.width
            Label {
                anchors { fill: parent; margins: 3 }
                color: "white"
                fontSizeMode: Text.Fit
                font.pixelSize: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
            }
            onClicked: root.close()
        }*/

        //cacheBuffer: window.height * 5
        clip: true

        //model: ["day1", "day2", "day3", "day4"]
    }
}
