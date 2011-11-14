import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: newContactViewPage
//            pageTitle: labelNewContactView
    Component.onCompleted : {
        window.toolBarTitle = labelNewContactView;
        newContactViewPage.disableSearch = true;
    }
    NewContactViewPortrait{
        id: newContact
        dataModel: peopleModel
    }
    FooterBar { 
        id: newFooter 
        type: "new"
        currentView: newContact
        pageToLoad: myAppAllContacts
    }
    /*
    actionMenuModel: (newContact.validInput) ? [contextSave, contextCancel] : [contextCancel]
    actionMenuPayload: (newContact.validInput) ? [0, 1] : [0]

    onActionMenuTriggered: {
        if(actionMenuModel[selectedItem] == contextSave) {
            window.switchBook(myAppAllContacts);
            newContact.contactSave();
        }else if(actionMenuModel[selectedItem] == contextCancel) {
            window.switchBook(myAppAllContacts);
        }
    }

    onActivated: {
        newContact.finishPageLoad();
    }
    */
}


