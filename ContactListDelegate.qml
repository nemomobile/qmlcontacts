/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Item {
    id: contactCardPortrait

    height: photo.height + itemMargins
    width: parent.width
    anchors.right: parent.right

    property int itemMargins: 10

    signal clicked

    // TODO: avatars should be centralised so we have error behaviour in both
    // list and card
    LimitedImage {
        id: photo
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true
        width: 64
        height: 64
        source: (model.person.avatarPath == "undefined") ? "image://theme/icon-m-telephony-contact-avatar" : model.person.avatarPath
        anchors {
            left: parent.left;
            leftMargin: 10
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
        text: model.person.displayLabel
        anchors {
            left: photo.right;
            verticalCenter: parent.verticalCenter;
            leftMargin: photo.height/8
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

