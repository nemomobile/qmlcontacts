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

Image {
    id: contactCardPortrait

    height: photo.height + itemMargins
    width: parent.width
    anchors.right: parent.right

    property string stringTruncater: qsTr("...")
    property int itemMargins: 10

    function getTruncatedString(valueStr, stringLen) {
        var MAX_STR_LEN = stringLen;
            //Make sure string is no longer than MAX_STR_LEN characters
            //Use MAX_STR_LEN - stringTruncater.length to make room for ellipses
            if (valueStr.length > MAX_STR_LEN) {
                valueStr = valueStr.substring(0, MAX_STR_LEN - stringTruncater.length);
                valueStr = valueStr + stringTruncater;
            }
        return valueStr;
    }

    //REVISIT: Instead of using the URI from AvatarRole, need to use thumbnail URI
    property string dataAvatar: model.person.avatarPath

    //: Remove favorite flag / remove contact from favorites list
    property string unfavoriteTranslated: qsTr("Unfavorite")

    //: Add favorite flag / add contact to favorites list
    property string favoriteTranslated: qsTr("Favorite", "Verb")

    //: Truncate string - used when a string is too long for the display area
    property string ellipse: qsTr("(...)")

    signal clicked
    signal pressAndHold(int mouseX, int mouseY, string uuid, string name)

    source: "image://themedimage/widgets/common/list/list"

    LimitedImage {
        id: photo
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true
        width: 64
        height: 64
        source: (dataAvatar ? dataAvatar : "image://theme/meegotouch-avatar-placeholder-background")
        anchors {
            left: parent.left;
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        onStatusChanged: {
            if(photo.status == Image.Error || photo.status == Image.Null){
                photo.source = "image://theme/meegotouch-avatar-placeholder-background"
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

    Image {
        id: favorite
        source: model.person.favorite  ? "image://themedimage/icons/actionbar/favorite-selected" : "image://themedimage/icons/actionbar/favorite"
        anchors {right: contactCardPortrait.right; top: nameFirst.top; rightMargin: photo.height/8;}
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

