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
import Enginio 1.0
import TalkSchedule 1.0
import "components"

ApplicationWindow {
    id: window
    visible: true
    height: 1080
    width: 1080
    property bool busy

    color: Theme.colors.white

    Connections {
        target: applicationClient
        onCurrentConferenceIdChanged: ModelsSingleton.conferenceId = applicationClient.currentConferenceId
        onError: ModelsSingleton.errorMessage = errorMessage
    }

    Item {
        id: menuPicker
        anchors.fill: parent
        z: 2
        visible: false
        MouseArea {
            anchors.fill: parent
            onClicked: menuPicker.visible = false
        }
        Rectangle {
            anchors.fill: parent
            color: Theme.colors.black
            opacity: 0.65
        }

        Rectangle {
            id: menuRectangle
            color: Theme.colors.white_menu
            anchors.centerIn: parent
            width: Theme.sizes.menuPopupWidth
            z: 3
            radius: Theme.margins.twenty
            ListModel {
                id: menuModel
                Component.onCompleted: {
                    append({name: Theme.text.home, id: "home" })
                    append({name: Theme.text.schedule, id: "schedule"  })
                    append({name: Theme.text.talks, id: "talks"  })
                    append({name: Theme.text.favorites, id: "favorites"  })
                    append({name: Theme.text.switchConf, id: "switchConf"  })
                    menuRectangle.height = Theme.sizes.buttonHeight * menuModel.count
                }
            }
            Repeater {
                id: listMenu
                anchors.fill: parent
                anchors.margins: Theme.margins.ten
                model: menuModel
                function firstOrLast(index)
                {
                    if (index === 0)
                        return 1
                    else if (index === (menuModel.count - 1))
                        return 2
                    else
                        return 0
                }

                Rectangle {
                    z: 2
                    height: Theme.sizes.buttonHeight
                    width: parent.width
                    color: !mouseArea.pressed ? Theme.colors.white_menu : Theme.colors.blue_menu
                    y: Theme.sizes.buttonHeight * index
                    radius: Theme.margins.twenty
                    Rectangle {
                        width: parent.width
                        property int posStatus: listMenu.firstOrLast(index)
                        height:  Theme.sizes.buttonHeight - (posStatus !== 0 ? Theme.margins.twenty : 0)
                        y: posStatus === 1 ? Theme.margins.twenty : 0
                        color: !mouseArea.pressed ? Theme.colors.white_menu : Theme.colors.blue_menu
                    }

                    Text {
                        z: 2
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.margins.ten
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -separator.height
                        width: parent.width
                        text: name
                        color: mouseArea.pressed ? Theme.colors.white : Theme.colors.blue_menu
                        font.pointSize: Theme.fonts.eight_pt
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle {
                        id: separator
                        visible: index < menuModel.count - 1
                        anchors.bottom: parent.bottom
                        height: 1
                        width: parent.width
                        color: Theme.colors.gray_menu
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: listMenu.pushView(id)
                    }
                }

                function pushView(id)
                {
                    switch (id) {
                    case "home":
                        var item = Qt.resolvedUrl("components/HomeScreen.qml")
                        stack.pop(stack.find(function(item){ return item.objectName === "homeScreen" }))
                        break
                    case "schedule":
                        var itemT = Qt.resolvedUrl("components/TrackSwitcher.qml")
                        var loadedTr = stack.find(function(itemT){ return itemT.objectName === "trackSwitcher" })
                        if (loadedTr !== null)
                            stack.pop(loadedTr)
                        else
                            stack.push(itemT)
                        break
                    case "talks":
                        var itemE = Qt.resolvedUrl("components/EventsList.qml")
                        var loadedEv = stack.find(function(itemE){ return (itemE.isFavoriteView === false)})
                        if (loadedEv !== null)
                            stack.pop(loadedEv)
                        else
                            stack.push(itemE)
                        break
                    case "favorites":
                        var itemFa = Qt.resolvedUrl("components/EventsList.qml")
                        var loadedFav = stack.find(function(itemFa){ return (itemFa.isFavoriteView === true)})
                        if (loadedFav !== null) {
                            stack.pop(loadedFav)
                        } else {
                            stack.push({
                                           "item" : itemFa,
                                           "properties" : { "isFavoriteView" : true }
                                       })
                        }
                        break
                    case "switchConf":
                        var item = Qt.resolvedUrl("components/ConferenceSwitcher.qml")
                        var loadedSC = stack.find(function(item){ return item.objectName === "switchConf" })
                        if (loadedSC !== null)
                            stack.pop(loadedSC)
                        else {
                            stack.push(item)
                        }
                        break
                    default:
                        break
                    }
                    menuPicker.visible = false
                }
            }
        }
    }

    ConferenceHeader {
        id: header
        visible: !initConferenceSwitcher.visible
        anchors.top: parent.top
        height: Theme.sizes.conferenceHeaderHeight
        width: parent.width
        opacity: stack.opacity
        Behavior on opacity { PropertyAnimation{} }
        onShowMenu: menuPicker.visible = !menuPicker.visible
    }

    StackView {
        id: stack
        visible: !initConferenceSwitcher.visible
        focus: true
        width: parent.width
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
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
        visible: !initConferenceSwitcher.visible
        Image {
            id: splashlogo
            visible: splashscreen.visible
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
                                      stack.push(Qt.resolvedUrl("components/HomeScreen.qml"))
                                  }
            }
        }
        onVisibleChanged: if (visible) animation.running = true
    }

    Rectangle {
        id: initConferenceSwitcher
        anchors.fill: parent
        opacity: 0.01
        visible:  ModelsSingleton.conferenceId === ""
        Image {
            id: logo
            visible: parent.visible
            opacity: parent.opacity
            anchors.top: parent.top
            anchors.topMargin: Theme.margins.thirty
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize.height: Theme.sizes.logoHeight
            sourceSize.width: Theme.sizes.logoWidth
            source: Theme.images.logo
            fillMode: Image.PreserveAspectFit
        }
        ConferenceSwitcher {
            anchors.top: logo.bottom
            anchors.topMargin: Theme.margins.thirty
            anchors.bottom: parent.bottom
            opacity: parent.opacity
            width: parent.width
        }
    }

    Connections {
        target: applicationClient
        onConferencesModelChanged: if (initConferenceSwitcher.visible) initConferenceSwitcher.opacity = 1
    }
}
