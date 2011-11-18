import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Sheet {
    acceptButtonText: "Save"
    rejectButtonText: "Cancel"

    content: Flickable {
        anchors.fill: parent
        contentHeight: contactEditor.childrenRect.height
        Item {
            anchors.fill: parent
            PortraitEditorView {
                id: contactEditor
                dataModel: peopleModel
            }
        }
    }

    function setSourceIndex(index) {
        contactEditor.setSourceIndex(index)
    }

    onAccepted: contactEditor.contactSave();
    Component.onCompleted: contactEditor.finishPageLoad();
}


