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

Rectangle {
    id: delegateItem
    property bool isDayLabelVisible: isSameDay()
    property int labelHeight: isDayLabelVisible ? Theme.sizes.dayLabelHeight : 5
    property var viewSortModel: ListView.view.model
    color: Theme.colors.white

    height: Theme.sizes.trackHeaderHeight + labelHeight
    width: parent.width
    Label {
        id: dayLabel
        height: labelHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        verticalAlignment: Text.AlignVCenter
        text: isDayLabelVisible ? Qt.formatDate(start, "dddd dd.MM.yyyy") : ""
        font.pixelSize: 20
        font.capitalization: Font.AllUppercase
    }
    RowLayout {
        id: rowLayout
        height: Theme.sizes.trackHeaderHeight
        width: parent.width
        anchors.top: dayLabel.bottom
        Rectangle {
            id: trackHeader
            height: Theme.sizes.trackHeaderHeight
            width: Theme.sizes.trackHeaderWidth
            color: tracks.backgroundColor

            Text {
                anchors.fill: parent
                anchors.margins: 10
                text: tracks.name
                color: tracks.fontColor
                fontSizeMode: Text.Fit
                font.pixelSize: 20
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.capitalization: Font.AllUppercase
                wrapMode: Text.WordWrap
            }
        }
        Rectangle {
            Layout.fillWidth: true
            color: Theme.colors.smokewhite
            height: parent.height
            width: parent.width

            ColumnLayout {
                id: eventColumn
                anchors.fill: parent
                anchors.margins: 20

                // For some reason word wrap does not work correctly
                // if Text not inside Item
                Item {
                    width: textTopic.implicitWidth
                    height: 50
                    Text {
                        id: textTopic
                        text: topic
                        color: Theme.colors.black
                        width: parent.width
                        font.pixelSize: 25
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                    }
                }
                Text {
                    text: performer
                    color: Theme.colors.gray
                    width: parent.width - 20
                    font.pixelSize: 14
                    font.capitalization: Font.AllUppercase
                    maximumLineCount: 1
                }
                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Text {
                        text: Qt.formatTime(start, "h:mm") + " - " + Qt.formatTime(end, "h:mm")
                        color: Theme.colors.gray
                        font.pixelSize: 14
                    }
                    Text {
                        text: " I "
                        color: Theme.colors.gray
                        font.pixelSize: 14
                        font.capitalization: Font.AllUppercase
                    }
                    Text {
                        text: "name room" // TODO tracks.location
                        Layout.fillWidth: true
                        color: Theme.colors.gray
                        font.pixelSize: 14
                        font.capitalization: Font.AllUppercase
                        maximumLineCount: 1
                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Item {
        // Add this imageArea to make it easier to click the image
        id: imageArea
        anchors.bottom: rowLayout.bottom
        anchors.right: rowLayout.right
        width: Theme.sizes.favoriteImageWidth + 20
        height: Theme.sizes.favoriteImageHeight + 20
        Image {
            id: favoriteImage
            anchors.centerIn: parent
            source: (favorite) ? window.favoriteImage : window.notFavoriteImage
            width: Theme.sizes.favoriteImageWidth
            height: Theme.sizes.favoriteImageHeight
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (favorite)
                    ModelsSingleton.removeFavorite(id)
                else
                    ModelsSingleton.saveFavorite(id)
            }
        }
    }

    function isSameDay()
    {
        if (index > 0) {
            var date = Qt.formatDate(start, "dddd d.M.yyyy")
            var date2 = Qt.formatDate(viewSortModel.get(index - 1, "start"), "dddd d.M.yyyy")
            return date2 != date
        }
        return index === 0
    }

    MouseArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: imageArea.left
        }
        onClicked: stack.push({"item" : Qt.resolvedUrl("Event.qml"), "properties" : {"eventId" : id}})
    }
}
