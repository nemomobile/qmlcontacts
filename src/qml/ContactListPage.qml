/*
 * Copyright (C) 2011-2012 Robin Burchell <robin+mer@viroteck.net>
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
import org.nemomobile.qmlcontacts 1.0
import org.nemomobile.contacts 1.0

Page {
    id: groupedViewPage

    PageHeader {
        id: header
        text: qsTr("Contacts")
    }

    SearchBox {
         id: searchbox
         placeHolderText: "Search"
         anchors.top: header.bottom
         anchors.left: parent.left
         anchors.right: parent.right
         onSearchTextChanged: {
             app.contactListModel.search(searchbox.searchText);
         }
     }

    Component {
        id: contactComponent
        Person {
        }
    }

    ContactListWidget {
        id: gvp
        anchors.top: searchbox.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        onAddNewContact: {
            Constants.loadSingleton("ContactEditorSheet.qml", groupedViewPage,
            function(editor) {
                    editor.contact = contactComponent.createObject(editor)
                    editor.open()
            })
        }

        searching: (searchbox.searchText.length > 0)
        model: app.contactListModel
        delegate: ContactListDelegate {
            id: card
            onClicked: {
                Constants.loadSingleton("ContactCardPage.qml", groupedViewPage,
                    function(card) {
                        card.contact = model.person
                        pageStack.push(card)
                    }
                );
            }
        }

    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-common-add"
            onClicked: {
                Constants.loadSingleton("ContactEditorSheet.qml", groupedViewPage,
                    function(editor) {
                        editor.contact = contactComponent.createObject(editor)
                        editor.open();
                    }
                );
            }
        }

        ToolIcon {
            iconId: "icon-m-toolbar-view-menu"
            onClicked: (pageMenu.status == DialogStatus.Closed) ? pageMenu.open() : pageMenu.close()
        }
    }

    Menu {
        id: pageMenu
        MenuLayout {
            MenuItem {
                text: "Import contacts"
                onClicked: {
                    Constants.loadSingleton("ContactImportSheet.qml", groupedViewPage,
                    function(editor) {
                        editor.open()
                    })
                }
            }

            MenuItem {
                text: "Export contacts"
                onClicked: {
                    var path = app.contactListModel.exportContacts()
                    exportCompleteDialog.path = path
                    exportCompleteDialog.open()
                }
            }
        }
    }

    Dialog {
        id: exportCompleteDialog
        property string path

        title: Label {
            color: "white"
            text: "Export completed"
        }

        content: Label {
            color: "white"
            text: "Export completed to " + exportCompleteDialog.path
            width: parent.width
            height: paintedHeight
        }
    }
}

