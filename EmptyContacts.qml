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
    id: emptyContactsView
    width: parent.width
    height: parent.height

    property string subText: qsTr("You haven't added any contacts yet.")
    property string addContact: qsTr("Add a contact")

    anchors { top: parent.top; right: parent.right; }
    signal clicked()

    Image {
        id: avatar
        source: "image://themedimage/icons/oobe/contacts-unavailable"
        opacity: 1
        anchors{ horizontalCenter: parent.horizontalCenter;  bottom: parent.bottom; bottomMargin: parent.height/2; }
    } 
    Text {
        id: no_contacts
        text: subText
        smooth: true
        anchors {top: avatar.bottom; topMargin: 40; horizontalCenter: parent.horizontalCenter;}
        opacity: 1
    }

    Button {
        id: button
        text: addContact
        enabled: true
        anchors{ top: no_contacts.bottom; topMargin: 30; horizontalCenter: no_contacts.horizontalCenter;}
        height: 60
        opacity: 1
        onClicked: {
            emptyContactsView.clicked()
        }
    }
}
