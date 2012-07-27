import QtQuick 1.1
import com.nokia.meego 1.0
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.qmlgallery 1.0
import org.nemomobile.contacts 1.0

Sheet {
    id: avatarPickerSheet
    acceptButtonText: "Select"
    rejectButtonText: "Cancel"

    property Contact contact
    signal avatarPicked(string pathToAvatar)

    content: Rectangle {
        // TODO: see if we can get theme asset for inverted background
        // cannot use theme.inverted, because that will change whole app's theme.
        color: "black"
        anchors.fill: parent
        GalleryView {
        id: avatarGridView
        property string filePath
        model: GalleryModel { }
        delegate: GalleryDelegate {
            id: delegateInstance
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    avatarGridView.currentIndex = index
                    avatarGridView.filePath = url
                }
            }
            Rectangle {
                color: "blue"
                opacity: 0.3
                visible: delegateInstance.GridView.isCurrentItem
                anchors.fill: parent
            }
        }
    }
}

    onAccepted: {
        avatarPicked(avatarGridView.filePath)
    }
}


