import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: groupedViewPage

    PageHeader {
        id: header
        text: qsTr("Contacts")
    }

    ContactListWidget {
        id: gvp
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onAddNewContact: newContactLoader.openSheet()
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-common-add"
            onClicked: {
                newContactLoader.openSheet()
            }
        }
    }

    Loader {
        id: newContactLoader

        function openSheet() {
            if (sheetUnloadTimer.running)
                sheetUnloadTimer.stop()

            var sourceUri = Qt.resolvedUrl("NewContactSheet.qml")
            if (newContactLoader.source != sourceUri)
                newContactLoader.source = sourceUri;
            else
                item.open(); // already connected, just reopen it
        }

        Timer {
            id: sheetUnloadTimer
            interval: 60000 // leave it a while in case they want it again
            onTriggered: {
                console.log("SHEET: freeing resources")
                newContactLoader.source = ""
            }
        }

        function closeSheet() {
            sheetUnloadTimer.start()
        }

        onLoaded: {
            item.accepted.connect(closeSheet)
            item.rejected.connect(closeSheet)
            item.open()
        }
    }
}

