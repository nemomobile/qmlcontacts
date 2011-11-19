import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Page {
    id: detailViewPage
    property Person contact: Person { }

    PageHeader {
        id: header
        text: contact.displayLabel

        Image {
            id: icon_favorite
            anchors{right: parent.right;  rightMargin: 10}
            source: contact.favorite ? "image://themedimage/icons/actionbar/favorite-selected" : "image://themedimage/icons/actionbar/favorite"
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
            iconId: "icon-m-toolbar-view-menu";
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        MenuLayout {
            MenuItem { text: "Edit"; onClicked: contactEditor.openSheet() }
        }
    }

    Loader {
        id: contactEditor

        function freeSheet() {
            console.log("SHEET: freeing resources")
            contactEditor.source = ""
        }

        function openSheet() {
            if (sheetUnloadTimer.running) {
                sheetUnloadTimer.stop()
                freeSheet()
            }

            var sourceUri = Qt.resolvedUrl("EditContactSheet.qml")
            contactEditor.source = sourceUri;
        }

        Timer {
            id: sheetUnloadTimer
            interval: 3000 // long enough for the animation to run
            onTriggered: freeSheet();
        }

        function closeSheet() {
            sheetUnloadTimer.start()
        }

        onLoaded: {
            item.contact = detailViewPage.contact
            item.accepted.connect(closeSheet)
            item.rejected.connect(closeSheet)
            item.open()
        }
    }

}

