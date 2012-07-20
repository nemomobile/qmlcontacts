/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import QtMobility.contacts 1.1

Image {
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    smooth: true
    width: UiConstants.ListItemHeightSmall
    height: UiConstants.ListItemHeightSmall
    property Contact contact
    source: (contact.thumbnail == "undefined") ? "avatars/icon-contacts-default-avatar.svg" : contact.thumbnail

    function limitSize() {
        var screenLong = Math.max(app.width, app.height)
        var screenShort = Math.min(app.width, app.height)
        var imageLong = Math.max(sourceSize.width, sourceSize.height)
        var imageShort = Math.min(sourceSize.width, sourceSize.height)

        if (imageLong / imageShort > screenLong / screenShort) {
            // limit the long side
            if (imageLong == sourceSize.width) {
                if (sourceSize.width > screenLong) {
                    sourceSize.width = screenLong
                    sourceSize.height = 0
                }
            }
            else if (sourceSize.height > screenLong) {
                sourceSize.height = screenLong
                sourceSize.width = 0
            }
        }
        else {
            // limit the short side
            if (imageShort == sourceSize.width) {
                if (sourceSize.width > screenShort) {
                    sourceSize.width = screenShort
                    sourceSize.height = 0
                }
            }
            else if (sourceSize.height > screenShort) {
                sourceSize.height = screenShort
                sourceSize.width = 0
            }
        }
    }

    onStatusChanged: {
        if (status == Image.Ready) {
            limitSize()
        }

        if (photo.status == Image.Error || photo.status == Image.Null){
            photo.source = "image://theme/icon-m-telephony-contact-avatar"
        }
    }
}
