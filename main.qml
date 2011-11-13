/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

PageStackWindow {
    id: window 
//    showToolBarSearch: false;
//    automaticBookSwitching: false 

    property string currentContactId: ""
    property int currentContactIndex: 0
    property string currentContactName: ""
    property bool telepathyReady: false
    property string currentFilter: PeopleModel.AllFilter
    property variant accountItem

    property string filterNew: qsTr("New contact")
    property string filterAll: qsTr("All")
    property string filterFavorites: qsTr("Favorites")

    //: Load the details for the selected contact
    property string contextView: qsTr("View")
    property string contextShare: qsTr("Share")
    property string contextEmail: qsTr("Email")

    //: Add favorite flag / add contact to favorites list
    property string contextFavorite: qsTr("Favorite", "Verb")

    //: Remove favorite flag / remove contact from favorites list 
    property string contextUnFavorite: qsTr("Unfavorite")

    property string contextEdit: qsTr("Edit")
    property string contextSave: qsTr("Save")
    property string contextCancel: qsTr("Cancel")
    property string contextDelete: qsTr("Delete")

    //: Confirmation of deletion - ensure the user wants to delete the contact
    property string deleteConfirmation: qsTr("Delete Confirmation")
    property int dateFormat: Qt.DefaultLocaleLongDate

    property string labelGroupedView: qsTr("Contacts")
    property string labelDetailView: qsTr("Contact details")
    property string labelNewContactView: qsTr("New contact")
    property string labelEditView: qsTr("Edit contacts")

    //: If we are unable to get the contact name, use 'this contact' instead
    property string contactname : (window.currentContactName ? window.currentContactName : qsTr("this contact"))
    property string promptStr: qsTr("Are you sure you want to remove %1 from your contacts?").arg(contactname)

    property int animationDuration: 250

//    bookMenuModel: [filterAll, filterFavorites];
//    bookMenuPayload: [myAppAllContacts, myAppFavContacts];

    /*
    Dialog {
        id:confirmDelete
        title:  deleteConfirmation
        content: Text {
            id: text
            wrapMode: Text.WordWrap
            width: parent.width-60
            text: promptStr
            anchors {horizontalCenter: parent.horizontalCenter;
                     verticalCenter: parent.verticalCenter}
            smooth: true
            opacity: 1
        }


       buttons: ButtonRow {
         style: ButtonStyle { }
           anchors.horizontalCenter: parent.horizontalCenter
           Button {text: contextDelete; onClicked: myDialog.accept()}
           Button {text: contextCancel; onClicked: myDialog.reject()}
       }

        onAccepted: {
            peopleModel.deletePerson(window.currentContactId);
//            window.switchBook(myAppAllContacts);
        }
    }
    */

    function setAllFilter(reload, setFilter) {
//        window.pageStack.currentPage.pageTitle = labelGroupedView;
        peopleModel.setFilter(PeopleModel.AllFilter, reload);

        if (setFilter)
            window.currentFilter = PeopleModel.AllFilter;
    }

    function setFavoritesFilter() {
        peopleModel.setFilter(PeopleModel.FavoritesFilter);
        window.currentFilter = PeopleModel.FavoritesFilter;
//        window.pageStack.currentPage.pageTitle = filterFavorites;
    }

    Loader{
        id: dialogLoader
        anchors.fill: parent
    }

    /*
    onBookMenuTriggered: {
        if (bookMenuModel[index] == filterAll) {
            setAllFilter(true, true);
        } else if (bookMenuModel[index] == filterFavorites) {
            setFavoritesFilter();
        } 
    }
    */

    //Need empty page place holder for filtering
    Component {
        id: myAppFavContacts
        Page {
            id: favContactsPage
//            pageTitle: filterFavorites 
        }
    }

    initialPage: ContactListPage {}

    Component {
        id: myAppDetails
        Page {
            id: detailViewPage
//            pageTitle: labelDetailView
            Component.onCompleted : {
                window.toolBarTitle = labelDetailView;
                detailViewPage.disableSearch = true;
            }
            DetailViewPortrait{
                id: detailViewContact
                anchors.fill:  parent
                detailModel: peopleModel
                indexOfPerson: proxyModel.getSourceRow(window.currentContactIndex)
            }
            FooterBar { 
                id: detailsFooter 
                type: "details"
                currentView: detailViewContact
                pageToLoad: myAppEdit
            }
/*            actionMenuModel: [contextShare, contextEdit]
            actionMenuPayload: [0, 1]

            onActionMenuTriggered: {
                if (selectedItem == 0) {
                    console.log("TODO this needs fixing (contacts app, ask Robin)")
//                    peopleModel.exportContact(window.currentContactId,  "/tmp/vcard.vcf");
//                    var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard.vcf\"";
//                    appModel.launch(cmd);
                }
                else if (selectedItem == 1) {
                    if (window.pageStack.currentPage == detailViewPage)
                        window.addPage(myAppEdit);
                }
            }
            onActivated: {
                detailViewContact.indexOfPerson = proxyModel.getSourceRow(window.currentContactIndex);
            }
*/
        }
    }

    Component {
        id: myAppEdit
	Page {
            id: editViewPage
//            pageTitle: labelEditView
            Component.onCompleted : {
                window.toolBarTitle = labelEditView;
                editViewPage.disableSearch = true;
            }
            EditViewPortrait{
                id: editContact
                dataModel: peopleModel
                index: proxyModel.getSourceRow(window.currentContactIndex, "editviewportrait")
                anchors.fill: parent
            }
            FooterBar { 
                id: editFooter 
                type: "edit"
                currentView: editContact
                pageToLoad: myAppAllContacts
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
        }
    }

    Component {
        id: myAppNewContact

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
    }

    PeopleModel{
        id: peopleModel
    }

    ProxyModel{
        id: proxyModel
        Component.onCompleted:{
            proxyModel.setModel(peopleModel); //Calls setSorting() on model
        }
    }
}

