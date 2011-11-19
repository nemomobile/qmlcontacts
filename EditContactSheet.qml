import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Sheet {
    id: editorSheet
    acceptButtonText: "Save"
    rejectButtonText: "Cancel"
    property Person contact: Person {}

    content: Flickable {
        anchors.fill: parent
        contentHeight: contactEditor.childrenRect.height
        PortraitEditorView {
            id: contactEditor
            contact: editorSheet.contact
        }
    }

    onAccepted: contactEditor.contactSave();
}


