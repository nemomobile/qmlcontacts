/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.App.Contacts 0.1
import MeeGo.App.IM 0.1

Item {
    id: imsRect
    height: childrenRect.height
    width:  parent.width

    property variant imModel: contactModel
    property variant contextModel: typeModel
    property bool    validInput   : false

    property int initialHeight: childrenRect.height

    property string addIm : qsTr("Add account")
    property string imLabel : qsTr("Instant messaging")
    property string aim_sp : qsTr("AIM")
    property string msn_sp : qsTr("MSN")
    property string jabber_sp : qsTr("Jabber")
    property string yahoo_sp : qsTr("Yahoo")
    property string facebook_sp : qsTr("Facebook")
    property string gtalk_sp : qsTr("gTalk")
    property string defaultIm : qsTr("Account Name / ID")
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

    /* REVISIT: Need to add a connection, as telepathyManager isn't always available
    Connections {
        target: accountsModel
        onComponentsLoaded: {
            console.log("-------------READY!");
        }
    }
    */

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
                for (var i = 0; i < list.length; i++) {
                    buddyList[i] = list[i];
                }
                if (buddyList.length > 0)
                    return buddyList;
            }
        }
        return [noBuddies];
    }

    Column{
        spacing: 1
        anchors {left:parent.left; right: parent.right; }

        Item {
            id: imHeader
            width: parent.width
            height: 70
            opacity: 1

            Text{
                id: label_im
                text: imLabel
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorInactive
                smooth: true
                anchors {bottom: imHeader.bottom; bottomMargin: 10; left: imHeader.left; leftMargin: 30}
            }
        }

        Repeater{
            model: ims
            width: parent.width
            height: childrenRect.height
            opacity: (imModel.length > 0 ? 1  : 0)
            delegate: Item {
                id: itemDelegate
                width: parent.width
                height: 80
                signal clicked()

                //Need to store the repeater index, as the drop down overwrites index with its own value
                property int repeaterIndex: index
                Image{
                    id: imBar
                    source: "image://theme/contacts/active_row"
                    anchors.fill:  parent

                    DropDown {
                        id: imComboBox
                        height: 60
                        delegateComponent: stringDelegate
                        visible: ((imContexts.count > 0 || ims.count > 0) ? 1  : 0)

                        anchors {verticalCenter: imBar.verticalCenter; left: imBar.left; leftMargin: 10}

                        selectedValue: type

                        dataModel: imContexts 

                        Component {
                            id: stringDelegate
                            Text {
                                id: listVal
                                property variant data
                                x: 15
                                text: "<b>" + data.accountType + "</b>"
                            }
                        }
                        onSelectionChanged: {
                            validInput = true;
                            if (ims.get(repeaterIndex).im == "")
                                ims.set(repeaterIndex, {"im": imComboBox2.dataList[imComboBox2.selectedIndex], 
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
                        height: 60
                        delegateComponent: stringDelegate2
                        visible: ((imContexts.count > 0 || ims.count > 0) ? 1  : 0)

                        anchors {verticalCenter: parent.verticalCenter; left:imComboBox.right; leftMargin: 10; right: delete_button.left; rightMargin: 10}

                        selectedValue: ims.get(repeaterIndex).im

                        dataList: getAvailableBuddies(imContexts.get(repeaterIndex).accountType)

                        Component {
                            id: stringDelegate2
                            Text {
                                id: listVal
                                property variant data
                                x: 15
                                text: "<b>" + data + "</b>"
                            }
                        }
                        onSelectionChanged: {
                            if (ims.get(repeaterIndex).type == "")
                                ims.set(repeaterIndex, {"im": data,
                                        "type": imContexts.get(imComboBox.selectedIndex).accountType,
                                        "account": imContexts.get(imComboBox.selectedIndex).account});
                            else
                                ims.setProperty(repeaterIndex, "im", data);
                        }
                    }

                    Text{
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
                                if(ims.count != 1 ){
                                    ims.remove(index);
                                    imsRect.height = imsRect.height-itemDelegate.height;
                                }else{
                                    imComboBox2.selectedValue = imComboBox2.dataList[0];
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


        Item {
            id: addFooter
            width: parent.width
            height: 80
            Image{
                id: addBar
                source: "image://theme/contacts/active_row"
                anchors.fill:  parent
                anchors.bottomMargin: 1

                ExpandingBox {
                    Image {
                        id: add_button
                        source: "image://theme/contacts/icn_add"
                        anchors{ verticalCenter: imBox.verticalCenter; left: imBox.left; leftMargin: 20}
                        width: 36
                        height: 36
                        opacity: 1
                    }

                    id: imBox
                    detailsComponent: imComponent

                    expanded: false
                    width: parent.width
                    anchors{ verticalCenter: addBar.verticalCenter; top: addBar.top; leftMargin: 15;}
                    titleTextItem.text: addIm
                    titleTextItem.color: theme_fontColorNormal
                    titleTextItem.anchors.leftMargin: add_button.width + add_button.anchors.leftMargin + imBox.anchors.leftMargin
                    titleTextItem.font.bold: true
                    titleTextItem.font.pixelSize: theme_fontPixelSizeLarge
                    pulldownImageSource: "image://theme/contacts/active_row"

                    expandedHeight: detailsItem.height + expandButton.height

                    onExpandedChanged: {
                        imsRect.height = expanded ? (initialHeight + expandedHeight) : initialHeight;
                        add_button.source = expanded ? "image://theme/contacts/icn_add_dn" : "image://theme/contacts/icn_add";
                        pulldownImageSource = expanded ? "image://theme/contacts/active_row_dn" : "image://theme/contacts/active_row"
                    }

                    Component {
                        id: imComponent
                        Item {
                            id: imBar2
                            height: 100

                            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                                id: imComboBox3
                                height: 60
                                delegateComponent: stringDelegate3
                                visible: (imContexts.count > 0 ? 1  : 0)

                                anchors {left: imBar2.left; leftMargin: imBox.titleTextItem.anchors.leftMargin - imBox.anchors.leftMargin;}
                                dataList: getAvailableAccountTypes()

                                Component {
                                    id: stringDelegate3
                                    Text {
                                        id: listVal
                                        property variant data
                                        x: 15
                                        text: "<b>" + data + "</b>"
                                    }
                                }
                            }

                            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                                id: imComboBox4
                                height: 60
                                delegateComponent: stringDelegate4
                                visible: (imContexts.count > 0 ? 1  : 0)

                                anchors {left:imComboBox3.right; leftMargin: 10;}

                                dataList: getAvailableBuddies(imComboBox3.selectedIndex)

                                Component {
                                    id: stringDelegate4
                                    Text {
                                        id: listVal
                                        property variant data
                                        x: 15
                                        text: "<b>" + data + "</b>"
                                    }
                                }
                            }

                            Button {
                                id: addButton
                                width: 100
                                height: 36
                                title: addLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                bgSourceUp: "image://theme/btn_blue_up"
                                bgSourceDn: "image://theme/btn_blue_dn"
                                anchors {right:cancelButton.left; top: imComboBox3.bottom; topMargin: 15; rightMargin: 5;}
                                visible: (imContexts.count > 0 ? 1  : 0)
                                onClicked: {
                                    ims.append({"im": imComboBox4.dataList[imComboBox4.selectedIndex], 
                                               "type": imContexts.get(imComboBox3.selectedIndex).accountType,
                                               "account": imContexts.get(imComboBox3.selectedIndex).account});
                                    imBox.expanded = false;
                                    imComboBox3.selectedValue = imComboBox3.dataList[0];
                                    imComboBox4.selectedValue = imComboBox4.dataList[0];
                                }
                            }

                            Button {
                                id: cancelButton
                                width: 100
                                height: 36
                                title: cancelLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                anchors {right:imComboBox4.right; top: imComboBox4.bottom; topMargin: 15;}
                                visible: (imContexts.count > 0 ? 1  : 0)
                                onClicked: {
                                    imBox.expanded = false;
                                    imComboBox3.selectedValue = imComboBox3.dataList[0];
                                    imComboBox4.selectedValue = imComboBox4.dataList[0];
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
            }
        }
    }
}
