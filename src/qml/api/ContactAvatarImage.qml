/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import org.nemomobile.thumbnailer 1.0
import org.nemomobile.contacts 1.0

Image {
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    width: UiConstants.ListItemHeightSmall
    height: UiConstants.ListItemHeightSmall
    property Person contact
    sourceSize.width: width
    sourceSize.height: width

    onContactChanged: {
        contact.avatarPathChanged.connect(avatarPotentiallyChanged)
        avatarPotentiallyChanged();
    }

    function avatarPotentiallyChanged() {
        if (contact.avatarPath == "")
            source = "image://theme/icon-m-telephony-contact-avatar"
        else
            source = "image://nemoThumbnail/" + contact.avatarPath
        if (source == "")
            source = "image://theme/icon-m-telephony-contact-avatar"
    }

    onStatusChanged: {
        if (status == Image.Error || status == Image.Null) {
            source = "image://theme/icon-m-telephony-contact-avatar"
        }
    }
}
