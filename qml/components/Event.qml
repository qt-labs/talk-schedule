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
import QtQuick.Layouts 1.1
import Enginio 1.0
import qt.conclave.models 1.0

Item {

    id: eventView

    property string eventId
    property var track

    property bool isSelected: false

    signal selectFavorite(bool favorite)
    property var favorite

    height: window.height
    width: window.width

    SubTitle {
        id: subTitle
        titleText: "esitykset"
    }
    Rectangle {
        color: "white"
        anchors.fill: flickable
    }

    Flickable {
        id: flickable
        anchors.top: subTitle.bottom
        anchors.left: subTitle.left
        anchors.right: subTitle.right
        anchors.topMargin: 5
        height: window.height - subTitle.height - statusBar.height
        contentHeight: columnLayout.height +  statusBar.height
        flickableDirection: Flickable.VerticalFlick
        clip: true
        Column{
            id: columnLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            spacing: 20
            Text {
                text: model.get(0, "topic")
                color: "black"
                width: columnLayout.width
                font.family: "Open Sans"
                font.pixelSize: 32
                maximumLineCount: 2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }
            Label {
                id: eventPerformers
                text: model.get(0, "performer")
                font.family: "Open Sans"
                font.pixelSize: 20
                font.capitalization: Font.AllUppercase
                color: "#666666"
            }
            Label {
                id: eventIntro
                text: model.get(0, "intro")
                font.family: "Open Sans"
                font.pixelSize: 19
                width: parent.width
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                color: "#666666"
            }
            Label {
                id: eventTags
                text: model.get(0, "tags")
                font.family: "Open Sans"
                font.pixelSize: 19
                color: "#ff00ff"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: stack.pop()

        }
    }

    Rectangle{

        color: Qt.rgba(0,242,242)

        anchors.bottom: flickable.bottom
        anchors.left: flickable.left
        anchors.right: flickable.right
        height: 80


        RowLayout {
            id: statusBar
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 20
            Rectangle {
                id: trackSquare

                width: statusBar.height - 10
                height: statusBar.height - 10
                radius: 5
                color: track.backgroundColor
                Text {
                    anchors.centerIn: parent
                    text: "Track \n"+"0"+track.trackNumber
                    color: track.fontColor
                    font.family: "Open Sans"
                    font.pixelSize: 20
                }
            }
            Label{
                height: parent.height
                text: Qt.formatTime(model.get(0, "start"), "hmm")+">"+Qt.formatTime(model.get(0, "end"), "hmm")
                color: "#666666"
                font.family: "Open Sans"
                font.pixelSize: 20
            }
            Label{
                text: track.location
                height: parent.height
                color: "#666666"
                font.family: "Open Sans"
                font.pixelSize: 20
            }
            Item {
                Layout.alignment: Qt.AlignRight
                height: statusBar.height
                width: 80
                Image {
                    id: favorImage
                    anchors.centerIn: parent
                    source: favorite ? window.favoriteImage : window.notFavoriteImage
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        favorite ? window.removeFavorite(eventId) : window.saveFavorite(eventId)
                    }
                }
            }
        }
    }
    SortFilterModel {
        id:model;
        filterRole: "id"
        filterRegExp: new RegExp(eventId)
        model: window.eventModel
        Component.onCompleted:{
            track = model.get(0, "tracks")
            favorite = model.get(0, "favorite")
        }
    }
    Connections {
        target: window
        ignoreUnknownSignals: true
        onUpdateFavoriteSignal:{
            if (added === true) {
                favorite = true
            }
            else {
               favorite = false
            }
        }
    }

}
