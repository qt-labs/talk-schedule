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
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import Enginio 1.0
import TalkSchedule 1.0

Item {
    id: conferenceHeader
    property var event
    property string favoriteImage
    property string notFavoriteImage
    property string location

    Item {
        id: topicRect
        anchors.fill: parent

        RowLayout {
            id: texts
            anchors.left: parent.left
            anchors.right: parent.right
            height: topicRect.height
            anchors.margins: 10
            MouseArea {
                enabled: stack.depth > 1
                Layout.preferredHeight: topicRect.height
                Layout.preferredWidth: topicRect.height
                onClicked: stack.pop()
                Image {
                    id: backButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20
                    opacity: stack.depth > 1 ? 1 : 0
                    Behavior on opacity { PropertyAnimation{} }
                    height: Theme.sizes.backHeight
                    width: Theme.sizes.backWidth
                }
            }
            Image {
                id: header
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredHeight: Theme.sizes.logoHeight
                Layout.preferredWidth: Theme.sizes.logoWidth

            }
            ComboBox {
                id: dropMenu
                Layout.preferredWidth: topicRect.height
                Layout.preferredHeight: topicRect.height
                property string menuImage
                Layout.alignment: Qt.AlignRight
                model: choices
                style: ComboBoxStyle{
                    drowDownButtonWidth: 0
                    label: Item {
                    }
                    background: Item {
                        height: topicRect.height
                        width: topicRect.height
                        Image{
                            id: mImage
                            source: dropMenu.menuImage
                            height: Theme.sizes.menuHeight
                            width: Theme.sizes.menuWidth
                            anchors.centerIn: parent
                        }

                    }
                }
                onCurrentIndexChanged: {
                    if (currentIndex === 0) {
                        var item = Qt.resolvedUrl("TrackSwitcher.qml")
                        stack.pop(stack.find(function(item){}))
                    } else if (currentIndex === 1) {
                        var itemF = Qt.resolvedUrl("EventsList.qml")
                        var loadedFav = stack.find(function(itemF){ return (itemF.isFavoriteView === true)})
                        if (loadedFav !== null)
                            stack.pop(loadedFav)
                        else
                            stack.push({
                                           "item" : itemF,
                                           "properties" : { "isFavoriteView" : true }
                                       })
                    } else if (currentIndex === 2) {
                        var itemE = Qt.resolvedUrl("EventsList.qml")
                        var loadedEv = stack.find(function(itemE){ return (itemE.isFavoriteView === false)})
                        if (loadedEv !== null)
                            stack.pop(loadedEv)
                        else
                            stack.push(itemE)
                    }
                    // View can be changed also with back button. So currentIndex does
                    // not necessarily change view as index is not changed.
                    // This is why currentIndex is changed to -1 after opening view
                    currentIndex = -1
                }
            }
        }
    }

    ListModel {
        id: choices
        Component.onCompleted: {
            choices.append({text: Theme.text.schedule})
            choices.append({text: Theme.text.favorites})
            choices.append({text: Theme.text.talks})
        }
    }

    EnginioClient {
        id: client
        backendId: backId

        onError: console.log("Enginio error " + reply.errorCode + ": " + reply.errorString)
        Component.onCompleted: {
            var eventQuery = query({ "objectType": "objects.Conference"})

            eventQuery.finished.connect(function() {
                event = eventQuery.data.results[0]

                ModelsSingleton.conferenceId = event.id
                location = event.location

                // After id is fetched, download also images
                if (!!event.logo) {
                    var downloadLogo = {
                        "id": event.logo.id,
                    }
                    var replyLogo = client.downloadUrl(downloadLogo)
                    replyLogo.finished.connect(function() {
                        if (header && replyLogo.data.expiringUrl) {
                            header.source = replyLogo.data.expiringUrl
                        }
                    })
                }
                if (!!event.backImage) {
                    var downloadBackImage = {
                        "id": event.backImage.id,
                    }
                    var replyBackImage = client.downloadUrl(downloadBackImage)
                    replyBackImage.finished.connect(function() {
                        if (backButton && replyBackImage.data.expiringUrl) {
                            backButton.source = replyBackImage.data.expiringUrl
                        }
                    })
                }
                if (!!event.menuImage) {
                    var downloaMenuImage = {
                        "id": event.menuImage.id,
                    }
                    var replyMenuImage = client.downloadUrl(downloaMenuImage)
                    replyMenuImage.finished.connect(function() {
                        if ( replyMenuImage.data.expiringUrl) {
                            dropMenu.menuImage = replyMenuImage.data.expiringUrl
                        }
                    })
                }
                if (!!event.favoriteNotSelectedImage) {
                    var downloaFavoriteNotSelectedImage = {
                        "id": event.favoriteNotSelectedImage.id,
                    }
                    var replyFavoriteNotImage = client.downloadUrl(downloaFavoriteNotSelectedImage)
                    replyFavoriteNotImage.finished.connect(function() {
                        if ( replyFavoriteNotImage.data.expiringUrl) {
                            notFavoriteImage = replyFavoriteNotImage.data.expiringUrl
                        }
                    })
                }
                if (!!event.favoriteSelectedImage) {
                    var downloaFavoriteSelectedImage = {
                        "id": event.favoriteSelectedImage.id,
                    }
                    var replyFavoriteImage = client.downloadUrl(downloaFavoriteSelectedImage)
                    replyFavoriteImage.finished.connect(function() {
                        if ( replyFavoriteImage.data.expiringUrl) {
                            favoriteImage = replyFavoriteImage.data.expiringUrl
                        }
                    })
                }
            })
        }
    }
}
