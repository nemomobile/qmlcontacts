import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Page {
    id: editViewPage

    EditViewPortrait {
        id: editContact
        dataModel: peopleModel
        index: proxyModel.getSourceRow(window.currentContactIndex, "editviewportrait")
        anchors.fill: parent
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

    tools: ToolBarLayout {
        ToolItem {
            iconId: "icon-m-toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}


