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
import Enginio 1.0
import qt.conclave.models 1.0
import "components"

import FileIO 1.0

ApplicationWindow {
    id: window
    height: 620
    width: 420
    property string conferenceId: header.conferenceId
    property string favoriteImage: header.favoriteImage
    property string notFavoriteImage: header.notFavoriteImage
    property bool busy
    property string userId : userIdFile.read()
    property variant updateFavoriteEvent: { 'event': '', 'added': false }
    property var eventModel: eventModel
    property var favoriteModel: favoriteModel
    property string backendId: "539fc807e5bde548e000597c"

    signal updateFavoriteSignal(string event, bool added)

    color:"#F2F2F2"

    FileIO {
        id: userIdFile
    }

    ConferenceHeader {
        id: header
    }

    StackView {
        id: stack
        anchors { top: header.bottom }
        initialItem: {"item" : Qt.resolvedUrl("components/TrackSwitcher.qml"), "properties" :
            {"height" : window.height - header.height, "width": "540"}}

    }
    Item {
        id: menuParent
        anchors.fill: parent
    }

    EnginioClient {
        id: client
        backendId: window.backendId

        Component.onCompleted:{
            if (userId.length === 0)
                createUser();
            else
                getUser()
        }

        function createUser()
        {
            console.log("createUser ")
            var reply = client.create({"objectType":"objects.User"})
            reply.finished.connect(function() {
                if (reply.errorType !== EnginioReply.NoError) {
                    console.log("Failed to create an user:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
                } else {
                    console.log("Account Created.")
                    userId = reply.data.id
                    userIdFile.write(userId)
                }
            })
        }

        function getUser()
        {
            console.log("get user "+userId)
            var queryUser = client.query({"objectType":"objects.User", "query" : { "id" : userId }})
            queryUser.finished.connect(function() {
                if (queryUser.errorType !== EnginioReply.NoError || queryUser.data.results[0] === undefined) {
                    // User not found. Create new one
                    userIdFile.write("")
                    userId = 0
                    createUser()
                }
            })
        }
    }

    function removeFavorite(removeEventId)
    {
        if (busy) {
            console.log("busy removing or saving favorite. Should we show some indicator here?")
            return
        }
        busy = true
        console.log("start removing favorite. First get the favorite id which should be removed")
        var favoriteQuery = client.query({
                                             "objectType": "objects.Favorite",
                                             "query":{
                                                 "favoriteEvent": {
                                                     "id": removeEventId,"objectType": "objects.Event"},
                                                 "user": {
                                                     "id": window.userId ,
                                                     "objectType": "objects.User"}}
                                         })

        favoriteQuery.finished.connect(function() {
            if (favoriteQuery.errorType !== EnginioReply.NoError) {
                console.log("Failed to query an Favorite:\n" + JSON.stringify(favoriteQuery.data, undefined, 2) + "\n\n")
            }
            else {
                if (favoriteQuery.data.results.length > 0) {
                    // Now do the actual removal
                    var reply = client.remove({ "objectType": "objects.Favorite",
                                                  "id": favoriteQuery.data.results[0].id })
                    reply.finished.connect(function() {
                        if (favoriteQuery.errorType !== EnginioReply.NoError) {
                            console.log("Failed to remove an Favorite:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
                        }
                        else {
                            // remove favorite from models too
                            eventModel.removeFavorite(removeEventId)
                            favoriteModel.removeRow(favoriteModel.indexOf("events_id", removeEventId))
                            window.updateFavoriteEvent = {'event':removeEventId, 'added':false}
                        }
                    })
                }
            }
            console.log("favorite remove done")
            busy = false
        })
    }

    function saveFavorite(saveEventId)
    {
        if (busy) {
            console.log("busy removing or saving favorite. Should we show some indicator here?")
            return
        }
        busy = true
        console.log("start saving favorite")
        var reply = client.create({
                                      "objectType": "objects.Favorite",
                                      "favoriteEvent": {
                                          "id": saveEventId,
                                          "objectType": "objects.Event"
                                      },
                                      "user": {
                                          "id": window.userId ,
                                          "objectType": "objects.User"}})

        reply.finished.connect(function() {
            if (reply.errorType !== EnginioReply.NoError) {
                console.log("Failed to create an Favorite:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
            } else {
                // Update models too:
                eventModel.addFavorite(saveEventId)
                var index = eventModel.indexOf("id", saveEventId)
                var tracks = eventModel.data(index, "tracks")
                console.log("favoriteModel rowcount "+favoriteModel.rowCount())
                if (favoriteModel.rowCount() <= 0){
                    console.log("no favorites yet. Get first from enginio so model is parsed correctly")
                    queryfavorites()
                }
                else {
                    console.log("there are already favorites, just add new row")
                    favoriteModel.addRow({"events_end":eventModel.data(index, "end"),"events_id":eventModel.data(index, "id"),
                                             "events_performer":eventModel.data(index, "performer"),
                                             "events_start":eventModel.data(index, "start"),"events_topic":eventModel.data(index, "topic"),
                                             "events_intro":eventModel.data(index, "intro"),
                                             "events_tracks":{
                                                 "name":tracks.name,"backgroundColor": tracks.backgroundColor,
                                                 "location": tracks.location, "trackNumber": tracks.trackNumber}})
                }
                // Inform that favorite has been added
                window.updateFavoriteEvent = {'event':saveEventId, 'added':true}
            }
            busy = false
            console.log("favorite save done")
        })
    }

    onUpdateFavoriteEventChanged: window.updateFavoriteSignal(updateFavoriteEvent.event, updateFavoriteEvent.added)

    onConferenceIdChanged: {
        console.log("query events. This is done when application starts")
        eventModel.query({ "objectType": "objects.Event",
                             "include": {
                                 "tracks": {
                                     "objectType": "objects.Track",
                                     "query": {"id": "$.track.id"},
                                     "result": "selectOne"
                                 }
                             }})
    }

    /******Models used by views**************/
    Model {
        id: eventModel
        backendId: window.backendId
        onDataReady: getFavoriteIds()
    }
    function getFavoriteIds()
    {
        var reply = client.query({"objectType": "objects.Favorite",
                                     "query":{
                                         "user": {
                                             "id": window.userId ,
                                             "objectType": "objects.User"}}
                                 })

        reply.finished.connect(function() {
            if (reply.errorType !== EnginioReply.NoError) {
                console.log("Failed to query an Favorite:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
            } else {
                for (var i = 0; i < reply.data.results.length; i++) {
                    var id = reply.data.results[i].favoriteEvent.id
                    eventModel.addFavorite(reply.data.results[i].favoriteEvent.id)
                }
            }
            // Inform models that favorites has changed
            window.updateFavoriteEvent = {'event':"", 'added':true}
        })
    }

    Model {
        id: favoriteModel;
        backendId: window.backendId
        Component.onCompleted: queryfavorites()
    }

    function queryfavorites()
    {
        var favQuery =favoriteModel.query({ "objectType": "objects.Favorite",
                                              "query":{
                                                  "user": {
                                                      "id": window.userId ,
                                                      "objectType": "objects.User"}
                                              },
                                              "include": {
                                                  "events": {
                                                      "objectType": "objects.Event",
                                                      "query": {"id": "$.favoriteEvent.id"},
                                                      "result": "selectOne",
                                                      "include": {
                                                          "tracks": {
                                                              "objectType": "objects.Track",
                                                              "query": {"id": "$.track.id"},
                                                              "result": "selectOne"
                                                          }
                                                      }
                                                  }
                                              }
                                          })
    }
}
