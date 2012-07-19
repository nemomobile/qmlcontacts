import QtQuick 1.1
import com.nokia.meego 1.0
import Qt.labs.folderlistmodel 1.0

Sheet {
    id: avatarPickerSheet
    acceptButtonText: "Select"
    rejectButtonText: "Cancel"

    property Person contact: PageManager.createNextPerson()

    Component {
        id: gridHighlight
        BorderImage {
            source: "image://theme/meegotouch-button-background-pressed"
            width: UI.avatarGridSize; height: UI.avatarGridSize
            border.left:  UI.highlightButtonMargins; border.top:    UI.highlightButtonMargins
            border.right: UI.highlightButtonMargins; border.bottom: UI.highlightButtonMargins
        }
    }

    content: GridView {
        id: avatarGridView
        anchors.fill: parent
        cellWidth: UI.avatarGridSize
        cellHeight: UI.avatarGridSize

        model: FolderListModel {
            id: avatarModel
            folder: "./avatars"
            nameFilters: ["*.png"]
        }
        delegate: Item {
            id: bgRect
            width: UI.avatarGridSize
            height: UI.avatarGridSize
            property alias avatarPath : delegateImage.source
            Image {
                id: delegateImage
                source: filePath
                width: UI.avatarSize
                height: UI.avatarSize
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: avatarGridView.currentIndex = index
            }
        }
        highlight: gridHighlight
        highlightFollowsCurrentItem: true
        focus: true
    }
    onAccepted: {
        contact.avatarPath = avatarGridView.currentItem.avatarPath
        PageManager.peopleModel.savePerson(contact)
    }
}


