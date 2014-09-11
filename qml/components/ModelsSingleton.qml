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

pragma Singleton
import QtQuick 2.2
import Enginio 1.0
import TalkSchedule 1.0

QtObject {
    id: object
    property string conferenceId
    property string currentUserId
    property string conferenceLocation
    property string conferenceTitle
    property string conferenceTwitterTag
    property string rssFeed
    property var currentConferenceTracks: []
    property var currentConferenceEvents: []
    property var currentConferenceDays: []
    property bool busy: false
    property string errorMessage
    property int conferenceIndex: 0
    property var conference
    property var client: EnginioClient {
        backendId: backId
        onError: {
            errorMessage = reply.errorString
            console.log("Enginio error " + reply.errorCode + ": " + reply.errorString)
        }
        Component.onCompleted: conferencesModel.query({"objectType": "objects.Conference"})
    }

    signal writeUserIdToFile(string userId)

    property var conferencesModel: Model {
        backendId: backId
        fileNameTag: "ConferencesObject"
        onDataReady: {
            if (conferencesModel.rowCount() > 0) {
                ModelsSingleton.conferenceId = conferencesModel.data(0, "id")
                ModelsSingleton.conferenceLocation = conferencesModel.data(0, "location")
                ModelsSingleton.conferenceTitle = conferencesModel.data(0, "title")
                ModelsSingleton.conferenceTwitterTag = conferencesModel.data(0, "TwitterTag")
                ModelsSingleton.rssFeed = conferencesModel.data(0, "rssFeed")
            }
        }
    }

    property var day: Model {
        backendId: backId
        fileNameTag: "DayObject"
        onDataReady: {
            currentConferenceDays = []
            for (var i = 0; i < day.rowCount(); i++)
                currentConferenceDays[i] = day.data(i, "id")
            queryConferenceBreaks()
        }
    }

    property var trackModel: Model {
        backendId: backId
        fileNameTag: "TrackObject"
        onDataReady: {
            currentConferenceTracks = []
            for (var i = 0; i < trackModel.rowCount(); i++)
                currentConferenceTracks[i] = trackModel.data(i, "id")
            queryConferenceEvents()
        }
    }

    property var eventModel: Model {
        id: eventModel
        backendId: backId
        fileNameTag: "EventObject"
        onDataReady: queryFavorites()
        function queryFavorites()
        {
            currentConferenceEvents = []
            for (var i = 0; i < eventModel.rowCount(); i++)
                currentConferenceEvents[i] = eventModel.data(i, "id")
            queryUserConferenceFavorites()
        }
    }

    property var favoriteModel: Model {
        // do not save favorite
        backendId: backId
        onDataReady: getFavoriteIds()
    }

    property var breakModel: Model {
        fileNameTag: "BreakObject"
        backendId: backId
    }

    property var timeListModel: Model {
        // do not save time list
        backendId: backId
        property var tracksTodayModel
        onTracksTodayModelChanged: {
            if (!!tracksTodayModel) {
                var todaysTracks = []
                for (var i = 0; i < tracksTodayModel.rowCount(); i++)
                    todaysTracks.push(tracksTodayModel.data(i, "id"))
                timeListModel.query({ "objectType": "objects.Event",
                                        "sort" : [{"sortBy": "start", "direction": "asc"}],
                                        "query": { "track.id" : { "$in" : todaysTracks } }
                                    })
            }
        }
    }

    function queryConferenceEvents()
    {
        eventModel.query({
                             "objectType": "objects.Event",
                             "query": { "track.id" : { "$in" : currentConferenceTracks } },
                             "include": {
                                 "tracks": {
                                     "objectType": "objects.Track",
                                     "query": {"id": "$.track.id"},
                                     "result": "selectOne",
                                 }
                             }
                         })
    }

    function queryConferenceBreaks()
    {
        breakModel.query({
                             "objectType": "objects.Break",
                             "query": { "day.id" : { "$in" : currentConferenceDays } },
                         })
    }

    function getFavoriteIds()
    {
        for (var i = 0; i < favoriteModel.rowCount(); i++)
            eventModel.addFavorite(favoriteModel.data(i, "events_id"))
    }

    function queryUserConferenceFavorites()
    {
        var favQuery = favoriteModel.query({ "objectType": "objects.Favorite",
                                               "query": {
                                                   "user.id": currentUserId,
                                                   "favoriteEvent.id" : { "$in" : currentConferenceEvents }
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

    function retrieveUser(userId)
    {
        currentUserId = userId
        if (currentUserId.length === 0)
            createUser()
        else
            getUser()
    }

    function createUser()
    {
        console.log("createUser")
        var reply = client.create({"objectType":"objects.User"})
        var userId = 0
        reply.finished.connect(function() {
            if (reply.errorType !== EnginioReply.NoError) {
                console.log("Failed to create an user:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
            } else {
                console.log("Account Created.")
                userId = reply.data.id
                writeUserIdToFile(userId)
                currentUserId = userId
            }
        })
    }

    function getUser()
    {
        console.log("get user")
        var queryUser = client.query({"objectType":"objects.User", "query" : { "id" : currentUserId }})
        queryUser.finished.connect(function() {
            if (queryUser.errorType !== EnginioReply.NoError || queryUser.data.results[0] === undefined) {
                // User not found. Create new one
                userIdFile.write("")
                createUser()
            }
        })
    }

    function saveFeedback(fbtext, eventId, rating)
    {
        console.log("saveFeedback")
        var reply = client.create({
                                      "objectType": "objects.Feedback",
                                      "event": {
                                          "id": eventId,
                                          "objectType": "objects.Event"
                                      },
                                      "rating": rating,
                                      "feedbackText": fbtext,
                                      "userId": ModelsSingleton.currentUserId
                                  })
        reply.finished.connect(function() {
            if (reply.errorType !== EnginioReply.NoError) {
                console.log("Failed to save feedback.\n")
            } else {
                console.log("Successfully saved feedback.\n")
            }
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
                                          "id": currentUserId,
                                          "objectType": "objects.User"}})

        reply.finished.connect(function() {
            if (reply.errorType !== EnginioReply.NoError)
                console.log("Failed to create an Favorite:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
            else
                eventModel.addFavorite(saveEventId)
            busy = false
            console.log("favorite save done")
        })
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
                                                     "id": removeEventId,
                                                     "objectType": "objects.Event"},
                                                 "user": {
                                                     "id": currentUserId ,
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
                        if (favoriteQuery.errorType !== EnginioReply.NoError)
                            console.log("Failed to remove an Favorite:\n" + JSON.stringify(reply.data, undefined, 2) + "\n\n")
                        else
                            eventModel.removeFavorite(removeEventId)
                    })
                }
            }
            console.log("favorite remove done")
            busy = false
        })
    }

    onConferenceIdChanged: {
        if (ModelsSingleton.conferenceId === "")
            return

        day.conferenceId = ModelsSingleton.conferenceId
        trackModel.conferenceId = ModelsSingleton.conferenceId
        eventModel.conferenceId = ModelsSingleton.conferenceId
        favoriteModel.conferenceId = ModelsSingleton.conferenceId
        breakModel.conferenceId = ModelsSingleton.conferenceId
        timeListModel.conferenceId = ModelsSingleton.conferenceId

        day.query({ "objectType": "objects.Day",
                      "query": {
                          "conference": {
                              "id": object.conferenceId,
                              "objectType": "objects.Conference"
                          }
                      }
                  })
        trackModel.query({"objectType": "objects.Track",
                             "query": {
                                 "conference": {
                                     "id": object.conferenceId,
                                     "objectType": "objects.Conference"
                                 }
                             }
                         });
    }
}
