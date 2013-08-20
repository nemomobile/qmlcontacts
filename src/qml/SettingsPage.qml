/*
 * Copyright (C) 2011-2012 Timo Hannukkala <timo.hannukkala@nomovok.com>
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

import QtQuick 2.0
import com.nokia.meego 2.0
//import org.nemomobile.qmlcontacts 1.0
//import org.nemomobile.contacts 1.0
//import org.nemomobile.voicecall 1.0

Page {
    id: settingsPage
    
    PageHeader {
        id: header
        text: qsTr("Settings")
        color: "#007FFF"
    }    
    
    Label {
         id: searchbox
         text: "Show contacts:"
         anchors.top: header.bottom
         width: parent.width
         anchors.leftMargin: 20
     }    

     CheckBox {
         id: showAllContacts
         text: "Show All contacts"
         anchors.top: searchbox.bottom
         width: parent.width
         anchors.leftMargin: 20
         checked: true
         onClicked: {
             showAllContacts.checked = true
             showFavoriteContacts.checked = false
             showPhoneNumberContacts.checked = false
             showEmailContacts.checked = false
             app.contactListModel.setFilterType(1);
         }
    }
     
     CheckBox {
         id: showFavoriteContacts
         text: "Show favorite contacts"
         anchors.top: showAllContacts.bottom
         width: parent.width
         anchors.leftMargin: 20
         onClicked: {
             showAllContacts.checked = false
             showFavoriteContacts.checked = true
             showPhoneNumberContacts.checked = false
             showEmailContacts.checked = false
             app.contactListModel.setFilterType(2);
         }
    }

     CheckBox {
         id: showPhoneNumberContacts
         text: "Show contacts with phone number"
         anchors.top: showFavoriteContacts.bottom
         width: parent.width
         anchors.leftMargin: 20
         onClicked: {
             showAllContacts.checked = false
             showFavoriteContacts.checked = false
             showPhoneNumberContacts.checked = true
             showEmailContacts.checked = false
             app.contactListModel.setFilterType(5);
         }
    }

     CheckBox {
         id: showEmailContacts
         text: "Show contacts with email address"
         anchors.top: showPhoneNumberContacts.bottom
         width: parent.width
         anchors.leftMargin: 20
         onClicked: {
             showAllContacts.checked = false
             showFavoriteContacts.checked = false
             showPhoneNumberContacts.checked = false
             showEmailContacts.checked = true
             app.contactListModel.setFilterType(4);
         }

    }


    Component.onCompleted: {
        if (app.contactListModel.filterType == 2)
        {
             showAllContacts.checked = false
             showFavoriteContacts.checked = true
             showPhoneNumberContacts.checked = false
             showEmailContacts.checked = false        
        }
        else if (app.contactListModel.filterType == 4)
        {
             showAllContacts.checked = false
             showFavoriteContacts.checked = false
             showPhoneNumberContacts.checked = false
             showEmailContacts.checked = true        
        }
        else if (app.contactListModel.filterType == 5)
        {
             showAllContacts.checked = false
             showFavoriteContacts.checked = false
             showPhoneNumberContacts.checked = true
             showEmailContacts.checked = false        
        }        
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-toolbar-back"
            onClicked: pageStack.pop()
        }
    }
}

