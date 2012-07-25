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
        cacheBuffer: cardListView.height
        clip: true
        model: app.contactListModel
        opacity: 0
        section.property: "firstName"
        section.criteria: ViewSection.FirstCharacter
        section.delegate: Component {
         Rectangle {
             width: parent.width
             height: childrenRect.height
             color: "lightsteelblue"

             Text {
                 anchors.right: parent.right
                 anchors.rightMargin: UiConstants.DefaultMargin
                 text: section
                 font.bold: true
             }
         }
        }

        function customSectionScrollerDataHandler() {
            var sections = []
            var sectionsData = []
            var curSection
            var contacts = model.contacts
            for (var i = 0; i < contacts.length; ++i) {
                console.log(contacts[i])
                if (contacts[i].name.firstName[0] != curSection) {
                    sections.push(contacts[i].name.firstName[0])
                    curSection = sections[sections.length - 1]
                }
            }
            for (var i = 0; i < sections.length; ++i) {
                sectionsData.push({ index: i })
            }
            return {
                sectionData: sectionsData,
                _sections: sections
            }
        }

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
