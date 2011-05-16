/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.App.Contacts 0.1

Item {
    id: groupedViewPortrait

    signal addNewContact
    signal pressAndHold(int x, int y)

    property PeopleModel dataModel: contactModel
    property ProxyModel sortModel: proxyModel
    property alias cards: cardListView

    EmptyContacts{
        id: emptyListView
        opacity: 1
        onClicked: {
            groupedViewPortrait.addNewContact();
        }
    }

    ListView {
        id: cardListView
        anchors.top: groupedViewPortrait.top
        anchors.right: groupedViewPortrait.right
        anchors.left: groupedViewPortrait.left
        height: groupedViewPortrait.height
        width: groupedViewPortrait.width
        snapMode: ListView.SnapToItem
        highlightFollowsCurrentItem: false
        focus: true
        keyNavigationWraps: false
        clip: true
        model: sortModel
        opacity: 0

        delegate: ContactCardPortrait
        {
        id: card
        dataPeople: dataModel
        sortPeople: proxyModel
        onClicked:
        {
            cardListView.currentIndex = index;
            window.currentContactIndex = index;
            window.currentContactId = dataPeople.data(index, PeopleModel.UuidRole);
            window.addPage(myAppDetails);
        }
        onPressAndHold: {
            cardListView.currentIndex = index;
            window.currentContactIndex = index;
            window.currentContactId = uuid;
            window.currentContactName = name;
            groupedViewPortrait.pressAndHold(mouseX, mouseY);
        }
        Binding{target: cardListView; property: "height"; value: ((cardListView.count > 1) ?  groupedViewPortrait.height : cardListView.childrenRect.height)}
    }

    section.property: "firstcharacter"
    section.criteria: ViewSection.FirstCharacter
    section.delegate: HeaderPortrait{width: cardListView.width;}
}

Binding{target: emptyListView; property: "opacity"; value: ((cardListView.count == 1) ? 1 : 0);}
Binding{target: cardListView; property: "opacity"; value: ((cardListView.count > 0) ? 1 : 0);}

    onPressAndHold:{
        objectMenu.setPosition(x, y)
        objectMenu.menuX = x
        objectMenu.menuY = y
        objectMenu.show()
    }

    ModalContextMenu {
        id: objectMenu

        property int menuX
        property int menuY

        content: ActionMenu {
            id: actionObjectMenu

            model: (dataModel.data(sortModel.getSourceRow(window.currentContactIndex), PeopleModel.IsSelfRole) == true) ? [contextView, contextShare, contextEdit] : ((dataModel.data(sortModel.getSourceRow(window.currentContactIndex), PeopleModel.FavoriteRole)) ? [contextView, contextShare, contextEdit, contextUnFavorite, contextDelete] : [contextView, contextShare, contextEdit, contextFavorite, contextDelete])

            onTriggered: {
                if(index == 0) { window.addPage(myAppDetails);}
                if(index == 3) { peopleModel.toggleFavorite(window.currentContactId); }
                if(index == 1) { shareMenu.setPosition(objectMenu.menuX, objectMenu.menuY + 30);
                                 shareMenu.show();  }
                if(index == 2) { window.addPage(myAppEdit);}
                if(index == 4) { confirmDelete.show(); }
                objectMenu.hide();
            }
        }
    }

    ModalContextMenu {
        id: shareMenu

        content: ActionMenu {
            id: actionShareMenu

            model: [contextEmail]

            onTriggered: {
                if(index == 0) {
                    var filename = currentContactName.replace(" ", "_");
                    peopleModel.exportContact(window.currentContactId,  "/tmp/vcard_"+filename+".vcf");
                    shareMenu.visible = false;
                    var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard_"+filename+".vcf\"";
                    appModel.launch(cmd);
                }
            }
        }
    }
}
