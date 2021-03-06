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
import QtQuick.Window 2.1
import QtQuick.Layouts 1.1
import TalkSchedule 1.0

ListView {
    id: trackHeaderListView
    height: parent.height
    width: Theme.sizes.trackHeaderWidth

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    Rectangle {
        z: -1
        anchors.fill: parent
        color: Theme.colors.white
    }

    delegate: Rectangle {
        id: delegateItem
        property int trackHeight: Theme.sizes.trackHeaderHeight
        color: Theme.colors.white

        DayTracksModel {
            id: dayTracksModel
            dayId: id
        }

        Connections {
            target: ModelsSingleton.eventModel
            onDataReady: {
                dayTracksModel.modelTracks.model = ModelsSingleton.eventModel
                dayTracksModel.modelTracks.init()
            }
        }

        height: !dayTracksModel.isEmpty ? trackHeight * ( dayTracksModel.numberCollidingEvents + 1 ): 0
        width: Theme.sizes.trackHeaderWidth
        visible: !dayTracksModel.isEmpty

        Rectangle {
            id: trackHeader
            anchors.fill: parent
            color: backgroundColor
            anchors.rightMargin: Theme.margins.ten
            anchors.bottomMargin: index !== (listView.count - 1) ? Theme.margins.ten : 0
            Text {
                visible: !dayTracksModel.isEmpty
                anchors.fill: parent
                anchors.margins: Theme.margins.ten
                text: name
                color: fontColor
                font.pointSize: Theme.fonts.six_pt
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.capitalization: Font.AllUppercase
            }
        }
    }

    onContentYChanged: {
        if (isViewScrolling === false) {
            isViewScrolling = true;
            listView.contentY = trackHeaderListView.contentY
            isViewScrolling = false;
        }
    }
}
