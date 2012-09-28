/*
 * Copyright (C) 2011-2012 Robin Burchell <robin+mer@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import org.nemomobile.contacts 1.0
import stage.rubyx.voicecall 1.0

Flickable {
    id: detailViewPortrait
    contentWidth: parent.width
    contentHeight: detailsList.height + (UiConstants.DefaultMargin * 2)
    flickableDirection: Flickable.VerticalFlick
    clip: true

    property Person contact
    property VoiceCallManager callManager

    Item {
        id: detailsList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: UiConstants.DefaultMargin
        height: phones.childrenRect.height

        ListView {
            id: phones
            anchors { left: parent.left; right: parent.right; top: parent.top; }
            model: contact.phoneNumbers
            interactive: false
            height: childrenRect.height
            delegate: Label {
                anchors.left: parent.left
                anchors.right: parent.right
                height: UiConstants.ListItemHeightDefault
                text: model.modelData
                verticalAlignment: Text.AlignVCenter

                ButtonRow {
                    width: 220
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: UiConstants.DefaultMargin / 2
                    anchors.bottomMargin: UiConstants.DefaultMargin / 2
                    anchors.rightMargin: UiConstants.DefaultMargin
                    exclusive: false
                    Button {
                        height: parent.height
                        iconSource: "image://theme/icon-m-telephony-incoming-call";
                        onClicked: callManager.dial(callManager.defaultProviderId, model.modelData);
                    }
                    Button {
                        height: parent.height
                        iconSource: "image://theme/icon-m-toolbar-send-sms";
                        onClicked: console.log("TODO: Send SMS to " + contact.firstName)
                    }
                }
            }
        }

        ListView {
            id: emails
            anchors { left: parent.left; right: parent.right; top: phones.bottom; }
            model: contact.emailAddresses
            interactive: false
            height: childrenRect.height
            delegate: Label {
                anchors.left: parent.left
                anchors.right: parent.right
                height: UiConstants.ListItemHeightDefault
                text: model.modelData
                verticalAlignment: Text.AlignVCenter

                Button {
                    width: 110
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: UiConstants.DefaultMargin / 2
                    anchors.bottomMargin: UiConstants.DefaultMargin / 2
                    anchors.rightMargin: UiConstants.DefaultMargin
                    iconSource: "image://theme/icon-l-email";
                    onClicked: console.log("TODO: Send SMS to " + contact.firstName)
                }
            }
        }

    }
}

