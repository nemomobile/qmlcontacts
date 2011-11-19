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

Column {
    id: newContactPage

    property Person contact: PageManager.createNextPerson()
    property string defaultFirstName: qsTr("First name")
    property string defaultLastName: qsTr("Last name")
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string headerNote: qsTr("Note")

    property string phoneLabel: qsTr("Phone numbers")
    property string addPhones: qsTr("Add number")

    function contactSave(){
        contact.firstName = data_first.text
        contact.lastName = data_last.text
        contact.phoneNumbers = phoneModel.dataList()

        var ret = peopleModel.savePerson(contact)

        if (!ret) //REVISIT
            console.log("[contactSave] Unable to create new contact due to missing info");
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        TextField {
            id: data_first
            placeholderText: defaultFirstName
            text: contact.firstName
        }
        TextField {
            id: data_last
            placeholderText: defaultLastName
            text: contact.lastName
        }
        TextField {
            id: data_company
            placeholderText: defaultCompany
            text: contact.companyName
        }
    }

    Column {
        id: phones

        Label {
            text: phoneLabel
            font.bold: true
        }

        Repeater {
            id: detailsPhone
            model: EditableModel {
                id: phoneModel
                sourceList: contact.phoneNumbers
            }
            delegate: Row {
                TextField {
                    id: data_phone
                    text: model.data
                }

                Button {
                    text: "save"
                    onClicked: phoneModel.setValue(model.index, data_phone.text)
                }
            }
        }

        Button {
            text: addPhones
            onClicked: {
                phoneModel.addNew()
            }
        }
    }

    Column {
        id: notesHeader

        Label {
            id: label_notes
            text: headerNote
            font.bold: true
        }


        TextField{
            id: data_notes
            placeholderText: defaultNote
            width:540
            height: 300
        }
    }
}

