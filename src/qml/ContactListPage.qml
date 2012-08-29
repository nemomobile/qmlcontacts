import QtQuick 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants
import org.nemomobile.qmlcontacts 1.0
import org.nemomobile.contacts 1.0

Page {
    id: groupedViewPage

    PageHeader {
        id: header
        text: qsTr("Contacts")
        MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        header.focus = true;

                    }
                }
    }


    SearchBox {
         id: searchbox
         placeHolderText: "Search"
         anchors.top: header.bottom
         anchors.left: parent.left
         anchors.right: parent.right
         onSearchTextChanged: {

             app.contactListModel.search(searchbox.searchText);

         }

     }

    Component {
        id: contactComponent
        Person {
        }
    }

    ContactListWidget {
        id: gvp
        anchors.top: searchbox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        onAddNewContact: {
            Constants.loadSingleton("ContactEditorSheet.qml", groupedViewPage,
            function(editor) {
                    editor.contact = contactComponent.createObject(editor)
                    editor.open()
            })
        }

        searching: (searchbox.searchText.length > 0)
        model: app.contactListModel
        delegate: ContactListDelegate {
            id: card
            onClicked: {
                Constants.loadSingleton("ContactCardPage.qml", groupedViewPortrait,
                    function(card) {
                        card.contact = model.person
                        pageStack.push(card)
                    }
                );
            }
        }

    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-common-add"
            onClicked: {
                Constants.loadSingleton("ContactEditorSheet.qml", groupedViewPage,
                    function(editor) {
                        editor.contact = contactComponent.createObject(editor)
                        editor.open();
                    }
                );
            }
        }

        ToolIcon {
            iconId: "icon-m-toolbar-view-menu"
            onClicked: (pageMenu.status == DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
        }
    }

    Menu {
        id: pageMenu
        MenuLayout {
            MenuItem {
                text: "Import contacts"
                onClicked: {
                    Constants.loadSingleton("ContactImportSheet.qml", groupedViewPage,
                    function(editor) {
                        editor.open()
                    })
                }
            }

            MenuItem {
                text: "Export contacts"
                onClicked: {
                    var path = app.contactListModel.exportContacts()
                    exportCompleteDialog.path = path
                    exportCompleteDialog.open()
                }
            }
        }
    }

    Dialog {
        id: exportCompleteDialog
        property string path

        title: Label {
            color: "white"
            text: "Export completed"
        }

        content: Label {
            color: "white"
            text: "Export completed to " + exportCompleteDialog.path
            width: parent.width
            height: paintedHeight
        }
    }
}

