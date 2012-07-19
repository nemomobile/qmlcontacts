/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import "UIConstants.js" as UI

Item {
    id: contactCardPortrait

    height: UiConstants.ListItemHeightDefault
    width: parent.width
    anchors.right: parent.right

    signal clicked

    LimitedImage {
        id: photo
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true
        width: UiConstants.ListItemHeightSmall
        height: UiConstants.ListItemHeightSmall
        source: (model.contact.thumbnail == "undefined") ? "avatars/icon-contacts-default-avatar.svg" : model.contact.thumbnail
        anchors {
            left: parent.left;
            leftMargin: UiConstants.DefaultMargin
            verticalCenter: parent.verticalCenter
        }
        onStatusChanged: {
            if(photo.status == Image.Error || photo.status == Image.Null){
                photo.source = "image://theme/icon-m-telephony-contact-avatar"
            }
        }
    }

    Label {
        id: nameFirst
        text: model.contact.displayLabel
        anchors {
            left: photo.right;
            verticalCenter: parent.verticalCenter;
            leftMargin: UiConstants.DefaultMargin
        }
        smooth: true
    }

    MouseArea {
        id: mouseArea
        anchors.fill: contactCardPortrait
        onClicked: {
            contactCardPortrait.clicked();
        }
    }

    states: State {
        name: "pressed"; when: mouseArea.pressed == true
        PropertyChanges { target: contactCardPortrait; opacity: .7}
    }

}

