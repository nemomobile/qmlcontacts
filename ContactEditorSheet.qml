import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: newContactViewPage
    acceptButtonText: "Save"
    rejectButtonText: "Cancel"
    property alias contact: newContact.contact

    content: Flickable {
        anchors.fill: parent
        //contentHeight: newContact.childrenRect.height
        PortraitEditorView {
            id: newContact
        }
    }

    onAccepted: newContact.contactSave();
}


