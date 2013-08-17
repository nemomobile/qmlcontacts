/*
 * Copyright (C) 2012 Jolla Ltd.
 * Copyright (C) 2011-2012 Robin Burchell <robin+mer@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import com.nokia.meego 2.0
import org.nemomobile.qmlcontacts 1.0
import org.nemomobile.contacts 1.0

Sheet {
    id: newContactViewPage

    acceptButtonText: qsTr("Save")
    rejectButtonText: qsTr("Cancel")

    acceptButtonEnabled: data_first.edited || data_last.edited || 
                         data_company.edited ||
                         data_avatar.edited || phoneRepeater.edited ||
                         emailRepeater.edited || addressRepeater.edited

    property Person contact

    Connections {
        target: contact
        onContactRemoved: {
            reject()
        }
    }


    onContactChanged: {
        data_first.text = contact.firstName
        data_last.text = contact.lastName
        data_company.text = contact.companyName
        data_avatar.contact = contact
        if (contact.avatarPath != "image://theme/icon-m-telephony-contact-avatar" )
            data_avatar.originalSource = "image://nemothumbnail/" + contact.avatarPath
        else
            data_avatar.originalSource = contact.avatarPath

        phoneRepeater.setModelData(contact.phoneNumbers)
        emailRepeater.setModelData(contact.emailAddresses)
        addressRepeater.setModelData(contact.addressTypes, contact.addresses)
    }
    
    SelectionDialog {
        id: selectionDialog
        titleText: qsTr("Select work, home or other address")

        onSelectedIndexChanged: {
            if (selectedIndex != -1)
            {
                addressRepeater.addNewData(selectionDialog.model.get(selectedIndex).name);
            }
        }
    }

    content: Flickable {
        anchors.fill: parent
        contentHeight: editorContent.childrenRect.height + UiConstants.DefaultMargin * 2

        Item {
            id: editorContent
            anchors.leftMargin: UiConstants.DefaultMargin
            anchors.rightMargin: UiConstants.DefaultMargin
            anchors.fill: parent

            Button {
                id: avatarRect
                width: height
                anchors { top: parent.top; topMargin: UiConstants.DefaultMargin; left:parent.left; bottom: data_last.bottom }
                onClicked: {
                    var avatarPicker = pageStack.openSheet(Qt.resolvedUrl("AvatarPickerSheet.qml"), { contact: contact })
                    avatarPicker.avatarPicked.disconnect()
                    avatarPicker.avatarPicked.connect(function(avatar) {
                        data_avatar.source = avatar
                    });
                }
                ContactAvatarImage {
                    id: data_avatar
                    property string originalSource
                    property bool edited: source != originalSource
                    width: parent.width - UiConstants.DefaultMargin
                    height: parent.height - UiConstants.DefaultMargin
                    anchors.centerIn: parent
                    contact: newContactViewPage.contact
                }
            }
            TextField {
                id: data_first
                placeholderText: qsTr("First name")
                property bool edited: data_first.text != contact.firstName
                anchors { top: avatarRect.top; right: parent.right; left: avatarRect.right; leftMargin: UiConstants.DefaultMargin }
            }
            TextField {
                id: data_last
                placeholderText: qsTr("Last name")
                property bool edited: text != contact.lastName
                anchors { top: data_first.bottom;
                    topMargin: UiConstants.DefaultMargin;
                    right: parent.right; left: data_first.left
                }
            }
            TextField {
                id: data_company
                placeholderText: qsTr("Company")
                property bool edited: text != contact.companyName
                anchors { top: data_last.bottom;
                    topMargin: UiConstants.DefaultMargin;
                    right: parent.right; left: data_last.left
                }
            }

            Column {
                id: phones
                anchors.top: data_company.bottom
                anchors.topMargin: UiConstants.DefaultMargin
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: UiConstants.DefaultMargin

                EditableList {
                    id: phoneRepeater
                    placeholderText: qsTr("Phone number")
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }

            Column {
                id: emails
                anchors.top: phones.bottom
                anchors.topMargin: UiConstants.DefaultMargin
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: UiConstants.DefaultMargin

                EditableList {
                    id: emailRepeater
                    placeholderText: qsTr("Email address")
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
            
            Button {
                id: buttonAddAddress
                anchors.top: emails.bottom
                anchors.topMargin: UiConstants.DefaultMargin
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                width: 200
                visible: true
                text: "Add address"
                onClicked: {
                     selectionDialog.model.clear();
                     var iCount = 0;

                     if (!addressRepeater.isAddressTypeExists("Work"))
                     {
                         selectionDialog.model.append( { name: "Work" } );
                         iCount = 1;
                     }
                     if (!addressRepeater.isAddressTypeExists("Home"))
                     {
                         selectionDialog.model.append( { name: "Home" } );
                         iCount = 1;
                     }
                     if (!addressRepeater.isAddressTypeExists("Other"))
                     {
                         selectionDialog.model.append( { name: "Other" } );
                         iCount = 1;
                     }

                     if (iCount != 0)
                     {
                         selectionDialog.selectedIndex = -1;
                         selectionDialog.open()
                     }
                }
            }
            
            Column {
                anchors.top: buttonAddAddress.bottom
                anchors.topMargin: UiConstants.DefaultMargin
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: UiConstants.DefaultMargin

                EditAddress {
                    id: addressRepeater
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }

        }
    }

    onAccepted: saveContact();

    function saveContact() {
        contact.firstName = data_first.text
        contact.lastName = data_last.text
        contact.companyName = data_company.text
        contact.avatarPath = data_avatar.source
        contact.phoneNumbers = phoneRepeater.modelData()
        contact.emailAddresses = emailRepeater.modelData()
        contact.addresses = addressRepeater.modelData()
        contact.addressTypes = addressRepeater.modelDataTypes()

        // TODO: this isn't asynchronous
        app.contactListModel.savePerson(contact)

        // TODO: revisit
        if (contact.dirty)
            console.log("[saveContact] Unable to create new contact due to missing info");
        else
        {
            console.log("[saveContact] Saved contact")
            pageStack.currentPage.contactChange();      
        }
    }
}


