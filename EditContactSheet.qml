import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Sheet {
    acceptButtonText: "Save"
    rejectButtonText: "Cancel"

    property bool validInput: false

    property string contextHome: qsTr("Home")
    property string contextWork: qsTr("Work")
    property string contextOther: qsTr("Other")
    property string contextMobile: qsTr("Mobile")
    property string defaultFirstName: qsTr("First name")
    property string defaultLastName: qsTr("Last name")
    property string defaultPronounciation: qsTr("Pronounciation")
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string defaultBirthday: qsTr("Enter birthday")
    property string headerBirthday: qsTr("Birthday")
    property string headerNote: qsTr("Note")

    property string favoriteValue: "Favorite"
    property string unfavoriteValue: "Unfavorite"

    //: Add favorite flag / add contact to favorites list
    property string favoriteTranslated: qsTr("Favorite", "Verb")

    //: Remove favorite flag / remove contact from favorites list
    property string unfavoriteTranslated: qsTr("Unfavorite")

    property string phoneLabel: qsTr("Phone numbers")
    property string addPhones: qsTr("Add number")

    //: Instant Messaging Accounts for this contact
    property string imLabel: qsTr("Instant messaging")
    property string emailLabel: qsTr("Email")
    property string addEmails: qsTr("Add email address")

    //: The header for the section that shows the web sites for this contact
    property string urlLabel: qsTr("Web")
    property string addUrls: qsTr("Add web page")
    property string addressLabel: qsTr("Address")
    property string addAddress: qsTr("Add address")

    content: EditViewPortrait {
        id: contactEditor
    }


/*            actionMenuModel: (window.currentContactId == 2147483647 ? (editContact.validInput ? [contextSave, contextCancel] : [contextCancel]) : (editContact.validInput ? [contextSave, contextCancel, contextDelete] : [contextCancel, contextDelete]))
    actionMenuPayload: (window.currentContactId == 2147483647 ? (editContact.validInput ? [0, 1] : [0]) : (editContact.validInput ? [0, 1, 2] : [0, 1]))
    onActionMenuTriggered: {
        if(actionMenuModel[selectedItem] == contextSave) {
            window.switchBook(myAppAllContacts);
            editContact.contactSave(window.currentContactId);
        }
        else if(actionMenuModel[selectedItem] == contextCancel) {
            window.switchBook(myAppAllContacts);
        }
        else if(actionMenuModel[selectedItem] == contextDelete) {
            confirmDelete.show();
        }
    }
    onActivated: {
        editContact.index = proxyModel.getSourceRow(window.currentContactIndex);
        editContact.finishPageLoad();
    }
*/

    onAccepted: contactEditor.contactSave(window.currentContactId);
}


