import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1
import "PageManager.js" as PageManager

Page {
    id: detailViewPage
    property Person contact: PageManager.createNextPerson()

    PageHeader {
        id: header
        text: contact.displayLabel

        /*
         * TODO: overlay favorite icon over avatar
        Image {
            id: icon_favorite
            anchors{right: parent.right;  rightMargin: 10}
            source: contact.favorite ? "image://themedimage/icons/actionbar/favorite-selected" : "image://themedimage/icons/actionbar/favorite"
        }
        */
        content: Image {
            id: avatar
            source: (contact.avatarPath == "undefined") ? "image://theme/icon-m-telephony-contact-avatar" : contact.avatarPath
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
            onClicked: { PageManager.openContactEditor(detailViewPage, contact.id) }
        }
        ToolIcon {
            iconId: (contact.favorite) ? "icon-m-toolbar-favorite-unmark" : "icon-m-toolbar-favorite-mark"
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
            MenuItem { text: "Edit"; onClicked: PageManager.openContactEditor(detailViewPage, contact.id) }
        }
    }
}

