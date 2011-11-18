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
    showToolBar: true;
//    automaticBookSwitching: false 

    property string currentContactId: ""
    property int currentContactIndex: undefined
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

    PeopleModel{
        id: peopleModel
    }

    ProxyModel{
        id: proxyModel
        Component.onCompleted:{
            proxyModel.setModel(peopleModel); //Calls setSorting() on model
        }
    }

    ToolBar {
        anchors.bottom: parent.bottom
    }
}

