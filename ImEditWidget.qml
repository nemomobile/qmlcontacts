/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.App.Contacts 0.1
import MeeGo.App.IM 0.1

Item {
    id: imsRect
    height: childrenRect.height
    width:  parent.width

    property variant imModel: contactModel
    property variant contextModel: typeModel
    property bool validInput: false
    property int initialHeight: childrenRect.height

    property alias detailsBoxExpanded: imDetailsItem.expanded

    property string addIm : qsTr("Add account")
    property string imLabel : qsTr("Instant messaging")
    property string aim_sp : qsTr("AIM")
    property string msn_sp : qsTr("MSN")
    property string jabber_sp : qsTr("Jabber")
    property string yahoo_sp : qsTr("Yahoo")
    property string facebook_sp : qsTr("Facebook")
    property string gtalk_sp : qsTr("gTalk")
    property string defaultIm : qsTr("Account Name / ID")
    property string defaultAccount : qsTr("Account Type")
    property string noAccount: qsTr("No IM accounts are configured")
    property string noBuddies : qsTr("No buddies for this account")
    property string cancelLabel: qsTr("Cancel")
    property string addLabel: qsTr("Add")

    function getNewIms() {
        var imList = new Array();
        var imTypeList = new Array();
        var count = 0;
        for (var i = 0; i < ims.count; i++) {
            if (ims.get(i).im != "") {
                imList[count] = ims.get(i).im;
                imTypeList[count] = ims.get(i).type + "\n" + ims.get(i).account;
                count = count + 1;
            }
        }
        return {"ims": imList, "types": imTypeList};
    }

    ListModel{
        id: ims
        Component.onCompleted:{
            for(var i =0; i < imModel.length; i++) {
                var type = contextModel[i].split("\n")[0];
                ims.append({"im": imModel[i], "type": type});
            }
        }
    }

    ListModel{
        id: imContexts 
        Component.onCompleted:{
            var list = telepathyManager.availableAccounts();
            for (var account in list) {
                imContexts.append({"accountType": list[account], "account": account});
            }
        }
    }

    function getAvailableAccountTypes() {
        var accountTypes = new Array();

        for (var i = 0; i < imContexts.count; i++) {
            accountTypes[i] = imContexts.get(i).accountType;
        }
        return accountTypes;
    }

    function getAvailableBuddies(selectedIndex) {
        var buddyList = new Array();
        for (var i = 0; i < imContexts.count; i++) {
            if (imContexts.get(i).accountType == imContexts.get(selectedIndex).accountType) {
                var list = telepathyManager.availableContacts(imContexts.get(i).account);
                if (list.length > 0) {
                    buddyList[0] = defaultIm;
                    for (var i = 1; i < list.length + 1; i++) {
                        buddyList[i] = list[i - 1];
                    }

                    return buddyList;
                }
            }
        }
        return [noBuddies];
    }

    ContactsExpandableDetails {
        id: imDetailsItem

        headerLabel: imLabel
        expandingBoxTitle: addIm
        repeaterComponent: imExistingComponent

        detailsModel: ims
        fieldDetailComponent: imNewComponent

        onDetailsBoxExpandingChanged: {
            imsRect.height = expanded ? (initialHeight + newHeight) : initialHeight;
        }
    }

    Component {
        id: imExistingComponent

        Item {
            id: itemDelegate
            width: (parent ? parent.width : 0)
            height: 80

            //Need to store the repeater index, as the drop down overwrites index with its own value
            property int repeaterIndex: index
            Image {
                id: imBar
                source: "image://theme/contacts/active_row"
                anchors.fill: parent

                DropDown {
                    id: imComboBox

                    anchors {verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10}
                    title: ims.get(repeaterIndex).type
                    titleColor: theme_fontColorNormal
                    replaceDropDownTitle: true

                    width: 250
                    minWidth: width
                    maxWidth: width + 50
                        
                    model: getAvailableAccountTypes()

                    onTriggered: {
                        validInput = true;
                        if (ims.get(repeaterIndex).im == "")
                            ims.set(repeaterIndex, {"im": imComboBox2.selectedTitle, 
                                                    "type": data.accountType,
                                                    "account": data.account});
                        else {
                            ims.setProperty(repeaterIndex, "type", data.accountType);
                            ims.setProperty(repeaterIndex, "account", data.account);
                        }
                    }
                }

                DropDown {
                    id: imComboBox2

                    anchors {verticalCenter: parent.verticalCenter; left:imComboBox.right; leftMargin: 10; right: delete_button.left; rightMargin: 10}
                    title: ims.get(repeaterIndex).im
                    titleColor: theme_fontColorNormal
                    replaceDropDownTitle: true

                    width: 450
                    minWidth: width
                    maxWidth: width + 50

                    model: (imComboBox.selectedTitle) ? getAvailableBuddies(imComboBox.selectedTitle) : getAvailableBuddies(ims.get(repeaterIndex).type)

                    onTriggered: {
                        if (ims.get(repeaterIndex).type == "")
                            ims.set(repeaterIndex, {"im": data,
                                                    "type": imContexts.get(imComboBox.selectedIndex).accountType,
                                                    "account": imContexts.get(imComboBox.selectedIndex).account});
                        else
                            ims.setProperty(repeaterIndex, "im", data);
                    }
                }

                Text {
                    id: label_no_im
                    text: noAccount
                    color: theme_fontColorNormal
                    font.pixelSize: theme_fontPixelSizeLarge
                    styleColor: theme_fontColorInactive
                    smooth: true
                    visible: ((imContexts.count < 0 && ims.count < 0) ? true : false)
                    anchors {bottom: parent.bottom; bottomMargin: 30; left: parent.left; leftMargin: 30;}
                }

                Image {
                    id: delete_button
                    source: "image://theme/contacts/icn_trash"
                    width: 36
                    height: 36
                    anchors {verticalCenter: imComboBox2.verticalCenter; right:parent.right; rightMargin: 20}
                    opacity: 1

                    MouseArea{
                        id: mouse_delete_im

                        anchors.fill: parent

                        onPressed: {
                            delete_button.source = "image://theme/contacts/icn_trash_dn";
                        }

                        onClicked: {
                            if (ims.count != 1) {
                                ims.remove(index);
                                if (imsRect.height > initialHeight)
                                    imsRect.height = imsRect.height-itemDelegate.height;
                            } else {
                                imComboBox.selectedTitle = defaultAccount
                                imComboBox2.selectedTitle = defaultIm
                            }
                            delete_button.source = "image://theme/contacts/icn_trash";
                        }
                    }
                    Binding{target: delete_button; property: "visible"; value: false; when: ims.count < 2}
                    Binding{target: delete_button; property: "visible"; value: true; when: ims.count > 1}
                }
            }
        }
    }

    Component {
        id: imNewComponent
        Image {
            id: imBar2
            height: 100
            width: parent.width
            //source: "image://theme/contacts/active_row_dn" //REVISIT

            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                id: imComboBox3

                anchors {left: parent.left; leftMargin: 36}
                title: defaultAccount
                titleColor: theme_fontColorNormal
                replaceDropDownTitle: true

                width: 250
                minWidth: width
                maxWidth: width + 50
                        
                model: getAvailableAccountTypes()
            }

            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                id: imComboBox4

                anchors {left:imComboBox3.right; leftMargin: 10;}
                title: defaultIm
                titleColor: theme_fontColorNormal
                replaceDropDownTitle: true

                width: 450
                minWidth: width
                maxWidth: width + 50

                model: (imComboBox3.selectedTitle) ? getAvailableBuddies(imComboBox3.selectedTitle) : [noBuddies]
            }

            Button {
                id: addButton

                width: 100
                height: 36
                text: addLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                bgSourceUp: "image://theme/btn_blue_up"
                bgSourceDn: "image://theme/btn_blue_dn"
                anchors {right:cancelButton.left; top: imComboBox3.bottom; topMargin: 15; rightMargin: 5;}
                visible: (imContexts.count > 0 ? 1  : 0)
                active: (imComboBox4.selectedTitle == defaultIm ? false : true)

                onClicked: {
                    validInput = true;
                    ims.append({"im": imComboBox4.selectedTitle,
                                "type": imContexts.get(imComboBox3.selectedIndex).accountType,
                                "account": imContexts.get(imComboBox3.selectedIndex).account});
                    detailsBoxExpanded = false;
                    imComboBox3.selectedTitle = defaultAccount
                    imComboBox4.selectedTitle = defaultIm
                }
            }

            Button {
                id: cancelButton

                width: 100
                height: 36
                text: cancelLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                anchors {right:imComboBox4.right; top: imComboBox4.bottom; topMargin: 15;}
                visible: (imContexts.count > 0 ? 1  : 0)

                onClicked: {
                    detailsBoxExpanded = false;
                    imComboBox3.selectedTitle = defaultAccount
                    imComboBox4.selectedTitle = defaultIm
                }
            }

            Text{
                id: label_no_im

                text: noAccount
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorInactive
                smooth: true
                visible: (imContexts.count > 0 ? 0  : 1)
                anchors {bottom: parent.bottom; bottomMargin: 30; left: parent.left; leftMargin: 30;}
            }
        } 
    }
}

