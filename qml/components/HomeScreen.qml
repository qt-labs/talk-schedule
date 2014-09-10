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
import QtQuick.XmlListModel 2.0
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
        return (entity.url ? entity.url : entity.expanded_url)
    }

    function textForEntity(entity)
    {
        return (entity.display_url ? entity.display_url : entity.expanded_url)
    }

    function insertLinks(text, entities)
    {
        console.log("Tweet before: " + text)

        if (typeof text !== 'string')
            return "";

        if (!entities)
            return text;

        var links = []
        links = entities.media ? entities.urls.concat(entities.media) : entities.urls

        links.sort(function(a, b) { return b.indices[0] - a.indices[0] })

        for (var i = 0; i < links.length; i++) {
            var offset = links[i].url ? 0 : 1
            text = text.substring(0, links[i].indices[0] + offset) +
                '<a href=\"' + linkForEntity(links[i]) + '\">' +
                textForEntity(links[i]) + '</a>' +
                text.substring(links[i].indices[1])
        }

        console.log("Tweet after: " + text)

        return text.replace(/\n/g, '<br>');
    }


    Column {
        spacing: 0
        Item {
            // upcoming
            width: homeScreenWindow.width
            height: homeScreenWindow.height / 3

            Text {
                id: labelUpcoming
                text: Theme.text.upcoming.arg(ModelsSingleton.conferenceTitle)
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
            }
            ListView {
                id: homeScreenListView
                anchors.top: labelUpcoming.bottom
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: Theme.margins.ten
                clip: true
                model: SortFilterModel {
                    id: sortModel
                    sortRole: "start"
                    filterRole: "fromNow"
                    model: ModelsSingleton.eventModel
                }
                onVisibleChanged: sortModel.filter()
                spacing: Theme.margins.five
                delegate: RowLayout {
                    width: parent.width
                    height: Theme.sizes.upcomingEventHeight
                    Rectangle {
                        color: tracks.backgroundColor
                        Layout.fillHeight: true
                        Layout.preferredWidth: Theme.sizes.upcomingEventTimeWidth

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.margins.five
                            text: Qt.formatDate(start, "ddd") + " " + Qt.formatTime(start, "h:mm")
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.pointSize: Theme.fonts.seven_pt
                        }
                    }
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: mouseArea.pressed ? Theme.colors.smokewhite : Theme.colors.white

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.margins.five
                            text: "<b>" + topic + "</b><br />by " + performer + " in " + location
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                onClicked: stack.push({
                                                          "item" : Qt.resolvedUrl("Event.qml"),
                                                          "properties" : {"eventId" : id}
                                                      })
                            }
                        }
                    }
                }
            }
        }
        Item {
            // news
            width: window.width
            height:  homeScreenWindow.height / 3


            TweetModel {
                id: tweetModel
            }

            Text {
                id: labelNews
                z: 1
                text: Theme.text.news
                width: parent.width
                height: Theme.sizes.homeTitleHeight
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
                    id: reloadNews
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.margins.ten
                    source: Theme.images.loading
                }
                MouseArea {
                    anchors.fill: reloadNews
                    onClicked: tweetModel.reload()
                }
            }

            Component {
                id: tweetDelegate

                Rectangle {
                    color: Theme.colors.smokewhite
                    height: tweetArea.height
                    width: window.width

                    Image {
                        id: placeHolder
                        anchors.verticalCenter: parent.verticalCenter
                        source: Theme.images.anonymous
                        visible: avatar.status != Image.Ready
                    }

                    Image {
                        id: avatar
                        anchors.fill: placeHolder
                        source: model.user.profile_image_url
                    }

                    Item {
                        id: tweetArea
                        width: parent.width - avatar.width
                        height: childrenRect.height
                        anchors.left: avatar.right

                        Text {
                            id: userName
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.margins.ten
                            text: "<b>" + model.user.name + "</b>"
                        }

                        Text {
                            id: userScreenName
                            anchors.left: userName.right
                            anchors.leftMargin: Theme.margins.ten
                            text: "@" + model.user.screen_name
                        }

                        Text {
                            id: tweetContent
                            anchors.left: parent.left
                            anchors.top: userName.bottom
                            anchors.leftMargin: Theme.margins.ten
                            anchors.rightMargin: Theme.margins.ten
                            width: parent.width - Theme.margins.twenty
                            text: insertLinks(model.text, model.entities)
                            wrapMode: Text.WordWrap
                            textFormat: Text.RichText
                            onLinkActivated: Qt.openUrlExternally(link)
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
                spacing: Theme.margins.ten

                model: tweetModel.model
                delegate: tweetDelegate
            }
        }
        Item {
            // useful info
            // Todo: Content
            width: window.width
            height:  homeScreenWindow.height / 3
            Text {
                id: labelInfo
                z: 1
                text: Theme.text.info
                width: parent.width
                height: Theme.sizes.homeTitleHeight
                font.pointSize: Theme.fonts.seven_pt
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.AllUppercase
                Rectangle {
                    anchors.fill: parent
                    z: -1
                    color: Theme.colors.smokewhite
                }
            }
            Text {
                id: info
                anchors.top: labelInfo.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.margins.ten
                textFormat: Text.StyledText
                font.pointSize: Theme.fonts.seven_pt
                text: "<a href='http://www.qtdeveloperdays.com/sites/default/files/files/bcc_map.pdf'>
                        Venue map</a><br />
                       <a href='http://www.qtdeveloperdays.com/sites/default/files/files/bcc_hotels.pdf'>
                        Recommended hotels</a><br />
                       <a href='https://www.qtdeveloperdays.com/sites/default/files/files/BerlinAlexanderplatzRestaurants_1.pdf'>
                        Restaurants in the vicinity</a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
