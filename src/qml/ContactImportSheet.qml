import QtQuick 1.1
import com.nokia.meego 1.0
import "constants.js" as Constants
import org.nemomobile.contacts 1.0
import org.nemomobile.folderlistmodel 1.0
import org.nemomobile.qmlfilemuncher 1.0

Sheet {
    id: newContactViewPage
    acceptButtonText: "Import"
    rejectButtonText: "Cancel"

    content: ListView {
        id: sheetContent
        anchors.fill: parent
        property string fileName

        model: FolderListModel {
            id: folderListModel
            path: DocumentsLocation
            showDirectories: false
            nameFilters: [ "*.vcf" ]
        }

        delegate: FileListDelegate {
            selected: sheetContent.fileName == model.fileName
            onClicked: {
                sheetContent.fileName = model.fileName
                console.log(model.fileName)
            }
        }
    }

    onAccepted: doImport();

    function doImport() {
        // TODO: would be nice if folderlistmodel had a role for the full
        // resolved path
        console.log("Importing " + sheetContent.fileName)
        var count = app.contactListModel.importContacts(folderListModel.path + "/" + sheetContent.fileName)
        importCompletedDialog.contactCount = count
        importCompletedDialog.open()
    }

    Dialog {
        id: importCompletedDialog
        property int contactCount: 0

        title: Label {
            color: "white"
            text: "Import completed"
        }

        content: Label {
            color: "white"
            text: "Imported " + importCompletedDialog.contactCount + " contacts"
            width: parent.width
            height: paintedHeight
        }
    }
}


