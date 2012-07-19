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
import "constants.js" as Constants

Item {
    id: newContactPage
    property Contact contact: Contact {}
    anchors { leftMargin: UiConstants.DefaultMargin; rightMargin: UiConstants.DefaultMargin; fill:parent }

    function contactSave() {
        newContactPage.contact.name.firstName = data_first.text
        newContactPage.contact.name.lastName = data_last.text

        // TODO: this isn't asynchronous
        app.contactListModel.saveContact(newContactPage.contact)

        // TODO: revisit
        if (contact.dirty)
            console.log("[contactSave] Unable to create new contact due to missing info");
        else
            console.log("[contactSave] Saved contact")
    }


    Button {
        id: avatarRect
        width: height
        anchors { top: parent.top; topMargin: UiConstants.DefaultMargin; left:parent.left; bottom: data_last.bottom }
        onClicked: { PageManager.openAvatarPicker(newContactPage, contact.id) }
        Image {
            id: data_avatar
            source: (contact.avatarPath == "undefined") ? "avatars/icon-contacts-default-avatar.svg" : contact.avatarPath
            width: parent.width - 10
            height: parent.height - 10
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectCrop
            anchors.centerIn: parent
        }
    }
    TextField {
        id: data_first
        placeholderText: qsTr("First name")
        text: contact.firstName
        anchors { top: avatarRect.top; right: parent.right; left: avatarRect.right; leftMargin: UiConstants.DefaultMargin }
    }
    TextField {
        id: data_last
        placeholderText: qsTr("Last name")
        text: contact.lastName
        anchors { top: data_first.bottom; topMargin:10; right: parent.right; left: data_first.left }
    }

    Column {
        anchors { top: data_last.bottom; topMargin: UiConstants.DefaultMargin }
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
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: UiConstants.DefaultMargin }
        onClicked: {
            phoneModel.addNew()
        }
    }
}

