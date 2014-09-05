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
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1
import Enginio 1.0
import TalkSchedule 1.0

Item {
    height: window.height
    width: window.width
    objectName: "feedback"
    property string eventId
    property string eventTopic
    property string eventPerformer
    property int rating: -1

    SubTitle {
        id: subTitle
        titleText: Theme.text.feedback
    }

    Column {
        anchors.top: subTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.margins.ten
        spacing: Theme.margins.five
        Text {
            text: eventTopic
            color: Theme.colors.black
            width: parent.width
            font.pointSize: Theme.fonts.twelve_pt
            maximumLineCount: 2
            wrapMode: Text.Wrap
            elide: Text.ElideRight
        }
        RowLayout {
            width: parent.width
            Label {
                id: eventPerformers
                text: eventPerformer
                font.pointSize: Theme.fonts.seven_pt
                color: Theme.colors.gray
            }
            Item {
                id: separator
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Slider {
                minimumValue: 0
                maximumValue: 4
                stepSize: 1
                onValueChanged: rating = value + 1
                style: SliderStyle {
                    handle: Item {}
                    groove: RowLayout {
                        Repeater {
                            model: 5
                            Image {
                                source: index <= (rating - 1) ? Theme.images.favorite : Theme.images.notFavorite
                                width: Theme.sizes.ratingImageWidth
                                height: Theme.sizes.ratingImageHeight
                                sourceSize.height: Theme.sizes.ratingImageHeight
                                sourceSize.width: Theme.sizes.ratingImageWidth
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            height: window.height / 3
            width: parent.width
            TextArea {
                id: feedbackEdit
                anchors.fill: parent
                textMargin: Theme.margins.ten
                wrapMode: TextEdit.Wrap
                onFocusChanged: text = ""
                textColor: text === Theme.text.writeYourCommentHere ? Theme.colors.gray : Theme.colors.black
                Component.onCompleted: text = Theme.text.writeYourCommentHere
            }
        }

        Row {
            spacing: Theme.margins.twenty
            Button {
                text: "Clear"
                onClicked: {
                    rating = -1
                    feedbackEdit.text = Theme.text.writeYourCommentHere
                }
                width: window.width / 3.5
                height: Theme.sizes.buttonHeight
                style: ButtonStyle {
                    background: Rectangle {
                        radius: 5
                        border.width: 2
                        border.color: Theme.colors.qtgreen
                        color: control.pressed ? Qt.darker(Theme.colors.white, 1.1) : Theme.colors.white
                    }
                    label: Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: control.text
                        color: Theme.colors.black
                        font.pointSize: Theme.fonts.six_pt
                    }
                }
            }
            Button {
                text: "Send"
                enabled: (feedbackEdit.text !== Theme.text.writeYourCommentHere && feedbackEdit.text !== "")
                         || rating > -1
                onClicked: {
                    text = "sending..."
                    Qt.inputMethod.hide()
                    ModelsSingleton.saveFeedback(feedbackEdit.text, eventId, rating)
                    stack.pop()
                }
                width: window.width / 3.5
                height: Theme.sizes.buttonHeight
                style: ButtonStyle {
                    background: Rectangle {
                        radius: 5
                        color: control.enabled ? (control.pressed ? Qt.darker(Theme.colors.qtgreen, 1.1) : Theme.colors.qtgreen)
                                               : Theme.colors.smokewhite
                    }
                    label: Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: control.text
                        color: control.enabled ? Theme.colors.black : Theme.colors.gray
                        font.pointSize: Theme.fonts.six_pt
                    }
                }
            }
        }
    }
}
