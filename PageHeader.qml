import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    id: detailHeader

    // TODO: landscape
    height: UiConstants.HeaderDefaultHeightPortrait;
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    color: "#007FFF"
    property alias text: label.text
    property alias content: othercontent.children

    Item {
        id: othercontent
        width: childrenRect.width
        height: childrenRect.height
        anchors.left: parent.left
        anchors.leftMargin: children.count > 0 ? UiConstants.DefaultMargin : 0
        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        id: label
        anchors.left: othercontent.right
        anchors.leftMargin: UiConstants.DefaultMargin
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        smooth: true
        color: "white"
        font: UiConstants.HeaderFont
    }
}

