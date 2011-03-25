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

Item {
    id: groupedViewPortrait

    signal addNewContact
    signal pressAndHold(int x, int y)

    property PeopleModel dataModel: contactModel
    property ProxyModel sortModel: proxyModel
    property Component newPage : myAppNewContact
    property Component detailsPage : myAppDetails

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
        anchors.bottom: groupedViewPortrait.bottom
        anchors.right: groupedViewPortrait.right
        anchors.left: groupedViewPortrait.left
        height: groupedViewPortrait.height
        width: groupedViewPortrait.width
        snapMode: ListView.SnapToItem
        highlightFollowsCurrentItem: true
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
            scene.currentContactIndex = index;
            scene.currentContactId = dataPeople.data(index, PeopleModel.UuidRole);
            groupedViewPage.addApplicationPage(myAppDetails);
        }
        onPressAndHold: {
            cardListView.currentIndex = index;
            scene.currentContactIndex = index;
            scene.currentContactId = uuid;
            scene.currentContactName = name;
            groupedViewPortrait.pressAndHold(mouseX, mouseY);
        }
    }

    section.property: "firstcharacter"
    section.criteria: ViewSection.FirstCharacter
    section.delegate: HeaderPortrait{parent: groupedViewPortrait}
}

Binding{target: emptyListView; property: "opacity"; value: ((cardListView.count == 0) ? 1 : 0);}
Binding{target: cardListView; property: "opacity"; value: ((cardListView.count > 0) ? 1 : 0);}

onPressAndHold:{
        objectMenu.menuX = x
        objectMenu.menuY = y
        objectMenu.visible = true
        }
}
