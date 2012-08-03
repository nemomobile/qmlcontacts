/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: groupedViewPortrait
    property alias model: cardListView.model
    property alias delegate: cardListView.delegate

    width: parent.width
    height: parent.height

    signal addNewContact
    signal pressAndHold(int x, int y)

    property alias cards: cardListView

    Item {
        // TODO: it would be nice if this was only instantiated
        // when needed, and destroyed after
        id: emptyListView
        anchors.fill: parent

        Label {
            id: no_contacts
            text: qsTr("You haven't added any contacts yet.")
            anchors.centerIn: parent
        }

        Button {
            id: button
            text: qsTr("Add a contact")

            anchors {
                top: no_contacts.bottom;
                topMargin: UiConstants.DefaultMargin;
                horizontalCenter: no_contacts.horizontalCenter;
            }
            onClicked: {
                groupedViewPortrait.addNewContact();
            }
        }
    }

    ListView {
        id: cardListView
        anchors.fill: parent
        cacheBuffer: cardListView.height
        clip: true
        model: app.contactListModel
        opacity: 0
        section.property: "sectionBucket"
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

/*
        function customSectionScrollerDataHandler() {
            var sections = []
            var sectionsData = []
            var curSection
            for (var i = 0; i < model.length; ++i) {
                var person = model.personByRow(i)
                if (person.sectionCharacter != curSection) {
                    sections.push(person.sectionCharacter)
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
        */
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
