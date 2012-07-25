import QtQuick 1.1
import QtMobility.contacts 1.1
import com.nokia.meego 1.1

QueryDialog {
    property Contact contact: Contact {}

    titleText: "Delete " + contact.displayLabel + "?"
    message: "Are you sure?"
    acceptButtonText: "Yes"
    rejectButtonText: "No"

    onAccepted: {
        app.contactListModel.removeContact(contact.contactId)
    }
}
