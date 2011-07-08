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
    width: parent.width

    property variant newDetailsModel: null 
    property int rIndex: -1
    property bool updateMode: false 
    property bool validInput: false
    property int itemMargins: 10

    //: Instant Messaging Accounts for this contact
    property string imLabel : qsTr("Instant messaging")
    property string aim_sp : qsTr("AIM")
    property string msn_sp : qsTr("MSN")
    property string jabber_sp : qsTr("Jabber")
    property string yahoo_sp : qsTr("Yahoo!")
    property string facebook_sp : qsTr("Facebook")

    //: Name of the Google Talk messaging service - this might differ by locale
    property string gtalk_sp : qsTr("gTalk")
    property string defaultIm : qsTr("Account Name / ID")
    property string defaultAccount : qsTr("Account Type")
    property string noAccount: qsTr("No IM accounts are configured")
    property string noBuddies : qsTr("No buddies for this account")

    property bool canSave: false

    SaveRestoreState {
        id: srsIM
        onSaveRequired: {
            if(newDetailsModel != null && !updateMode && imsRect.canSave){
                if(newDetailsModel.count > 0){
                    var pageTitle = window.pageStack.currentPage.pageTitle;
                    setValue(pageTitle + ".im.count", newDetailsModel.count)
                    for (var i = 0; i < newDetailsModel.count; i++){
                        setValue(pageTitle + ".im.account" + i, newDetailsModel.get(i).im)
                        setValue(pageTitle + ".im.type" + i, newDetailsModel.get(i).type)
                    }
                }
            }
            sync()
        }
    }

    function restoreData() {
        if(srsIM.restoreRequired && !updateMode){
            var pageTitle = window.pageStack.currentPage.pageTitle;
            var imCount = srsIM.value(pageTitle + ".im.count", 0)
            if(imCount > 0){
                for(var i = 0; i < imCount; i++){
                    newDetailsModel.set(i, {"im": srsIM.restoreOnce(pageTitle + ".im.account" + i, "")})
                    newDetailsModel.set(i, {"type": srsIM.restoreOnce(pageTitle + ".im.type" + i, "")})
                }
            }
        }
        imsRect.canSave = true
    }

    function parseDetailsModel(existingDetailsModel, contextModel) {
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++) {
            var type = contextModel[i].split("\n")[0];
            arr[i] = {"im": existingDetailsModel[i], "type": type};
        }

        return arr;
    }

    function getInitFields() {
        return {"im" : "", "account" : "", "type" : ""};
    }

    function getNewDetailValues() {
        var imList = new Array();
        var imTypeList = new Array();
        var count = 0;
        for (var i = 0; i < newDetailsModel.count; i++) {
            if (newDetailsModel.get(i).im != "") {
                imList[count] = newDetailsModel.get(i).im;
                imTypeList[count] = newDetailsModel.get(i).type + "\n" 
                                    + newDetailsModel.get(i).account;
                count = count + 1;
            }
        }
        return {"ims": imList, "types": imTypeList};
    }

    function getDetails(reset) {
        var type = imComboBox.model[imComboBox.selectedIndex];
        var arr = {"im": imComboBox2.model[imComboBox2.selectedIndex],
                   "type": type,
                   "account": getAccountByType(type)}

        if (reset)
            resetFields();

        return arr;
    }

    function resetFields() {
        imComboBox.selectedIndex = 0;
        imComboBox2.selectedIndex = 0;
    }

    function getAccountByType(type) {
        for (var i = 0; i < imContexts.count; i++) {
            if (type == imContexts.get(i).accountType)
                return imContexts.get(i).account;
        }
        return "";
    }

    function getAvailableAccountTypes() {
        var accountTypes = new Array();

        for (var i = 0; i < imContexts.count; i++) {
            accountTypes[i] = imContexts.get(i).accountType;
        }

        if (i == 0)
            accountTypes[0] = noAccount;

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

    ListModel{
        id: imContexts
        Component.onCompleted:{
            var list = telepathyManager.availableAccounts();
            for (var account in list) {
                imContexts.append({"accountType": list[account],
                                   "account": account});
            }
        }
    }

    function getIndexVal(model, value) {
        for (var i = 0; i < model.length; i++) {
            if (model[i] == value)
                return i;
         }
         return 0;
     }

    DropDown {
        id: imComboBox
 
        anchors {left: parent.left; leftMargin: itemMargins}
        titleColor: theme_fontColorNormal
 
        width: Math.round(parent.width/2) - 4*anchors.leftMargin
        minWidth: width 
        maxWidth: width
 
        model: getAvailableAccountTypes()

        title: (updateMode) ? newDetailsModel.get(rIndex).type : defaultAccount 
        selectedIndex: (updateMode) ? getIndexVal(imComboBox.model, newDetailsModel.get(rIndex).type) : 0
        replaceDropDownTitle: true
    }

    DropDown {
        id: imComboBox2
 
        anchors {left:imComboBox.right; leftMargin: itemMargins;}
        titleColor: theme_fontColorNormal
 
        width: Math.round(parent.width/2) - 4*anchors.leftMargin
        minWidth: width 
        maxWidth: width
 
        model: getAvailableBuddies(imComboBox.selectedTitle)
 
        state: "notInUpdateMode"
 
        states: [
            State {
                name: "inUpdateMode"; when: (imsRect.updateMode == true)
                PropertyChanges {
                    target: imComboBox2;
                    selectedIndex: getIndexVal(imComboBox2.model,
                                               newDetailsModel.get(rIndex).im)
                }
            },
            State {
                name: "notInUpdateMode"; when: (imsRect.updateMode == false)
                PropertyChanges {
                    target: imComboBox2;
                    selectedIndex: getIndexVal(imComboBox2.model, defaultIm)
                }
            }
        ]
    }

    Binding {
        target: imsRect; property: "validInput"; value: true;
        when: ((imComboBox.model[imComboBox.selectedIndex] != defaultAccount) &&
              (imComboBox.model[imComboBox.selectedIndex] != noAccount) &&
              (imComboBox2.model[imComboBox2.selectedIndex] != defaultIm) &&
              (imComboBox2.model[imComboBox2.selectedIndex] != noBuddies))
    }

    Binding {
        target: imsRect; property: "validInput"; value: false; 
        when: ((imComboBox.model[imComboBox.selectedIndex] == defaultAccount) &&
              (imComboBox.model[imComboBox.selectedIndex] == noAccount) &&
              (imComboBox2.model[imComboBox2.selectedIndex] == defaultIm) &&
              (imComboBox2.model[imComboBox2.selectedIndex] == noBuddies))
    }
}

