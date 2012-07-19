/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0

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
        elide: Text.ElideRight
        anchors {
            left: photo.right;
            right: favorite.visible ? favorite.left : parent.right
            verticalCenter: parent.verticalCenter;
            leftMargin: UiConstants.DefaultMargin
        }
        smooth: true
    }

    // TODO: only instantiate if required?
    Image {
        id: favorite
        source: "image://theme/icon-m-toolbar-favorite-mark"
        visible: contact.favorite.favorite
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
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

