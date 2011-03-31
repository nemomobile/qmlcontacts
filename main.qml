/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.App.Contacts 0.1

Window {
    id: scene
    title: qsTr("Contacts")
    showsearch: false;

    property string currentContactId: ""
    property int currentContactIndex: 0
    property string currentContactName: ""

    property string filterNew: qsTr("New contact")
    property string filterAll: qsTr("All")
    property string filterFavorites: qsTr("Favorites")
    property string filterWhosOnline: qsTr("Who's online")

    property string contextView: qsTr("View")
    property string contextShare: qsTr("Share")
    property string contextEmail: qsTr("Email")
    property string contextFavorite: qsTr("Favorite")
    property string contextEdit: qsTr("Edit")
    property string contextSave: qsTr("Save")
    property string contextCancel: qsTr("Cancel")
    property string contextDelete: qsTr("Delete")
    property string deleteConfirmation : qsTr("Delete Confirmation")

    property string labelGroupedView: qsTr("Contacts")
    property string labelDetailView: qsTr("Contact details")
    property string labelNewContactView: qsTr("New contact")
    property string labelEditView: qsTr("Edit contacts")

    property string contactname : (scene.currentContactName ? scene.currentContactName : qsTr("this contact"))
    property string promptStr: qsTr("Are you sure you want to remove %1 from your contacts?").arg(contactname)

    property int animationDuration: 250

    applicationPage: myAppAllContacts

    Loader{
        id: dialogLoader
        anchors.fill: parent
    }

    onFilterTriggered: {
        if(index == 0){
            scene.filterModel = [filterAll, filterFavorites, filterWhosOnline];
            peopleModel.setFilter(PeopleModel.AllFilter);
            scene.applicationPage = myAppAllContact;
        }else if(index == 1){
            peopleModel.setFilter(PeopleModel.FavoritesFilter);
            scene.applicationPage = myAppAllContact;
        }else if(index == 2){
            peopleModel.setFilter(PeopleModel.OnlineFilter); //REVISIT: TEST THIS
            scene.applicationPage = myAppAllContact;
        }
    }

    Component {
        id: myAppAllContacts
        ApplicationPage{
            id: groupedViewPage
            title: labelGroupedView
            Component.onCompleted : {
                scene.title = labelGroupedView;
                scene.filterModel = [filterAll, filterFavorites, filterWhosOnline];
                disableSearch = false;
                showsearch = true;
            }
            onSearch: {
                peopleModel.searchContacts(needle);
            }
            GroupedViewPortrait{
                id: gvp
                parent: groupedViewPage.content
                anchors.fill: parent
                dataModel: peopleModel
                sortModel: proxyModel
                newPage: myAppNewContact //REVISIT: Need to do this?
                detailsPage: myAppDetails //REVISIT: Need to do this?
                onAddNewContact:{
                    groupedViewPage.addApplicationPage(myAppNewContact);
                }
            }
            FooterBar { 
                id: groupedViewFooter 
                type: ""
                currentView: gvp
                pageToLoad: myAppAllContacts
            }
            menuContent: ActionMenu {
                id: actions
                model: [labelNewContactView]
                onTriggered: {
                    if(index == 0) {
                        groupedViewPage.addApplicationPage(myAppNewContact);
                    }
                    groupedViewPage.closeMenu();
                }
            }
        }
    }

    Component {
        id: myAppDetails
        ApplicationPage {
            id: detailViewPage
            title: labelDetailView
            Component.onCompleted : {
                scene.title = labelDetailView;
                scene.filterModel = [];
                disableSearch = true;
            }
            DetailViewPortrait{
                id: detailViewContact
                anchors.fill:  parent
                parent: detailViewPage.content
                detailModel: peopleModel
                index: proxyModel.getSourceRow(scene.currentContactIndex)
            }
            FooterBar { 
                id: detailsFooter 
                type: "details"
                currentView: detailViewContact
                pageToLoad: myAppEdit
            }
            menuContent: ActionMenu {
                id: actions
                model: [contextShare, contextEdit]
                onTriggered: {
                    if(index == 0) {
                        peopleModel.exportContact(scene.currentContactId,  "/tmp/vcard.vcf");
                        var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard.vcf\"";
                        appModel.launch(cmd);
                    }
                    else if(index == 1) {
                        scene.addApplicationPage(myAppEdit);
                    }
                    detailViewPage.closeMenu();
                }
            }
            Component.onDestruction: {
                peopleModel.setFilter(PeopleModel.AllFilter);
                scene.filterModel = [filterAll, filterFavorites, filterWhosOnline];
                //REVISIT: change filter earlier to avoid glitch
            }
        }
    }

    Component {
        id: myAppEdit
        ApplicationPage {
            id: editViewPage
            title: labelEditView
            Component.onCompleted : {
                scene.title = labelEditView;
                scene.filterModel = [];
                disableSearch = true;
            }
            EditViewPortrait{
                id: editContact
                parent: editViewPage.content
                dataModel: peopleModel
                index: proxyModel.getSourceRow(scene.currentContactIndex)
                anchors.fill: parent
            }
            FooterBar { 
                id: editFooter 
                type: "edit"
                currentView: editContact
                pageToLoad: myAppAllContacts
            }
            menuContent: ActionMenu {
                id: actions
                model: [contextSave, contextCancel, contextDelete]
                onTriggered: {
                    if(index == 0) {
                        editContact.contactSave(scene.currentContactId);
                        applicationPage = myAppAllContacts;
                    }
                    else if(index == 1) {
                        applicationPage = myAppAllContacts;
                    }
                    else if(index == 2) {
                        showModalDialog(confirmDialog);
                        actions.visible = false;
                    }
                    editViewPage.closeMenu();
                }
            }
            Component.onDestruction: {
                peopleModel.setFilter(PeopleModel.AllFilter);
                scene.filterModel = [filterAll, filterFavorites, filterWhosOnline];
            }
        }
    }

    Component {
        id: myAppNewContact
        ApplicationPage {
            id: newContactViewPage
            title: labelNewContactView
            Component.onCompleted : {
                scene.title = labelNewContactView;
                scene.filterModel = [];
                disableSearch = true;
            }
            NewContactViewPortrait{
                id: newContact
                parent: newContactViewPage.content
                dataModel: peopleModel
            }
            FooterBar { 
                id: newFooter 
                type: "new"
                currentView: newContact
                pageToLoad: myAppAllContacts
            }
            menuContent:
                ActionMenu{
                id: menu
                model: [contextSave, contextCancel]
                onTriggered: {
                    if(index == 0) {
                        newContact.contactSave();
                        scene.applicationPage = myAppAllContacts;
                    }else if(index == 1) {
                        scene.applicationPage = myAppAllContacts;
                    }
                    newContactViewPage.closeMenu();
                }
            }
            Component.onDestruction: {
                peopleModel.setFilter(PeopleModel.AllFilter);
                scene.filterModel = [filterAll, filterFavorites, filterWhosOnline];
            }
        }
    }

    PeopleModel{
        id: peopleModel
    }

    ProxyModel{
        id: proxyModel
        Component.onCompleted:{
            //setSortType() will in turn call setSorting() on the PeopleModel
            proxyModel.setModel(peopleModel);
            proxyModel.setSortType(ProxyModel.SortName);
            proxyModel.setSortType(settingsDataStore.getSortOrder());
        }
    }

    //REVISIT: We're not catching/emitting this signal correctly
    Connections {
        target: settingsDataStore
        onSortOrderChanged: {
            console.debug("[contacts] - Got sortOrderChanged signal");
            //REVISIT: Read and set sort order here
        }
    }

    ApplicationsModel{
        id: appModel
    }

    ContextMenu {
        id: objectMenu
        model: [contextView, contextFavorite, contextShare, contextEdit, contextDelete]
        onTriggered: {
            if(index == 0) { scene.addApplicationPage(myAppDetails); objectMenu.visible = false;}
            if(index == 1) { peopleModel.toggleFavorite(scene.currentContactId); objectMenu.visible = false;}
            if(index == 2) { shareMenu.menuY = (objectMenu.menuY+30); shareMenu.menuX = objectMenu.menuX; shareMenu.visible = true;  objectMenu.visible = false;}
            if(index == 3) { scene.addApplicationPage(myAppEdit); objectMenu.visible = false;}
            if(index == 4) { showModalDialog(confirmDialog); objectMenu.visible = false;}
        }
    }

    ContextMenu {
        id: shareMenu
        model: [contextEmail]
        onTriggered: {
            if(index == 0) {
                var filename = currentContactName.replace(" ", "_");
                peopleModel.exportContact(scene.currentContactId,  "/tmp/vcard_"+filename+".vcf");
                shareMenu.visible = false;
                var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard_"+filename+".vcf\"";
                appModel.launch(cmd);
            }
        }
    }

    Component{
        id: confirmDialog
        ModalDialog{
            id:confirmDelete
            leftButtonText: contextCancel
            rightButtonText:  contextDelete
            dialogTitle:  deleteConfirmation
            bgSourceUpRight: "image://theme/btn_red_up"
            bgSourceDnRight: "image://theme/btn_red_dn"
            contentLoader.sourceComponent: Text {
                id: text
                wrapMode: Text.WordWrap
                text: promptStr
                color: theme_fontColorNormal
                font.pointSize: theme_fontPixelSizeMedium
                smooth: true
                opacity: 1
            }
            onDialogClicked: {
                dialogLoader.sourceComponent = undefined;
                if(button == 2){
                    peopleModel.deletePerson(scene.currentContactId);
                    if (applicationPage != myAppAllContacts)
                        applicationPage = myAppAllContacts;
                }
            }
        }
    }
}

