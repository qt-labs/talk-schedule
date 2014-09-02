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
import QtQuick.Controls 1.1
import Enginio 1.0
import TalkSchedule 1.0
import "components"

ApplicationWindow {
    id: window
    visible: true
    height: 800
    width: 1080
    property bool busy

    color: Theme.colors.white

    FileIO {
        id: userIdFile
        Component.onCompleted: ModelsSingleton.retrieveUser(read())
    }

    Connections {
        target: ModelsSingleton
        onWriteUserIdToFile: userIdFile.write(userId)
    }

    ConferenceHeader {
        id: header
        height: Theme.sizes.conferenceHeaderHeight
        width: parent.width
        opacity: stack.opacity
        Behavior on opacity { PropertyAnimation{} }
    }

    StackView {
        id: stack
        focus: true
        anchors.fill: parent
        opacity: 1 - splashscreen.opacity
        Behavior on opacity { PropertyAnimation{} }
        // capture Android back key
        Keys.onReleased: {
            if (event.key === Qt.Key_Back) {
                if (stack.depth > 1) {
                    event.accepted = true
                    stack.pop()
                }
            }
        }
    }

    Item {
        id: splashscreen
        anchors.fill: parent
        Image {
            id: splashlogo
            anchors.centerIn: parent
            source: Theme.images.logo
            sourceSize.width: Theme.sizes.logoWidth * 2
            sourceSize.height: Theme.sizes.logoHeight * 2
            ParallelAnimation {
                id: animation
                running: false
                PropertyAnimation {target: splashlogo; properties: "width"; from: 0; to: Theme.sizes.logoWidth * 2; duration: 1500}
                PropertyAnimation {target: splashlogo; properties: "height"; from: 0; to: Theme.sizes.logoHeight * 2; duration: 1500}
                onRunningChanged: if (!running) {
                                      splashscreen.opacity = 0
                                      toolBar = header
                                      stack.push(Qt.resolvedUrl("components/TrackSwitcher.qml"))
                                  }
            }
            Component.onCompleted: animation.running = true
        }
    }
}
