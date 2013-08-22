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

import QtQuick 2.0
import com.nokia.meego 2.0
import org.nemomobile.contacts 1.0
import org.nemomobile.qmlcontacts 1.0
import org.nemomobile.voicecall 1.0

Flickable {
    id: detailViewPortrait
    contentWidth: parent.width
    contentHeight: childrenRect.height
    flickableDirection: Flickable.VerticalFlick
    clip: true

    property Person contact
    property VoiceCallManager callManager

    Item {
        id: header
        height: avatar.height + UiConstants.DefaultMargin
        property int shortSize: parent.parent.width > parent.parent.height ? parent.parent.height : parent.parent.width
        ContactAvatarImage {
            id: avatar
            contact: detailViewPage.contact
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: UiConstants.DefaultMargin
            width: parent.shortSize * 0.3
            height: parent.shortSize * 0.3
        }

        Label {
            anchors.verticalCenter: avatar.verticalCenter
            anchors.left: avatar.right
            anchors.leftMargin: UiConstants.DefaultMargin
            text: contact.displayLabel
        }
    }

    SelectionDialog {
        id: selectionDialog
        property int mode: 0 // 0: call, 1: sms, 2: message, 3: mail

        onSelectedIndexChanged: {
            if (mode == 0)
                callManager.dial(callManager.defaultProviderId, contact.phoneNumbers[selectedIndex]);
            else if (mode == 1)
                onClicked: messagesInterface.startSMS(contact.phoneNumbers[selectedIndex])
            else if (mode == 2)
                messagesInterface.startConversation(contact.accountPaths[selectedIndex], contact.accountUris[selectedIndex])
                
            accept()
        }
    }

    Button {
        id: callButton
        anchors.top: header.bottom
        anchors.topMargin: UiConstants.DefaultMargin
        anchors.left: parent.left
        anchors.leftMargin: UiConstants.DefaultMargin
        height: contact.phoneNumbers.length ? UiConstants.ListItemHeightDefault - UiConstants.DefaultMargin : 0
        width: parent.width - UiConstants.DefaultMargin * 2
        visible: height != 0
        iconSource: "image://theme/icon-m-telephony-incoming-call"; // TODO: icon-m-toolbar-make-call
        text: "Call"
        onClicked: {
            if (contact.phoneNumbers.length == 1) {
                callManager.dial(callManager.defaultProviderId, contact.phoneNumbers[0])
                return
            }

            selectionDialog.mode = 0
            selectionDialog.titleText = qsTr("Call %1").arg(contact.firstName)
            selectionDialog.model = contact.phoneNumbers
            selectionDialog.open()
        }
    }

    Button {
        id: smsButton
        anchors.top: callButton.bottom
        anchors.topMargin: UiConstants.DefaultMargin
        anchors.left: parent.left
        anchors.leftMargin: UiConstants.DefaultMargin
        height: contact.phoneNumbers.length ? UiConstants.ListItemHeightDefault - UiConstants.DefaultMargin : 0
        width: parent.width - UiConstants.DefaultMargin * 2
        visible: height != 0
        iconSource: "image://theme/icon-m-toolbar-send-chat";
        text: "SMS"
        onClicked: {
            if (contact.phoneNumbers.length == 1) {
                messagesInterface.startSMS(contact.phoneNumbers[0])
                return
            }

            selectionDialog.mode = 1
            selectionDialog.titleText = qsTr("SMS %1").arg(contact.firstName)
            selectionDialog.model = contact.phoneNumbers
            selectionDialog.open()
        }
    }

    Button {
        id: messageButton
        anchors.top: smsButton.bottom
        anchors.topMargin: UiConstants.DefaultMargin
        anchors.left: parent.left
        anchors.leftMargin: UiConstants.DefaultMargin
        height: contact.accountUris.length ? UiConstants.ListItemHeightDefault - UiConstants.DefaultMargin : 0
        width: parent.width - UiConstants.DefaultMargin * 2
        visible: height != 0
        iconSource: "image://theme/icon-m-toolbar-send-chat";
        text: "Message"
        onClicked: {
            if (contact.accountUris.length == 1) {
                messagesInterface.startConversation(contact.accountPaths[0], contact.accountUris[0])
                return
            }

            selectionDialog.mode = 2
            selectionDialog.titleText = qsTr("Message %1").arg(contact.firstName)
            selectionDialog.model = contact.accountUris
            selectionDialog.open()
        }
    }

    Button {
        id: mailButton
        anchors.top: messageButton.bottom
        anchors.topMargin: UiConstants.DefaultMargin
        anchors.left: parent.left
        anchors.leftMargin: UiConstants.DefaultMargin
        height: contact.emailAddresses.length ? UiConstants.ListItemHeightDefault - UiConstants.DefaultMargin : 0
        width: parent.width - UiConstants.DefaultMargin * 2
        visible: height != 0
        iconSource: "image://theme/icon-m-toolbar-send-sms"; // TODO: icon-m-toolbar-send-email
        text: "Mail"
        onClicked: {
            console.log("TODO: integrate with mail client")
            if (contact.emailAddresses.length == 1)
                return

            selectionDialog.mode = 3
            selectionDialog.titleText = qsTr("Mail %1").arg(contact.firstName)
            selectionDialog.model = contact.emailAddresses
            selectionDialog.open()
        }
    }
}

