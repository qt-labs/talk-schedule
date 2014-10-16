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
import QtQuick.Layouts 1.1
import TalkSchedule 1.0

Rectangle {
    id: homeScreenWindow
    height: window.height - header.height
    width: window.width
    objectName: "homeScreen"

    property var idx
    property var ids
    property int counter: 0

    function linkForEntity(entity)
    {
        return (entity.url ? entity.url :
               (entity.screen_name ? 'https://twitter.com/' + entity.screen_name :
                                     'https://twitter.com/search?q=%23' + entity.text))
    }

    function textForEntity(entity)
    {
        return (entity.display_url ? entity.display_url :
               (entity.screen_name ? entity.screen_name : entity.text))
    }

    function insertLinks(text, entities)
    {
        if (typeof text !== 'string')
            return "";

        if (!entities)
            return text;

        if (entities.retweeted_status)
            return "";

        var links = []
        entities.urls = entities.media ? entities.urls.concat(entities.media) : entities.urls
        links = entities.urls.concat(entities.hashtags, entities.user_mentions)

        links.sort(function(a, b) { return b.indices[0] - a.indices[0] })

        for (var i = 0; i < links.length; i++) {
            var offset = links[i].url ? 0 : 1
            text = text.substring(0, links[i].indices[0] + offset) +
                '<a href=\"' + linkForEntity(links[i]) + '\">' +
                textForEntity(links[i]) + '</a>' +
                text.substring(links[i].indices[1])
        }

        return text.replace(/\n/g, '<br>');
    }

    Column {
        spacing: 0
        visible: ModelsSingleton.conferenceId !== ""
        anchors.fill: parent
        Item {
            // upcoming
            id: upcomingItem
            width: homeScreenWindow.width
            height: homeScreenWindow.height / 2

            property string visibleDate: ""
            property string formatDate: "ddd d.MM"

            SortFilterModel {
                id: sortModelNextEvents

                function init()
                {
                    emptyUpcoming.visible = false
                    if (sortModelNextEvents.rowCount() > 0)
                        upcomingItem.visibleDate = Qt.formatDate(sortModelNextEvents.get(0, "start"), upcomingItem.formatDate)
                    if (sortModelNextEvents.rowCount() === 0)
                        emptyUpcoming.visible = true
                }

                sortRole: "start"
                filterRole: "fromNow"
                maximumCount: 7
                model: ModelsSingleton.eventModel
                Component.onCompleted: init()
            }

            Connections {
                target: ModelsSingleton.eventModel
                onDataReady: {
                    sortModelNextEvents.model = ModelsSingleton.eventModel
                    sortModelNextEvents.init()
                }
            }

            Text {
                // upcoming events title
                id: labelUpcoming
                text: Theme.text.upcoming.arg(applicationClient.currentConferenceDetails.title).arg(upcomingItem.visibleDate)
                width: parent.width
                height: Theme.sizes.homeTitleHeight
                z: 1
                font.pointSize: Theme.fonts.seven_pt
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.AllUppercase
                Rectangle {
                    anchors.fill: parent
                    z: -1
                    color: Theme.colors.smokewhite
                }
                Image {
                    id: reloadUpcoming
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.margins.fifteen
                    source: Theme.images.loading
                    sourceSize.height: Theme.sizes.reloadButtonSize
                    sourceSize.width: Theme.sizes.reloadButtonSize
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            rotationUpcoming.running = true
                            homeScreenListView.reloadUpcoming()
                        }
                    }
                    RotationAnimation {
                        id: rotationUpcoming
                        target: reloadUpcoming
                        property: "rotation"
                        running: false
                        duration: 800
                        from: 0
                        to: 360
                    }
                }
            }
            ListView {
                // upcoming events list
                id: homeScreenListView
                anchors.top: labelUpcoming.bottom
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: Theme.margins.ten
                model: sortModelNextEvents
                clip: true
                function reloadUpcoming() {
                    emptyUpcoming.visible = false
                    if (visible && sortModelNextEvents.rowCount() > 0) {
                        sortModelNextEvents.filter()
                        upcomingItem.visibleDate = Qt.formatDate(sortModelNextEvents.get(0, "start"), upcomingItem.formatDate)
                    }
                    if (sortModelNextEvents.rowCount() === 0)
                        emptyUpcoming.visible = true
                }

                onVisibleChanged: homeScreenListView.reloadUpcoming()
                Text {
                    id: emptyUpcoming
                    visible: false
                    text: Theme.text.endedEvent
                    anchors.centerIn: parent
                    font.pointSize: Theme.fonts.eight_pt
                }
                spacing: Theme.margins.ten
                delegate: RowLayout {
                    id: upcomingEventDelegate
                    width: parent.width
                    visible: Qt.formatDate(start, upcomingItem.formatDate) === upcomingItem.visibleDate
                    height: visible ? Theme.sizes.upcomingEventHeight : 0
                    Rectangle {
                        color: tracks.backgroundColor
                        Layout.fillHeight: true
                        Layout.preferredWidth: Theme.sizes.upcomingEventTimeWidth
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.margins.five
                            text: tracks.name
                            font.capitalization: Font.AllUppercase
                            color: Theme.colors.white
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.pointSize: Theme.fonts.eight_pt

                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: mouseArea.pressed ? Theme.colors.smokewhite : Theme.colors.white
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: stack.push({
                                                      "item" : Qt.resolvedUrl("Event.qml"),
                                                      "properties" : {"eventId" : id}
                                                  })
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.margins.twenty
                            Text {
                                Layout.fillWidth: true
                                text: topic
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.pointSize: Theme.fonts.eight_pt
                            }
                            Text {
                                Layout.fillWidth: true
                                text: Qt.formatTime(start, Qt.locale().timeFormat(Locale.ShortFormat)) + Theme.text.room_space.arg(location)
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.pointSize: Theme.fonts.eight_pt

                                color: Theme.colors.gray
                            }
                        }
                    }
                }
            }
        }
        Item {
            // twitter news
            width: window.width
            height: homeScreenWindow.height / 2

            TweetModel {
                id: tweetModel
            }

            Rectangle {
                id: labelNews
                width: parent.width
                height: Theme.sizes.homeTitleHeight
                color: Theme.colors.smokewhite

                Text {
                    id: labelNewsText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Theme.text.news
                    font.pointSize: Theme.fonts.seven_pt
                    font.capitalization: Font.AllUppercase
                }

                Image {
                    source: Theme.images.twitter
                    sourceSize.height: labelNewsText.height
                    sourceSize.width: labelNewsText.height
                    anchors.right: labelNewsText.left
                    anchors.rightMargin: Theme.margins.five
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(Theme.text.twitterLink)
                    }
                }

                Image {
                    id: reloadNews
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.margins.fifteen
                    source: Theme.images.loading
                    sourceSize.height: Theme.sizes.reloadButtonSize
                    sourceSize.width: Theme.sizes.reloadButtonSize
                    RotationAnimation {
                        id: rotationNews
                        target: reloadNews
                        property: "rotation"
                        running: false
                        duration: 800
                        from: 0
                        to: 360
                    }
                }
                MouseArea {
                    anchors.fill: reloadNews
                    onClicked: {
                        rotationNews.running = true
                        tweetModel.reload()
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: tweetModel.errorMessage !== ""
                text: tweetModel.errorMessage
            }


            Component {
                id: tweetDelegate

                Rectangle {
                    color: Theme.colors.white
                    height: Math.max(tweetArea.height, Theme.sizes.twitterAvatarSize)
                    width: window.width

                    Image {
                        id: placeHolder
                        anchors.top: parent.top
                        anchors.left: parent.left
                        source: Theme.images.anonymous
                        sourceSize.height: Theme.sizes.twitterAvatarSize
                        sourceSize.width: Theme.sizes.twitterAvatarSize
                        visible: avatar.status != Image.Ready
                    }

                    Image {
                        id: avatar
                        anchors.fill: placeHolder
                        source: model.user.profile_image_url
                        sourceSize.height: Theme.sizes.twitterAvatarSize
                        sourceSize.width: Theme.sizes.twitterAvatarSize

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Qt.openUrlExternally(Theme.text.twitterLink + model.user.screen_name)
                        }
                    }

                    Column {
                        id: tweetArea
                        width: parent.width - placeHolder.width - Theme.margins.twenty
                        height: userName.implicitHeight + tweetContent.implicitHeight
                        anchors.left: placeHolder.right
                        anchors.leftMargin: Theme.margins.ten
                        anchors.rightMargin: Theme.margins.ten

                        Item {
                            width: parent.width
                            height: userName.implicitHeight
                            Text {
                                id: userName
                                anchors.left: parent.left
                                text: model.user.name
                                font.pointSize: Theme.fonts.eight_pt
                                color: Theme.colors.black
                                textFormat: Text.StyledText
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally(Theme.text.twitterLink
                                                                    + model.user.screen_name)
                                }
                            }

                            Text {
                                id: screenName
                                anchors.left: userName.right
                                anchors.leftMargin: Theme.margins.ten
                                anchors.bottom: parent.bottom
                                text: "@" + model.user.screen_name
                                font.pointSize: Theme.fonts.eight_pt

                                color: Theme.colors.gray
                                textFormat: Text.StyledText
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally(Theme.text.twitterLink
                                                                    + model.user.screen_name)
                                }
                            }
                            Text {
                                id: timeStamp
                                anchors.right: parent.right
                                anchors.rightMargin: Theme.margins.ten
                                anchors.bottom: parent.bottom
                                text: getElapsedTime()
                                font.pointSize: Theme.fonts.eight_pt
                                color: Theme.colors.gray
                                textFormat: Text.StyledText
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally(Theme.text.twitterLink
                                                                    + model.user.screen_name
                                                                    + "/status/" + model.id_str)
                                }
                                function getElapsedTime()
                                {
                                    var createdAt = model.created_at.replace(" +0000", "") // UTC
                                    var createdDate = new Date(createdAt)
                                    var now = new Date() // Local
                                    var localOffset = now.getTimezoneOffset() * 60 * 1000
                                    var diff = Math.floor((now.getTime() - createdDate.getTime() + localOffset) / 1000); // seconds

                                    if (diff <= 10)
                                        return "Now"
                                    if (diff <= 90)
                                        return "1m"
                                    if (diff <= 3540)
                                        return Math.round(diff / 60) + "m"
                                    if (diff <= 5400) // 1,5h
                                        return "1h"
                                    if (diff <= 84600) // 23,5h
                                        return Math.round(diff / 3600) + "h"
                                    if (diff <= 129600) // 36h
                                        return "1 day"
                                    if (diff <= 561600) // 6,5 days
                                       return Math.round(diff / 86400) + " days"
                                    var createdDateFormated = new Date()
                                    createdDateFormated.setTime(now.getTime() - diff *1000) // createdAt in local format
                                    return Qt.formatDate(createdDateFormated, "d MMM");
                                }
                            }
                        }

                        Text {
                            id: tweetContent
                            width: parent.width
                            text: insertLinks(model.text, model.entities)
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            font.pointSize: Theme.fonts.eight_pt
                            color: Theme.colors.gray
                            onLinkActivated: Qt.openUrlExternally(link)
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally(Theme.text.twitterLink
                                                                + model.user.screen_name
                                                                + "/status/" + model.id_str)
                            }
                        }
                    }
                }
            }

            ListView {
                id: listNews
                anchors.top: labelNews.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.margins.ten
                clip: true
                spacing: Theme.margins.twenty
                model: tweetModel.model
                delegate: tweetDelegate
            }
        }
    }
}
