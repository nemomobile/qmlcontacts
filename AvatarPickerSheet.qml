import QtQuick 1.1
import QtMobility.contacts 1.1
import com.nokia.meego 1.0
import Qt.labs.folderlistmodel 1.0
import org.nemomobile.thumbnailer 1.0

Sheet {
    id: avatarPickerSheet
    acceptButtonText: "Select"
    rejectButtonText: "Cancel"

    property Contact contact

    signal avatarPicked(string pathToAvatar)

    property int avatarGridSize: avatarPickerSheet.width / 3

    content: GridView {
        id: avatarGridView
        anchors.fill: parent
        cellWidth: avatarGridSize
        cellHeight: avatarGridSize
        cacheBuffer: cellHeight * 3

        model: FolderListModel {
            id: avatarModel
            folder: "file://" + systemAvatarDirectory
            nameFilters: ["*.png", "*.jpg", "*.jpeg"]
            showDirs: false
        }
        delegate: Item {
            id: delegateInstance
            width: avatarGridSize
            height: avatarGridSize
            property alias avatarPath: delegateImage.source
            Image {
                id: delegateImage
                width: avatarGridSize
                height: avatarGridSize
                source: "image://nemoThumbnail/" + filePath
                anchors.centerIn: parent
                asynchronous: true
                sourceSize.width: avatarGridSize
                sourceSize.height: avatarGridSize
            }
            MouseArea {
                anchors.fill: parent
                onClicked: avatarGridView.currentIndex = index
            }
            Rectangle {
                color: "blue"
                opacity: 0.3
                visible: delegateInstance.GridView.isCurrentItem
                anchors.fill: parent
            }
        }
        focus: true
    }
    onAccepted: {
        avatarPicked(avatarGridView.currentItem.avatarPath)
    }
}


