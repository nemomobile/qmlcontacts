import QtQuick 1.1
import QtMobility.contacts 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants

Page {
    id: detailViewPage
    property Contact contact

    PageHeader {
        id: header
        text: contact.displayLabel
    }

    ContactCardContentWidget {
        id: detailViewContact
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contact: detailViewPage.contact
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolIcon {
            iconId: "icon-m-toolbar-edit"
            onClicked: {
                Constants.loadSingleton("ContactEditorSheet.qml", detailViewPage,
                    function(editor) {
                        editor.contact = contact
                        editor.open();
                    }
                );
            }
        }
        ToolIcon {
            iconId: (contact.favorite.favorite) ? "icon-m-toolbar-favorite-unmark" : "icon-m-toolbar-favorite-mark"
            onClicked: console.log("TODO - mark/unmark as favorite") //TODO
        }
        ToolIcon {
            iconId: "icon-m-toolbar-view-menu"
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        MenuLayout {
            MenuItem { text: "Delete"; onClicked: console.log("TODO - delete contact action") }
        }
    }
}

