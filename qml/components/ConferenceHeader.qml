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
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import Enginio 1.0
import TalkSchedule 1.0

Item {
    id: conferenceHeader
    property var event

    Rectangle {
        id: topicRect
        anchors.fill: parent
        color: Theme.colors.white

        RowLayout {
            id: texts
            anchors.left: parent.left
            anchors.right: parent.right
            height: topicRect.height
            anchors.margins: Theme.margins.ten
            MouseArea {
                id: mouseAreaBack
                Layout.preferredHeight: topicRect.height
                Layout.preferredWidth: topicRect.height
                enabled: stack.depth > 1
                onClicked: stack.pop()
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Theme.margins.five
                    color: mouseAreaBack.pressed ? Theme.colors.smokewhite : Theme.colors.white
                    radius: 5
                }
                Image {
                    id: backButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.margins.twenty
                    opacity: stack.depth > 1 ? 1 : 0
                    Behavior on opacity { PropertyAnimation{} }
                    height: Theme.sizes.backHeight
                    width: Theme.sizes.backWidth
                    sourceSize.height: Theme.sizes.backHeight
                    sourceSize.width: Theme.sizes.backWidth
                    source: Theme.images.back
                }
            }
            Image {
                id: header
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: Theme.sizes.logoHeight
                Layout.preferredWidth: Theme.sizes.logoWidth
                sourceSize.height: Theme.sizes.logoHeight
                sourceSize.width: Theme.sizes.logoWidth
                source: Theme.images.logo
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                id: mouseAreaMenu
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: topicRect.height
                Layout.preferredHeight: topicRect.height
                onClicked: menu.popup()
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Theme.margins.five
                    color: mouseAreaMenu.pressed ? Theme.colors.smokewhite : Theme.colors.white
                    radius: 5
                }
                Menu {
                    id: menu
                    MenuItem {
                        text: Theme.text.home
                        onTriggered: {
                            var item = Qt.resolvedUrl("HomeScreen.qml")
                            stack.pop(stack.find(function(item){}))
                        }
                    }
                    MenuItem {
                        text: Theme.text.schedule
                        onTriggered: {
                            var itemT = Qt.resolvedUrl("TrackSwitcher.qml")
                            var loadedTr = stack.find(function(itemT){})
                            if (loadedTr !== null)
                                stack.pop(loadedTr)
                            else
                                stack.push(itemT)
                        }
                    }
                    MenuItem {
                        text: Theme.text.talks
                        onTriggered: {
                            var itemE = Qt.resolvedUrl("EventsList.qml")
                            var loadedEv = stack.find(function(itemE){ return (itemE.isFavoriteView === false)})
                            if (loadedEv !== null)
                                stack.pop(loadedEv)
                            else
                                stack.push(itemE)
                        }
                    }
                    MenuItem {
                        text: Theme.text.favorites
                        onTriggered: {
                            var itemFa = Qt.resolvedUrl("EventsList.qml")
                            var loadedFav = stack.find(function(itemFa){ return (itemFa.isFavoriteView === true)})
                            if (loadedFav !== null) {
                                stack.pop(loadedFav)
                            } else {
                                stack.push({
                                               "item" : itemFa,
                                               "properties" : { "isFavoriteView" : true }
                                           })
                            }
                        }
                    }
                    MenuItem {
                        text: Theme.text.feedback
                        onTriggered: {
                            var itemFe = Qt.resolvedUrl("Feedback.qml")
                            var loadedFe = stack.find(function(itemFe){})
                            if (loadedFe !== null)
                                stack.pop(loadedFe)
                            else
                                stack.push(itemFe)
                        }
                    }
                }
                Image {
                    id: dropMenu
                    anchors.centerIn: parent
                    Layout.alignment: Qt.AlignRight
                    height: Theme.sizes.menuHeight
                    width: Theme.sizes.menuWidth
                    source: Theme.images.menu
                    sourceSize.height: Theme.sizes.menuHeight
                    sourceSize.width: Theme.sizes.menuWidth
                }
            }
        }
    }
}
