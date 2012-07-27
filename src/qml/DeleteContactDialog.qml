import QtQuick 1.1
import com.nokia.meego 1.1
import org.nemomobile.contacts 1.0

QueryDialog {
    property Person contact: Person {}

    titleText: "Delete " + contact.displayLabel + "?"
    message: "Are you sure?"
    acceptButtonText: "Yes"
    rejectButtonText: "No"

    onAccepted: {
        app.contactListModel.removePerson(contact)
    }
}
