/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 2.0
import com.nokia.meego 2.0
import org.nemomobile.contacts 1.0

PageStackWindow {
    id: app
    showToolBar: true;

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
    property string contactname : (app.currentContactName ? app.currentContactName : qsTr("this contact"))
    property string promptStr: qsTr("Are you sure you want to remove %1 from your contacts?").arg(contactname)

    property int animationDuration: 250

    initialPage: Component { ContactListPage {} }

    property PeopleModel contactListModel: PeopleModel {
        
// for testing purposes
        Component.onCompleted: {
//            importContacts("../test/example.vcf")
              setDisplayLabelOrder(false);
              setFilterType(1);
        }
    }



}

