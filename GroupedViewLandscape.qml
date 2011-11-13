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
    id: groupedViewLandscape

    property string parentTitle: ""

    property PeopleModel dataModel: contactModel
    property ProxyModel sortModel: proxyModel
    property alias cards: cardListView

    function getActionMenuModel()
    {
        if (dataModel.data(sortModel.getSourceRow(window.currentContactIndex),
                           PeopleModel.IsSelfRole))
            return [contextView, contextShare, contextEdit];

        if (dataModel.data(sortModel.getSourceRow(window.currentContactIndex),
                           PeopleModel.FavoriteRole))
            return [contextView, contextShare, contextEdit,
                    contextUnFavorite, contextDelete];

       return [contextView, contextShare, contextEdit,
               contextFavorite, contextDelete];
    }

    signal addNewContact
    signal pressAndHold(int x, int y)

    EmptyContacts {
        id: emptyListView
        anchors.verticalCenter: groupedViewLandscape.verticalCenter
        onClicked: {
            groupedViewLandscape.addNewContact();
        }
    }

    Rectangle {
        id: emptyOrCardListView

        width: parent.width
        height: parent.height
        color: "white"

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
                        smooth: true
                    }
                }
            }
        }
    }

    Binding {target: emptyListView;
             property: "visible";
             value: (((cardListView.count == 1) &&
                    (peopleModel.isSelfContact(cardListView.cUuid))) ? 1 : 0);}

    Binding {target: cardListView;
             property: "visible";
             value: ((cardListView.count > 0) ? 1 : 0);}

    onPressAndHold: {
        objectMenu.setPosition(x, y)
        objectMenu.menuX = x
        objectMenu.menuY = y
        objectMenu.show()

        //Set actionMenu model on each click because we need
        //to check to see if the contact has been favorited
        objectMenu.actionMenu.model = getActionMenuModel()
    }

                    /*
    ContextMenu {
        id: objectMenu
        property int menuX
        property int menuY

        property alias actionMenu: actionObjectMenu

        content: ActionMenu {
            id: actionObjectMenu
            model: getActionMenuModel()

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

    ContextMenu {
        id: shareMenu

        content: ActionMenu {
            id: actionShareMenu

            model: [contextEmail]

            onTriggered: {
                if(index == 0) {
                    var filename = currentContactName.replace(" ", "_");
                    //REVISIT: Non-ASCII characters are corrupted when calling
                    //meego-qml-launcher via the command-line.
                    //peopleModel.exportContact(window.currentContactId,  "/tmp/vcard_"+filename+".vcf");
                    peopleModel.exportContact(window.currentContactId,  "/tmp/vcard.vcf");
                    shareMenu.visible = false;
                    //var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard_"+filename+".vcf\"";
                    var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard.vcf\"";
                    appModel.launch(cmd);
                }
            }
        }
    }
    */
}

