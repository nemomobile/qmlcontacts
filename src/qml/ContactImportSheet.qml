/*
 * Copyright (C) 2011-2012 Robin Burchell <robin+mer@viroteck.net>
 * Copyright (C) 2012 Jolla Ltd.
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

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

    onStatusChanged: {
        if (status == DialogStatus.Opening) {
            sheetContent.fileName = ""
            folderListModel.refresh()
        }
    }

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


