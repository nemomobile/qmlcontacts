import QtQuick 1.1
import com.nokia.meego 1.0

Rectangle {
    id: detailHeader
    height: 72;
    width: parent.width
    color: "#007FFF"
    property alias text: label.text
    property alias content: othercontent.children

    Item {
        id: othercontent
        width: childrenRect.width
        anchors.left: parent.left
        anchors.leftMargin: 10
//        anchors.verticalCenter: parent.verticalCenter
    }

    Label {
        id: label
        anchors.left: othercontent.right
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        elide: Text.ElideRight
        smooth: true
        color: "white"
    }
}

