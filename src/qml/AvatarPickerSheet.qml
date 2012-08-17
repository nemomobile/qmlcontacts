import QtQuick 1.1
import com.nokia.meego 1.0
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.qmlgallery 1.0
import org.nemomobile.contacts 1.0

Sheet {
    id: avatarPickerSheet

    acceptButtonText: qsTr("Select")
    rejectButtonText: qsTr("Cancel")

    acceptButtonEnabled: avatarGridView.itemSelected

    property Person contact
    signal avatarPicked(string pathToAvatar)

    content: Rectangle {
        // TODO: see if we can get theme asset for inverted background
        // cannot use theme.inverted, because that will change whole app's theme.
        color: "black"
        anchors.fill: parent
        GalleryView {
        id: avatarGridView
        property string filePath
        property bool itemSelected: false
        model: GalleryModel { }
        delegate: GalleryDelegate {
            id: delegateInstance
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    avatarGridView.itemSelected = true
                    avatarGridView.currentIndex = index
                    avatarGridView.filePath = url
                }
            }
            Rectangle {
                color: "blue"
                opacity: 0.3
                visible: delegateInstance.GridView.isCurrentItem && avatarGridView.itemSelected
                anchors.fill: parent
            }
        }
    }
}

    onAccepted: {
        avatarPicked(avatarGridView.filePath)
        avatarGridView.itemSelected = false
    }

    onRejected: {
        avatarGridView.itemSelected = false
    }
}


