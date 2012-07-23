import QtQuick 1.1
import QtMobility.contacts 1.1
import com.nokia.meego 1.0
import Qt.labs.folderlistmodel 1.0

Sheet {
    id: avatarPickerSheet
    acceptButtonText: "Select"
    rejectButtonText: "Cancel"

    property Contact contact

    signal avatarPicked(string pathToAvatar)

    property int avatarGridSize: avatarPickerSheet.width / 3

    Component {
        id: gridHighlight
        Rectangle {
            color: "blue"
            opacity: 0.5
            width: avatarGridSize; height: avatarGridSize
        }
    }

    content: GridView {
        id: avatarGridView
        anchors.fill: parent
        cellWidth: avatarGridSize
        cellHeight: avatarGridSize

        model: FolderListModel {
            id: avatarModel
            folder: "file://" + systemAvatarDirectory
            nameFilters: ["*.png", "*.jpg", "*.jpeg"]
        }
        delegate: Item {
            id: bgRect
            width: avatarGridSize
            height: avatarGridSize
            property alias avatarPath: delegateImage.source
            Image {
                id: delegateImage
                width: avatarGridSize
                height: avatarGridSize
                source: filePath
                anchors.centerIn: parent
                asynchronous: true
                sourceSize.width: avatarGridSize
                sourceSize.height: avatarGridSize
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
        avatarPicked(avatarGridView.currentItem.avatarPath)
    }
}


