import QtQuick 1.1
import com.nokia.meego 1.0
import org.nemomobile.contacts 1.0

Flickable {
    id: detailViewPortrait
    contentWidth: parent.width
    contentHeight: detailsList.height + (UiConstants.DefaultMargin * 2)
    flickableDirection: Flickable.VerticalFlick
    clip: true

    property Person contact

    Item {
        id: detailsList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: UiConstants.DefaultMargin
        height: phones.childrenRect.height

        ListView {
            id: phones
            anchors { left: parent.left; right: parent.right; top: parent.top; }
            model: contact.phoneNumbers
            interactive: false
            height: childrenRect.height
            delegate: Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: UiConstants.ListItemHeightDefault

                Label {
                    text: model.modelData
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                ButtonRow {
                    width: 220
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: UiConstants.DefaultMargin
                    exclusive: false
                    Button {
                        height: parent.height
                        iconSource: "image://theme/icon-m-telephony-incoming-call";
                        onClicked: console.log("TODO: Make call to " + contact.firstName)
                    }
                    Button {
                        height: parent.height
                        iconSource: "image://theme/icon-m-toolbar-send-sms";
                        onClicked: console.log("TODO: Send SMS to " + contact.firstName)
                    }
                }
            }
        }
    }
}

