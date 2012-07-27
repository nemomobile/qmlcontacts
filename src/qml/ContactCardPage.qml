import QtQuick 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants
import org.nemomobile.qmlcontacts 1.0
import org.nemomobile.contacts 1.0

Page {
    id: detailViewPage
    property Person contact

    Connections {
        target: contact
        onContactRemoved: {
            pageStack.pop()
        }
    }

    PageHeader {
        id: header
        text: contact.displayLabel
        content: ContactAvatarImage {
            contact: detailViewPage.contact
        }
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
            iconId: contact.favorite ? "icon-m-toolbar-favorite-mark" : "icon-m-toolbar-favorite-unmark"
            onClicked: {
                contact.favorite = !contact.favorite

                // TODO: delay saving to save CPU on repeated toggling
                app.contactListModel.savePerson(detailViewPage.contact)
            }
        }
        ToolIcon {
            iconId: "icon-m-toolbar-view-menu"
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        MenuLayout {
            MenuItem {
                text: "Delete";
                onClicked: {
                    Constants.loadSingleton("DeleteContactDialog.qml", detailViewPage,
                        function(deleteDialog) {
                            deleteDialog.contact = contact
                            deleteDialog.open();
                        }
                    );
                }
            }
        }
    }
}

