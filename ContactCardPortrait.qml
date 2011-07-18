/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Contacts 0.1
import MeeGo.App.IM 0.1
import TelepathyQML 0.1

Image {
    id: contactCardPortrait

    height: photo.height + itemMargins
    width: parent.width
    anchors.right: parent.right

    property PeopleModel dataPeople : theModel
    property ProxyModel sortPeople : sortModel
    property int sourceIndex: sortPeople.getSourceRow(index)
    property string stringTruncater: qsTr("...")
    property int itemMargins: 10

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

    function getOnlineStatus(presence) {
        var icon = "";
        var text = "";

        switch (presence) {
            case TelepathyTypes.ConnectionPresenceTypeAvailable:
                icon = "image://themedimage/icons/status/status-available"
                text = statusOnline;
                break;
            case TelepathyTypes.ConnectionPresenceTypeBusy:
                icon = "image://themedimage/icons/status/status-busy"
                text = statusBusy;
                break;
            case TelepathyTypes.ConnectionPresenceTypeAway:
            case TelepathyTypes.ConnectionPresenceTypeExtendedAway:
                icon = "image://themedimage/icons/status/status-idle";
                text = statusIdle;
                break;
            case TelepathyTypes.ConnectionPresenceTypeHidden:
            case TelepathyTypes.ConnectionPresenceTypeUnknown:
            case TelepathyTypes.ConnectionPresenceTypeError:
            case TelepathyTypes.ConnectionPresenceTypeOffline:
            default:
                icon = "image://themedimage/icons/status/status-idle";
                text = statusOffline;
        }
        return [icon, text];
    }

    property string dataFirst: dataPeople.data(sourceIndex, PeopleModel.FirstNameRole)
    property string dataUuid: dataPeople.data(sourceIndex, PeopleModel.UuidRole);
    property string dataLast:  dataPeople.data(sourceIndex, PeopleModel.LastNameRole)
    property bool dataFavorite: dataPeople.data(sourceIndex, PeopleModel.FavoriteRole)
    property int dataStatus: dataPeople.data(sourceIndex, PeopleModel.PresenceRole)
    property bool dataMeCard: dataPeople.data(sourceIndex, PeopleModel.IsSelfRole)
    //REVISIT: Instead of using the URI from AvatarRole, need to use thumbnail URI
    property string dataAvatar: dataPeople.data(sourceIndex, PeopleModel.AvatarRole)

    //: Remove favorite flag / remove contact from favorites list
    property string unfavoriteTranslated: qsTr("Unfavorite")

    //: Add favorite flag / add contact to favorites list
    property string favoriteTranslated: qsTr("Favorite", "Verb")

    property string statusIdle: qsTr("Idle")
    property string statusBusy: qsTr("Busy")
    property string statusOnline: qsTr("Online")
    property string statusOffline: qsTr("Offline")

    //: Truncate string - used when a string is too long for the display area
    property string ellipse: qsTr("(...)")

    signal clicked
    signal pressAndHold(int mouseX, int mouseY, string uuid, string name)

    source: "image://themedimage/widgets/common/list/list"
    opacity: (dataPeople.data(sourceIndex, PeopleModel.IsSelfRole) ? .7 : 1)

    Connections {
        target: accountsModel
        ignoreUnknownSignals: true
        onComponentsLoaded: {
            var uri = dataPeople.data(sourceIndex,
                                      PeopleModel.OnlineAccountUriRole);
            var provider = dataPeople.data(sourceIndex,
                                           PeopleModel.OnlineServiceProviderRole);

            if ((uri.length < 1) || (provider.length < 1))
               return;

            var account = provider[0].split("\n");
            if (account.length != 2)
                return;
            account = account[1];

            var buddy = uri[0].split(") ");
            if (buddy.length != 2)
                return;
            buddy = buddy[1];

            var contactItem = accountsModel.contactItemForId(account, buddy);
            var presence = contactItem.data(AccountsModel.PresenceTypeRole);

            statusIcon.source = getOnlineStatus(presence)[0];
            statusText.text = getOnlineStatus(presence)[1];
        }
    }

    LimitedImage{
        id: photo
        fillMode: Image.PreserveAspectCrop
        smooth: true
        clip: true
        width: theme_listBackgroundPixelHeightTwo
        height: theme_listBackgroundPixelHeightTwo
        source: (dataAvatar ? dataAvatar :"image://themedimage/widgets/common/avatar/avatar-default")
        anchors {left: contactCardPortrait.left;
                 top: parent.top; topMargin: itemMargins}
        onStatusChanged: {
            if(photo.status == Image.Error || photo.status == Image.Null){
                photo.source = "image://themedimage/widgets/common/avatar/avatar-default";
            }
        }
    }

    Text {
        id: nameFirst
        text: {
            if((dataFirst != "") || (dataLast != "")) {
                if (settingsDataStore.getDisplayOrder() == PeopleModel.LastNameRole) {
                    //: %1 is last name, %2 is first name
                    return qsTr("%1 %2", "LastFirstName").arg(getTruncatedString(dataLast, 25)).arg(getTruncatedString(dataFirst, 25));
                } else {
                    //: %1 is first name, %2 is last name
                    return qsTr("%1 %2", "FirstLastName").arg(getTruncatedString(dataFirst, 25)).arg(getTruncatedString(dataLast, 25));
                }
            }
            else if(dataPeople.data(sourceIndex, PeopleModel.CompanyNameRole) != "")
                return getTruncatedString(dataPeople.data(sourceIndex, PeopleModel.CompanyNameRole), 25);
            else if(dataPeople.data(sourceIndex, PeopleModel.PhoneNumberRole) != "")
                return getTruncatedString(dataPeople.data(sourceIndex, PeopleModel.PhoneNumberRole), 25)[0];
            else if(dataPeople.data(sourceIndex, PeopleModel.OnlineAccountUriRole)!= "")
                return getTruncatedString(dataPeople.data(sourceIndex, PeopleModel.OnlineAccountUriRole), 25)[0];
            else if (dataPeople.data(sourceIndex, PeopleModel.EmailAddressRole) != "")
                return getTruncatedString(dataPeople.data(sourceIndex, PeopleModel.EmailAddressRole), 25)[0];
            else if (dataPeople.data(sourceIndex, PeopleModel.WebUrlRole) != "")
                return getTruncatedString(dataPeople.data(sourceIndex, PeopleModel.WebUrlRole), 25)[0];
            else
                return ellipse;
        }
        anchors { left: photo.right; top: photo.top; topMargin: photo.height/8-contactDivider.height; leftMargin: photo.height/8}
        font.pixelSize: theme_fontPixelSizeLargest
        color: theme_fontColorNormal; smooth: true
    }

    //    REVISIT:Text {
    //        id: nameLast
    //        text: dataLast
    //        anchors { left: nameFirst.right; top: nameFirst.top; leftMargin: photo.height/8;}
    //        font.pixelSize: theme_fontPixelSizeLargest
    //        color: theme_fontColorNormal; smooth: true
    //    }

    Image {
        id: favorite
        source: (dataPeople.data(sourceIndex, PeopleModel.FavoriteRole) ? "image://themedimage/icons/actionbar/favorite-selected" : "image://themedimage/icons/actionbar/favorite" )
        opacity: (dataMeCard ? 0 : 1)
        anchors {right: contactCardPortrait.right; top: nameFirst.top; rightMargin: photo.height/8;}
    }

    Image {
        id: statusIcon
        source: "image://themedimage/icons/status/status-idle"
        anchors {horizontalCenter: favorite.horizontalCenter; verticalCenter: statusText.verticalCenter  }
    }

    Text {
        id: statusText
        color: theme_fontColorNormal
        font.pixelSize: theme_fontPixelSizeLarge
        smooth: true
        anchors { left: nameFirst.left; bottom: photo.bottom; bottomMargin: photo.height/8}
        text: statusOffline
    }

    Image{
        id: contactDivider
        source: "image://themedimage/widgets/common/dividers/divider-horizontal-double"
        anchors {right: contactCardPortrait.right; bottom: contactCardPortrait.bottom; left: contactCardPortrait.left}
    }

    MouseArea {
        id: mouseArea
        anchors.fill: contactCardPortrait
        onClicked: {
            contactCardPortrait.clicked();
        }
        onPressAndHold: {
            var map = mapToItem(window, mouseX, mouseY);
            if(dataFirst != "" && dataLast != ""){
                if(settingsDataStore.getDisplayOrder() == PeopleModel.LastNameRole)
                    contactCardPortrait.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataLast +", " + dataFirst, 25));
                else
                    contactCardPortrait.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataFirst +" " + dataLast, 25));
            }else if(dataFirst == ""){
                contactCardPortrait.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataLast, 25));
            }else if(dataLast == ""){
                contactCardPortrait.pressAndHold(map.x, map.y, dataUuid, getTruncatedString(dataFirst, 25))
            }else{
                contactCardPortrait.pressAndHold(map.x, map.y, dataUuid, "");
            }
        }
    }

    states: State {
        name: "pressed"; when: mouseArea.pressed == true
        PropertyChanges { target: contactCardPortrait; opacity: .7}
    }

}
