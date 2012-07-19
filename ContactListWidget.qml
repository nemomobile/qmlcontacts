/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import QtMobility.contacts 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants

Item {
    id: groupedViewPortrait
    property alias model: cardListView.model

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
        model: app.contactListModel
        opacity: 0

        delegate: ContactListDelegate {
            id: card
            onClicked: {
                Constants.loadSingleton("ContactCardPage.qml", groupedViewPortrait,
                    function(card) {
                        card.contact = model.contact
                        pageStack.push(card)
                    }
                );
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
            Image {
                anchors.right: sectionBackground.left
                anchors.left: parent.left
                anchors.verticalCenter: sectionBackground.verticalCenter
                anchors.rightMargin: 24
                source: "image://theme/meegotouch-groupheader" + (theme.inverted ? "-inverted" : "") + "-background"
            }
        }
    }

    SectionScroller {
        listView: cardListView
    }

    ScrollDecorator {
        flickableItem: cardListView
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
