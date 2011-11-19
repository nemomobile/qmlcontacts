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

Item {
    id: groupedViewPortrait

    width: parent.width
    height: parent.height

    signal addNewContact
    signal pressAndHold(int x, int y)

    property alias cards: cardListView

    EmptyContacts{
        id: emptyListView
        anchors.fill: parent
        onClicked: {
            groupedViewPortrait.addNewContact();
        }
    }

    ListView {
        id: cardListView
        anchors.fill: parent
        snapMode: ListView.SnapToItem
        highlightFollowsCurrentItem: false
        focus: true
        keyNavigationWraps: false
        clip: true
        model: proxyModel
        opacity: 0

        delegate: ContactListDelegate {
            id: card
            onClicked:
            {
                var card = pageStack.push(Qt.resolvedUrl("ContactCardPage.qml"));
                card.contact = model.person
            }
        }

        section.property: "firstcharacter"
        section.criteria: ViewSection.FirstCharacter
        section.delegate: Item {
            width: cardListView.width
            height: 30
            id: sectionBackground
            Label {
                //: If a contact isn't sorted under one of the values in a locale's alphabet, it is sorted under '#'
                text: section.toUpperCase()
                anchors.verticalCenter: sectionBackground.verticalCenter
                anchors.right: sectionBackground.right
                anchors.rightMargin: 30
                smooth: true
            }
        }
    }

    FastScroll {
        listView: cardListView
    }

    Binding {
        target: emptyListView;
        property: "opacity";
        value: ((cardListView.count == 0) ? 1 : 0);
    }
    Binding {
        target: cardListView;
        property: "opacity";
        value: ((cardListView.count > 0) ? 1 : 0);
    }
}
