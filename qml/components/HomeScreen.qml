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

    Column {
        spacing: 0
        Item {
            // upcoming
            // Todo: List upcoming talks
            width: homeScreenWindow.width
            height: homeScreenWindow.height / 3

            Text {
                id: labelUpcoming
                text: Theme.text.upcoming
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
                delegate: ColumnLayout {
                    width: parent.width
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.sizes.upcomingEventHeight
                        Text {
                            text: Qt.formatDate(start, "ddd") + " " + Qt.formatTime(start, "hh:mm")
                            Layout.fillHeight: true
                            Layout.preferredWidth: Theme.sizes.upcomingEventTimeWidth
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.pointSize: Theme.fonts.seven_pt
                        }
                        Text {
                            text: topic + " in " + location
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: Theme.fonts.seven_pt
                            elide: Text.ElideRight
                            MouseArea {
                                anchors.fill: parent
                                onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"eventId" : id}})
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.colors.darkgray
                    }
                }
            }
        }
        Item {
            // news
            width: window.width
            height:  homeScreenWindow.height / 3

            XmlListModel {
                id: rssXmlModel
                source: ModelsSingleton.rssFeed
                query: "/rss/channel/item"

                XmlRole { name: "title"; query: "title/string()" }
                XmlRole { name: "description"; query: "description/string()" }
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
            }
            ListView {
                id: listNews
                anchors.top: labelNews.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.margins.ten
                model: rssXmlModel
                clip: true
                delegate: Text {
                    width: window.width - Theme.margins.twenty
                    text: "<b>" + title + "</b>" + "\n" + description
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    onLinkActivated: Qt.openUrlExternally(link)
                    font.pointSize: Theme.fonts.seven_pt
                }
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
                text: "<a href='https://www.qtdeveloperdays.com/europe/europe-exhibit-hall-info'><b>Venue, Accommodation and Useful Info</b></a>"
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
