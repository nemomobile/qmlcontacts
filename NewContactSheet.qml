import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: newContactViewPage
    acceptButtonText: "Save"
    rejectButtonText: "Cancel"

    content: Flickable {
        NewContactViewPortrait {
            id: newContact
            anchors.fill: parent
            dataModel: peopleModel
        }
    }

    onAccepted: {
        pageStack.pop();
        newContact.contactSave();
    }

    onRejected: pageStack.pop()
}


