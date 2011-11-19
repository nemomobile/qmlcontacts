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

Flickable {
    id: detailViewPortrait
    contentWidth: parent.width
    contentHeight: detailsList.height
    flickableDirection: Flickable.VerticalFlick
    clip: true

    property Person contact

    property string headerPhone: qsTr("Phone numbers")

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

    Column {
        id: detailsList
        spacing: 1
        anchors { fill: parent; leftMargin:10; rightMargin:10;}

        Label {
            id: company
            width: parent.width
            text: contact.companyName
            elide: Text.ElideRight
        }

        Column {
            id: phones
            visible: contact.phoneNumbers.length > 0

            Label {
                text: headerPhone
                font.bold: true
            }

            Repeater{
                id: detailsPhone
                model: contact.phoneNumbers

                Button {
                    id: data_phone
                    text: getTruncatedString(modelData, 25)
                }
            }

        }
    }
}

