/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

Item{
    id: phonesRect
    height: childrenRect.height
    width:  parent.width

    property variant newDetailsModel: null
    property int rIndex: -1
    property bool updateMode: false 
    property bool validInput: false 

    property string addressLabel: qsTr("Address")
    property string homeContext: qsTr("Home")
    property string workContext: qsTr("Work")
    property string otherContext: qsTr("Other")
    property string mobileContext: qsTr("Mobile")
    property string phoneHeaderLabel: qsTr("Phone numbers")
    property string addPhone: qsTr("Add number")
    property string defaultPhone: qsTr("Phone number")
    property string cancelLabel: qsTr("Cancel")
    property string addLabel: qsTr("Add")

    function parseDetailsModel(existingDetailsModel, contextModel) {
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++)
            arr[i] = {"phone": existingDetailsModel[i], "type": contextModel[i]};

        return arr;
    }

    function getNewDetailValues() {
        var phoneNumList = new Array();
        var phoneTypeList = new Array();
        var count = 0;
        for (var i = 0; i < newDetailsModel.count; i++) {
            if (newDetailsModel.get(i).phone != "") {
                phoneNumList[count] = newDetailsModel.get(i).phone;
                phoneTypeList[count] = newDetailsModel.get(i).type;
                count = count + 1;
            }
        }
        return {"numbers": phoneNumList, "types": phoneTypeList};
    }

    function getDetails(reset) {
        var arr = {"phone": data_phone.text, 
                   "type": phoneComboBox.selectedTitle};

        if (reset)
            resetFields();

        return arr;
    }

    function resetFields() {
       data_phone.text = "";
       phoneComboBox.selectedTitle = mobileContext;
    }

    DropDown {
        id: phoneComboBox

        anchors {left: parent.left; leftMargin: 10;}
        titleColor: theme_fontColorNormal

        width: 250
        minWidth: width
        maxWidth: width + 50

        model: [mobileContext, homeContext, workContext, otherContext]

        state: "notInUpdateMode"

        states: [
            State {
                name: "inUpdateMode"; when: (updateMode == true)
                PropertyChanges{target: phoneComboBox; title: newDetailsModel.get(rIndex).type}
                PropertyChanges{target: phoneComboBox; selectedTitle: newDetailsModel.get(rIndex).type}
            },
            State {
                name: "notInUpdateMode"; when: (updateMode == false)
                PropertyChanges{target: phoneComboBox; title: mobileContext}
                PropertyChanges{target: phoneComboBox; selectedTitle: mobileContext}
            }
        ]
    }

    TextEntry {
        id: data_phone
        text: (updateMode) ? newDetailsModel.get(rIndex).phone : ""
        defaultText: defaultPhone
        width: 400
        anchors {left:phoneComboBox.right; leftMargin: 10;}
        inputMethodHints: Qt.ImhDialableCharactersOnly
    }

    Binding {target: phonesRect; property: "validInput"; value: true;
             when: (data_phone.text != "")
            }

    Binding {target: phonesRect; property: "validInput"; value: false;
             when: (data_phone.text == "")
            }
}
