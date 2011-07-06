/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

Item {
    id: emailRect
    height: childrenRect.height
    width: parent.width

    property variant newDetailsModel: null
    property int rIndex: -1
    property bool updateMode: false 
    property bool validInput: false 
    property int itemMargins: 10

    property string contextHome : qsTr("Home")
    property string contextWork : qsTr("Work")
    property string contextOther : qsTr("Other")
    property string defaultEmail : qsTr("Email address")

    property string prefixSaveRestore: ""
    property bool canSave: false

    SaveRestoreState {
        id: srsMail
        onSaveRequired: {
            if(!updateMode && emailRect.canSave){
                // Save the phone number that is currently being edited
                setValue(prefixSaveRestore + ".email.address", data_email.text)
                setValue(prefixSaveRestore + ".email.typeIndex", emailComboBox.selectedIndex)
            }

            sync()
        }
    }

    function restoreData() {
        if(srsMail.restoreRequired && !updateMode){
            var restoredEmail = srsMail.restoreOnce(prefixSaveRestore + ".email.address", "")
            var index = srsMail.restoreOnce(prefixSaveRestore + ".email.typeIndex", -1)

            data_email.text = restoredEmail;

            if (index != -1) {
                emailComboBox.title = emailComboBox.model[index];
                emailComboBox.selectedIndex = index;
            }
            else {
                emailComboBox.title = contextHome;
                emailComboBox.selectedIndex = 0;
            }
        }
        emailRect.canSave = true
    }

    function parseDetailsModel(existingDetailsModel, contextModel) {
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++)
            arr[i] = {"email": existingDetailsModel[i], "type": contextModel[i]};

        return arr;
    }

    function getNewDetailValues() {
        var emailAddyList = new Array();
        var emailTypeList = new Array();
        var count = 0;

        for (var i = 0; i < newDetailsModel.count; i++) {
            if (newDetailsModel.get(i).email != "") {
                emailAddyList[count] = newDetailsModel.get(i).email;
                emailTypeList[count] = newDetailsModel.get(i).type;
                count = count + 1;
            }
        }
        return {"emails": emailAddyList, "types": emailTypeList};
    }

    function getDetails(reset) {
        var arr = {"email": data_email.text,
                   "type": emailComboBox.model[emailComboBox.selectedIndex]};

        if (reset)
            resetFields();

        return arr;
    }

    function resetFields() {
       data_email.text = "";
       emailComboBox.selectedIndex = 0;
    }

    function getIndexVal(type) {
        if (updateMode) {
            for (var i = 0; i < emailComboBox.model.length; i++) {
                if (emailComboBox.model[i] == newDetailsModel.get(rIndex).type)
                    return i;
            }
        }
        return 0;
    }

    function updateDisplayedData(){
        if(updateMode){
            emailComboBox.title = (updateMode) ? newDetailsModel.get(rIndex).type : contextHome
            emailComboBox.selectedIndex = (updateMode) ? getIndexVal(newDetailsModel.get(rIndex).type) : 0
        }
    }

    DropDown {
        id: emailComboBox

        anchors {left: parent.left; leftMargin: itemMargins;}
        titleColor: theme_fontColorNormal

        width: Math.round(parent.width/2) - 4*anchors.leftMargin
        minWidth: width
        maxWidth: width

        model: [contextHome, contextWork, contextOther]

        title: (updateMode) ? newDetailsModel.get(rIndex).type : contextHome
        selectedIndex: (updateMode) ? getIndexVal(newDetailsModel.get(rIndex).type) : 0
        replaceDropDownTitle: true
    }

    TextEntry {
        id: data_email
        text: (updateMode) ? newDetailsModel.get(rIndex).email : ""
        defaultText: defaultEmail
        width: Math.round(parent.width/2) - 4*anchors.leftMargin
        anchors {left:emailComboBox.right; leftMargin: itemMargins;}
        inputMethodHints: Qt.ImhEmailCharactersOnly
    }

    Binding {target: emailRect; property: "validInput"; value: true;
             when: (data_email.text != "")
            }

    Binding {target: emailRect; property: "validInput"; value: false;
             when: (data_email.text == "")
            }
}

