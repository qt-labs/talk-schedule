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
import TalkSchedule 1.0
import "functions.js" as Functions

QtObject {
    id: dayTracksModel
    property string dayId
    property int numberCollidingEvents: 0
    property var rowsArray: []
    signal isReady
    property bool isEmpty: false

    property var modelTracks: SortFilterModel {
        property bool ready
        sortRole: "start"
        filterRole: "track"
        filterRegExp: new RegExp(dayId)
        model: ModelsSingleton.eventModel
        Component.onCompleted: {
            isEmpty = modelTracks.rowCount() === 0
            ready = Qt.binding(function() {return modelTracks.rowCount() > 0})
        }
        onReadyChanged: {
            // calculate number of rows needed for the current track
            numberCollidingEvents = 0
            rowsArray = []
            for (var i = 0; i < modelTracks.rowCount(); i++) {
                var colliding = isCollidingWithPreviousEvents(i)
                if (rowsArray[colliding] === undefined)
                    rowsArray.push([])
                var sizeArray = rowsArray[colliding].length
                rowsArray[colliding].push(i)
                numberCollidingEvents = Math.max(colliding, numberCollidingEvents)
            }
            dayTracksModel.isReady()
        }
        function isCollidingWithPreviousEvents(index) {
            var currentTimeStart = new Date(modelTracks.get(index, "start"))
            for (var i = 0; i < index; i++) {
                var previoustTimeEnd = new Date(modelTracks.get(i, "end"))
                if (currentTimeStart < previoustTimeEnd)
                    return (index - i)
            }
            return 0
        }
    }
}
