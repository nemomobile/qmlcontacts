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

    //: Truncate string - used when a string is too long for the display area
    property string stringTruncater: qsTr("…")

    function getTruncatedString(valueStr, stringLen) {
        var MAX_STR_LEN = stringLen;
        var multiline = (valueStr.indexOf("\n") == -1 ? false : true);
        var valueStr = valueStr.split("\n");
        var MAX_NEWLINE = valueStr.length-1;
        var newStr = "";
        for(var i = 0; i < valueStr.length; i++){
            //Make sure string is no longer than MAX_STR_LEN characters
            //Use MAX_STR_LEN - stringTruncater.length to make room for ellipses
            if (valueStr[i].length > MAX_STR_LEN) {
                valueStr[i] = valueStr[i].substring(0, MAX_STR_LEN - stringTruncater.length);
                valueStr[i] = valueStr[i] + stringTruncater;
            }
            if(multiline && (i<MAX_NEWLINE))
                newStr = newStr + valueStr[i] + "\n";
            else
                newStr = newStr + valueStr[i];
        }
        return newStr;
    }

    Item {
        id: detailsList
        anchors {
            left: parent.left; leftMargin: UiConstants.DefaultMargin;
            right: parent.right; rightMargin: UiConstants.DefaultMargin;
            top: parent.top; topMargin:  UiConstants.DefaultMargin
        }

        Column {
            id: phones
            visible: contact.phoneNumbers.length > 0
            spacing: UiConstants.DefaultMargin
            anchors { left: parent.left; right: parent.right; top: parent.bottom; topMargin: 40}

            Label {
                text: qsTr("Phone")
                font.bold: true
                font.pixelSize: 44
            }
            Repeater{
                id: detailsPhone
                model: contact.phoneNumbers

                Rectangle {
                    anchors { left: parent.left; right: parent.right }
                    height: childrenRect.height
                    color: "transparent"
                    Label {
                        text: modelData // getTruncatedString(modelData, 25) //FIXME - is this needed?
                        font.pixelSize: 36
                        anchors { left: parent.left; }
                    }
                    ButtonRow {
                        width: 140
                        anchors { right: parent.right }
                        exclusive: false
                        Button {
                            iconSource: "image://theme/icon-m-telephony-incoming-call"; height: 64;
                            onClicked: console.log("TODO: Make call to " + contact.firstName)
                        }
                        Button {
                            iconSource: "image://theme/icon-m-toolbar-send-sms";  height: 64;
                            onClicked: console.log("TODO: Send SMS to " + contact.firstName)
                        }
                    }
                }
            }
        }
    }
}

