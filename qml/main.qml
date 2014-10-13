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
    signal showFloor
    onShowFloor: listMenu.pushView("floorPlan")

    color: Theme.colors.white

    Connections {
        target: applicationClient
        onCurrentConferenceIdChanged: ModelsSingleton.conferenceId = applicationClient.currentConferenceId
        onError: ModelsSingleton.errorMessage = errorMessage
    }

    Item {
        id: menuPicker
        anchors.fill: parent
        z: 3
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
            z: 4
            ListModel {
                id: menuModel
                Component.onCompleted: {
                    append({name: Theme.text.home, id: "home" })
                    append({name: Theme.text.schedule, id: "schedule"  })
                    append({name: Theme.text.talks, id: "talks"  })
                    append({name: Theme.text.favorites, id: "favorites"  })
                    append({name: Theme.text.floorPlan, id: "floorPlan"  })
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
                    z: 3
                    height: Theme.sizes.buttonHeight
                    width: parent.width
                    color: !mouseArea.pressed ? Theme.colors.white : Theme.colors.gray_menu
                    y: Theme.sizes.buttonHeight * index
                    Text {
                        z: 3
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.margins.ten
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -separator.height
                        width: parent.width
                        text: name
                        color: mouseArea.pressed ? Theme.colors.gray : Theme.colors.black
                        font.pointSize: Theme.fonts.eight_pt
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Rectangle {
                        id: separator
                        visible: index < menuModel.count - 1
                        anchors.bottom: parent.bottom
                        height: 2
                        width: parent.width
                        color: Theme.colors.lightgray
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
                    case "floorPlan":
                        var itemFl = Qt.resolvedUrl("components/Floorplan.qml")
                        var loadedSC = stack.find(function(itemFl){ return itemFl.objectName === "floorPlan" })
                        if (loadedSC !== null)
                            stack.pop(loadedSC)
                        else {
                            stack.push(itemFl)
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
        z: 2
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

    Rectangle {
        id: splashscreen
        anchors.fill: parent
        visible: !initConferenceSwitcher.visible
        color: Theme.colors.white
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
                                      stack.forceActiveFocus()
                                  }
            }
            Component.onCompleted: if (visible) animation.running = true
        }
        onVisibleChanged: if (visible) animation.running = true
    }

    Rectangle {
        id: initConferenceSwitcher
        anchors.fill: parent
        visible:  ModelsSingleton.conferenceId === ""
        color: Theme.colors.white
        Text {
            anchors.centerIn: parent
            visible: applicationClient.noNetworkNoInitialisation
            font.pointSize: Theme.fonts.seven_pt
            text: Theme.text.networkErrorInit
        }

        Image {
            id: logo
            opacity: 0.01
            visible: parent.visible
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
            opacity: logo.opacity
            width: parent.width
        }
    }

    Connections {
        target: applicationClient
        onConferencesModelChanged: if (initConferenceSwitcher.visible) logo.opacity = 1
    }
}
