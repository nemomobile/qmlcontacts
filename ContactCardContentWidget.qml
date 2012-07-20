/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import QtMobility.contacts 1.1
import com.nokia.meego 1.0

Flickable {
    id: detailViewPortrait
    contentWidth: parent.width
    contentHeight: detailsList.height
    flickableDirection: Flickable.VerticalFlick
    clip: true

    property Contact contact

    Item {
        id: detailsList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: UiConstants.DefaultMargin

        Column {
            id: phones
            spacing: UiConstants.DefaultMargin / 2
            anchors { left: parent.left; right: parent.right; top: parent.top; }
            visible: contact.phoneNumber.number != ""

            // TODO: use a repeater here somehow
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 90

                Label {
                    text: contact.phoneNumber.number
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                ButtonRow {
                    width: 240
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    exclusive: false
                    Button {
                        iconSource: "image://theme/icon-m-telephony-incoming-call";
                        height: 80;
                        onClicked: console.log("TODO: Make call to " + contact.firstName)
                    }
                    Button {
                        iconSource: "image://theme/icon-m-toolbar-send-sms";
                        height: 80;
                        onClicked: console.log("TODO: Send SMS to " + contact.firstName)
                    }
                }
            }
        }
    }
}

