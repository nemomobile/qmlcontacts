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
    id: groupedViewLandscape

    property string parentTitle: ""

    property PeopleModel dataModel: contactModel
    property ProxyModel sortModel: proxyModel
    property alias cards: cardListView

    signal addNewContact
    signal pressAndHold(int x, int y)

    Item {
        id: emptyOrCardListView
        anchors.fill: parent

        ListOfGridsView {
            id: cardListView
            anchors.fill: parent
            focus: true
            clip: true
            dataPeople: dataModel
            sortPeople: proxyModel

            delegate: ContactCardLandscape
            {
                id: card
                dataPeople: dataModel
                sortPeople: proxyModel
                onClicked:
                {
                    window.currentContactIndex = proxyIndex
                    window.currentContactId = dataPeople.data(sourceIndex, PeopleModel.UuidRole);
                    window.addPage(myAppDetails);
                }
                onPressAndHold: {
                    window.currentContactIndex = proxyIndex
                    window.currentContactId = uuid;
                    window.currentContactName = name;
                    groupedViewLandscape.pressAndHold(mouseX, mouseY);
                }
            }

            sectionDelegate: Component {
                id: sectionDelegate
                Image {
                    id: sectionBackground
                    property string etcSymbol: qsTr("#")
                    property string section
                    source: "image://themedimage/widgets/common/list/list-dividerbar"
                    fillMode: Image.Stretch
                    Text {
                        id: headerTitle
                        text: (section ? section.toUpperCase() : etcSymbol)
                        anchors.verticalCenter: sectionBackground.verticalCenter
                        anchors.left: sectionBackground.left
                        anchors.leftMargin: 30
                        font.pixelSize: theme_fontPixelSizeLargest
                        color: theme_fontColorNormal; smooth: true
                    }
                }
            }

            EmptyContacts {
                id: emptyListView
                anchors.top: parent.bottom
                onClicked: {
                    groupedViewLandscape.addNewContact();
                }
            }

            Binding {target: emptyListView;
                     property: "visible"; value: cardListView.count == 1 }
        }

        Binding {target: cardListView;
                 property: "visible"; value: cardListView.count > 0 }
    }

    onPressAndHold: {
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
            model: (dataModel.data(sortModel.getSourceRow(window.currentContactIndex), PeopleModel.IsSelfRole) == true) ?
                [contextView, contextShare, contextEdit] :
                    ((dataModel.data(sortModel.getSourceRow(window.currentContactIndex), PeopleModel.FavoriteRole)) ?
                        [contextView, contextShare, contextEdit, contextUnFavorite, contextDelete] :
                        [contextView, contextShare, contextEdit, contextFavorite, contextDelete])

            onTriggered: {
                if(index == 0) { window.addPage(myAppDetails); }
                if(index == 3) { peopleModel.toggleFavorite(window.currentContactId); }
                if(index == 1) { shareMenu.setPosition(objectMenu.menuX, objectMenu.menuY + 30);
                                 shareMenu.show(); }
                if(index == 2) { window.addPage(myAppEdit); }
                if(index == 4) { confirmDelete.show(); }
                objectMenu.hide();
            }
        }
    }
}

