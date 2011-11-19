import QtQuick 1.1
import com.nokia.meego 1.0
import "PageManager.js" as PageManager

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
        onAddNewContact: PageManager.openContactEditor()
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-common-add"
            onClicked: {
                PageManager.openContactEditor(groupedViewPage)
            }
        }
    }
}

