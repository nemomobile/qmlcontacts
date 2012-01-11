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
import "PageManager.js" as PageManager

Item {
    id: newContactPage
    anchors { leftMargin: 20; rightMargin: 20; fill:parent }
    property Person contact: PageManager.createNextPerson()

    function contactSave() {
        contact.firstName = data_first.text
        contact.lastName = data_last.text
        contact.phoneNumbers = phoneModel.dataList()

        var ret = PageManager.peopleModel.savePerson(contact)

        if (!ret) //REVISIT
            console.log("[contactSave] Unable to create new contact due to missing info");
    }

    Item {
        id: avatarRect
        width: height
        anchors { top: parent.top; topMargin: 20; left:parent.left; bottom: data_last.bottom }
        Image {
            id: data_avatar
            source: (contact.avatarPath == "undefined") ? "image://theme/icon-m-telephony-contact-avatar" : contact.avatarPath
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
        }
    }

    TextField {
        id: data_first
        placeholderText: qsTr("First name")
        text: contact.firstName
        anchors { top: avatarRect.top; right: parent.right; left: avatarRect.right; leftMargin: 20 }
    }
    TextField {
        id: data_last
        placeholderText: qsTr("Last name")
        text: contact.lastName
        anchors { top: data_first.bottom; topMargin:10; right: parent.right; left: data_first.left }
    }

    Column {
        anchors { top: data_last.bottom; topMargin: 20 }
        width: parent.width
        spacing: 10
        Repeater {
            id: repeaterPhoneNumbers
            model: EditableModel {
                id: phoneModel
                sourceList: contact.phoneNumbers
                Component.onCompleted: { if (contact.phoneNumbers.count) console.log("No need to add phone number"); else phoneModel.addNew(); } //FIXME - this does not seem to work
            }
            delegate: TextField {
                id: data_phone
                placeholderText: qsTr("Phone number")
                width: parent.width
                text: model.data
                onTextChanged: phoneModel.setValue(index, data_phone.text)
            }
        }
    }

    Button {
        text: qsTr("Add phone number")
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 20 }
        onClicked: {
            phoneModel.addNew()
        }
    }
}

