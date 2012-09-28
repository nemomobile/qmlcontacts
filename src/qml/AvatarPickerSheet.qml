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


