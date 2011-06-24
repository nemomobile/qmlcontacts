/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Contacts 0.1
import TelepathyQML 0.1

Item {
    id: contactCardLandscape

    // TODO need clip off rounded edges from avatar image

    height: contactWithNoAvatar.height; width: contactWithNoAvatar.width // size from theme image
    property PeopleModel dataPeople : theModel
    property ProxyModel sortPeople : sortModel
    property int sourceIndex
    property int proxyIndex

    property string dataAvatar: dataPeople.data(sourceIndex, PeopleModel.AvatarRole)
    property string dataFirst: dataPeople.data(sourceIndex, PeopleModel.FirstNameRole)
    property string dataLast:  dataPeople.data(sourceIndex, PeopleModel.LastNameRole)
    property bool dataFavorite: dataPeople.data(sourceIndex, PeopleModel.FavoriteRole)
    property string dataUuid: dataPeople.data(sourceIndex, PeopleModel.UuidRole);
    property int iconsMargin: 6
    property int borderMargins: 3 
    property int itemMargins: 15

    signal clicked
    signal pressAndHold(int mouseX, int mouseY, string uuid, string name)

    Image {
        id: contactWithAvatar
        width: 104
        height: width
        anchors.centerIn: parent
        asynchronous: true
        visible: avatar.status == Image.Ready

        BorderImage {
            id: borderImg
            anchors.fill:parent
            z: -10
            asynchronous: true
            source: "image://themedimage/widgets/apps/media/photo-border"
            border.top: borderMargins
            border.bottom: borderMargins
            border.left: borderMargins
            border.right: borderMargins

            Item {
                id: wrapper
                anchors.fill: parent
                anchors.topMargin: borderImg.border.top
                anchors.bottomMargin: borderImg.border.bottom
                anchors.leftMargin: borderImg.border.left
                anchors.rightMargin: borderImg.border.right

                Image {
                    id: avatar
                    smooth: true
                    asynchronous: true
                    anchors { fill: parent; }
                    fillMode: Image.PreserveAspectCrop
                    source: dataAvatar
                    clip: true
                    z: 0
                }

                Image {
                    id: nameOverlay
                    width: parent.width
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "image://theme/contacts/contact_thumb_bg"
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }
            }
        }
    }

    Image {
        id: contactWithNoAvatar
        width: theme_listBackgroundPixelHeightTwo + itemMargins
        height: theme_listBackgroundPixelHeightTwo + itemMargins
        source: "image://themedimage/widgets/common/avatar/avatar-default"
        visible: avatar.status != Image.Ready
    }

    Text {
        id: contactNameText
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: 8
            rightMargin: 8
            bottomMargin: 9
        }
        elide: Text.ElideRight
        font.pixelSize: theme_fontPixelSizeLargest
        color: theme_fontColorMediaHighlight;
        smooth: true
        text: {
            if ((dataFirst != "") || (dataLast != "")) {
                if (settingsDataStore.getDisplayOrder() == PeopleModel.LastNameRole)
                    return qsTr("%1 %2").arg(dataLast).arg(dataFirst)
                else
                    return qsTr("%1 %2").arg(dataFirst).arg(dataLast)
            }
            return ""
        }
    }

    Image {
        id: statusIcon
        anchors { right: parent.right; top: parent.top; rightMargin: iconsMargin; topMargin: iconsMargin }
        source: {
            var imStatus = getOnlineStatus();
            var icon = "";
            if (imStatus == TelepathyTypes.ConnectionPresenceTypeAvailable)
                icon = "image://themedimage/contacts/status_available_sml";
            else if (imStatus == TelepathyTypes.ConnectionPresenceTypeBusy)
                icon = "image://themedimage/contacts/status_busy_sml";
            // else: no icon
            return icon;
        }
    }

    Image {
        id: favoriteIcon
        height: 17; width: 17 // TODO this is temporary until a properly sized asset is added to the theme
        anchors { right: parent.right; rightMargin: width + (2*iconsMargin); top: parent.top; topMargin: iconsMargin }
        source: "image://themedimage/icons/actionbar/favorite-selected"
        visible: dataFavorite
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            contactCardLandscape.clicked();
        }
        onPressAndHold: {
            var map = mapToItem(window, mouseX, mouseY);
            if(dataFirst != "" && dataLast != "") {
                if(settingsDataStore.getDisplayOrder() == PeopleModel.LastNameRole)
                    contactCardLandscape.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataLast +", " + dataFirst, 25));
                else
                    contactCardLandscape.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataFirst +" " + dataLast, 25));
            } else if(dataFirst == "") {
                contactCardLandscape.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataLast, 25));
            } else if(dataLast == "") {
                contactCardLandscape.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataFirst, 25))
            } else {
                contactCardLandscape.pressAndHold(map.x, map.y, dataUuid, "");
            }
        }
    }

    function getOnlineStatus() {
        if ((dataPeople.data(sourceIndex, PeopleModel.OnlineAccountUriRole).length < 1)
                || (dataPeople.data(sourceIndex, PeopleModel.OnlineServiceProviderRole).length < 1))
            return "";

        var account = dataPeople.data(sourceIndex, PeopleModel.OnlineServiceProviderRole)[0].split("\n");
        if (account.length != 2)
            return "";
        account = account[1];

        var buddy = dataPeople.data(sourceIndex, PeopleModel.OnlineAccountUriRole)[0].split(") ");
        if (buddy.length != 2)
            return "";
        buddy = buddy[1];

        var contactItem = accountsModel.contactItemForId(account, buddy);
        var presence = contactItem.data(AccountsModel.PresenceTypeRole);
        return presence;
    }

    function getTruncatedString(valueStr, stringLen) {
        var MAX_STR_LEN = stringLen;
        //Make sure string is no longer than MAX_STR_LEN characters
        //Use MAX_STR_LEN - stringTruncater.length to make room for ellipses
        if (valueStr.length > MAX_STR_LEN) {
            valueStr = valueStr.substring(0, MAX_STR_LEN - stringTruncater.length);
            valueStr = valueStr + stringTruncater;
        }
        return valueStr;
    }
}
