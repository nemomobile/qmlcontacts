import QtQuick 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants

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
        onAddNewContact: {
            Constants.loadSingleton("ContactEditorSheet.qml", groupedViewPage,
            function(editor) {
                    editor.contact = Qt.createQmlObject("import QtMobility.contacts 1.1; Contact {}", editor);
                    editor.open()
            })
        }

        model: app.contactListModel
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-common-add"
            onClicked: {
                Constants.loadSingleton("ContactEditorSheet.qml", groupedViewPage,
                    function(editor) {
                        editor.contact = Qt.createQmlObject("import QtMobility.contacts 1.1; Contact {}", editor);
                        editor.open();
                    }
                );
            }
        }
    }
}

