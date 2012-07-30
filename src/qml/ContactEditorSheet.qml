import QtQuick 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants
import org.nemomobile.qmlcontacts 1.0
import org.nemomobile.contacts 1.0

Sheet {
    id: newContactViewPage
    acceptButtonText: "Save"
    rejectButtonText: "Cancel"

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
        data_avatar.contact = contact

        var tmpList = []
        for (var i = 0; i < contact.phoneNumbers.length; ++i) {
            tmpList.push(contact.phoneNumbers[i])
        }
        phoneRepeater.setModelData(tmpList)
    }

    content: Flickable {
        anchors.fill: parent
        contentHeight: editorContent.childrenRect.height +
        UiConstants.DefaultMargin

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
                    Constants.loadSingleton("AvatarPickerSheet.qml", newContactViewPage,
                        function(avatarPicker) {
                            avatarPicker.contact = contact
                            avatarPicker.avatarPicked.disconnect()
                            avatarPicker.avatarPicked.connect(function(avatar) {
                                data_avatar.source = avatar
                            });
                            avatarPicker.open();
                        }
                    );
                }
                ContactAvatarImage {
                    id: data_avatar
                    width: parent.width - UiConstants.DefaultMargin
                    height: parent.height - UiConstants.DefaultMargin
                    anchors.centerIn: parent
                    contact: newContactViewPage.contact
                }
            }
            TextField {
                id: data_first
                placeholderText: qsTr("First name")
                anchors { top: avatarRect.top; right: parent.right; left: avatarRect.right; leftMargin: UiConstants.DefaultMargin }
            }
            TextField {
                id: data_last
                placeholderText: qsTr("Last name")
                anchors { top: data_first.bottom;
                    topMargin: UiConstants.DefaultMargin;
                    right: parent.right; left: data_first.left
                }
            }

            Column {
                anchors.top: data_last.bottom
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
        }
    }

    onAccepted: saveContact();

    function saveContact() {
        contact.firstName = data_first.text
        contact.lastName = data_last.text
        contact.avatarPath = data_avatar.source
        contact.phoneNumbers = phoneRepeater.modelData()

        // TODO: this isn't asynchronous
        app.contactListModel.savePerson(contact)

        // TODO: revisit
        if (contact.dirty)
            console.log("[saveContact] Unable to create new contact due to missing info");
        else
            console.log("[saveContact] Saved contact")
    }
}


