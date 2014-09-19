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
    id: floorplan
    objectName: "floorPlan"
    color: Theme.colors.white
    width: window.width
    height: window.height

    property bool isPortrait: floorplan.width < floorplan.height

    ListModel {
        id: currentModel
        property var conference: applicationClient.currentConferenceDetails.location
        onConferenceChanged: {
            currentModel.clear()
            if (conference === "BLN") {
                append({ imageSource: Theme.images.levelA })
                append({ imageSource: Theme.images.levelB })
                append({ imageSource: Theme.images.levelC })
            } else {
                append({ imageSource: Theme.images.sfoFloor })
            }
            largeView.largeImageSource = currentModel.get(0).imageSource
            largeView.visible = currentModel.count === 1
        }
    }

    GridLayout {
        id: columFloors
        anchors.fill: parent
        anchors.margins: Theme.margins.ten
        columns: floorplan.isPortrait ? 1 : currentModel.count
        rows: floorplan.isPortrait ? currentModel.count : 1
        z: 1
        columnSpacing: Theme.margins.ten
        rowSpacing: Theme.margins.ten
        Repeater {
            id: repeater
            model: currentModel
            Image {
                id: image
                source: imageSource
                Layout.alignment: Qt.AlignHCenter
                sourceSize.height: floorplan.isPortrait ? columFloors.height / currentModel.count - Theme.margins.twenty : 0
                sourceSize.width: !floorplan.isPortrait ? columFloors.width / currentModel.count - Theme.margins.twenty : 0
                property bool small: true
                Behavior on sourceSize.width { PropertyAnimation{} }
                Behavior on sourceSize.height { PropertyAnimation{} }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        largeView.largeImageSource = imageSource
                        largeView.visible = true
                    }
                }
            }
        }
    }

    Rectangle {
        z: 2
        id: largeView
        color: Theme.colors.white
        anchors.fill: parent
        visible: currentModel.count === 1
        property alias largeImageSource: floorOne.source
        Flickable {
            id: flickable
            anchors.fill: parent
            anchors.margins: Theme.margins.ten
            contentHeight: floorOne.height
            contentWidth: floorOne.width
            Image {
                id: floorOne
                anchors.centerIn: parent
                width: flickable.width
                fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (currentModel.count > 1)
                        largeView.visible = false
                }
            }
        }
    }
}
