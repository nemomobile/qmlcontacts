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
    id: addressRect
    height: childrenRect.height
    width: parent.width

    property variant newDetailsModel: null 
    property int rIndex: -1
    property bool updateMode: false 
    property bool validInput: false 

    property string homeContext: qsTr("Home")
    property string workContext: qsTr("Work")
    property string otherContext: qsTr("Other")
    property string streetAddress: qsTr("Street address")
    property string localeAddress: qsTr("Town / City")
    property string regionAddress: qsTr("Region / State")
    property string countryAddress:  qsTr("Country")
    property string postcodeAddress:  qsTr("Postcode / Zip")

    property int restoredAddressTypeIndex: -1
    property string prefixSaveRestore: ""

    SaveRestoreState {
        id: srsAddress
        onSaveRequired: {
            if(!updateMode){
                if(addressFieldRepeater){
                    for(var i = 0; i < addressFieldRepeater.itemCount; i++){
                        var tempItem = addressFieldRepeater.itemList[i]
                        if(tempItem){
                            if(tempItem.fieldVal == "street"){
                                setValue(prefixSaveRestore + ".address.street", tempItem.text);
                            }else if(tempItem.fieldVal == "locale"){
                                setValue(prefixSaveRestore + ".address.locale", tempItem.text);
                            }else if(tempItem.fieldVal == "region"){
                                setValue(prefixSaveRestore + ".address.region", tempItem.text);
                            }else if(tempItem.fieldVal == "zip"){
                                setValue(prefixSaveRestore + ".address.zip", tempItem.text);
                            }else if(tempItem.fieldVal == "country"){
                                setValue(prefixSaveRestore + ".address.country", tempItem.text);
                            }
                        }
                    }
                }

                setValue(prefixSaveRestore + ".address.typeIndex", addressComboBox.selectedIndex);

            }

            sync()
        }
    }

    function restoreData() {
        if(srsAddress.restoreRequired && !updateMode){
            var restoredAddress = srsAddress.restoreOnce(prefixSaveRestore + ".address.street", streetAddress);
            var restoredLocale  = srsAddress.restoreOnce(prefixSaveRestore + ".address.locale", localeAddress);
            var restoredRegion  = srsAddress.restoreOnce(prefixSaveRestore + ".address.region", regionAddress);
            var restoredZip     = srsAddress.restoreOnce(prefixSaveRestore + ".address.zip", postcodeAddress);
            var restoredCountry = srsAddress.restoreOnce(prefixSaveRestore + ".address.country", countryAddress);

            if(addressFieldRepeater){
                for(var i = 0; i < addressFieldRepeater.itemCount; i++){
                    var tempItem = addressFieldRepeater.itemList[i]
                    if(tempItem){
                        if(tempItem.fieldVal == "street"){
                            tempItem.text = restoredAddress
                        }else if(tempItem.fieldVal == "locale"){
                            tempItem.text = restoredLocale
                        }else if(tempItem.fieldVal == "region"){
                            tempItem.text = restoredRegion
                        }else if(tempItem.fieldVal == "zip"){
                            tempItem.text = restoredZip
                        }else if(tempItem.fieldVal == "country"){
                            tempItem.text = restoredCountry
                        }
                    }
                }
            }

            restoredAddressTypeIndex        = srsAddress.restoreOnce(prefixSaveRestore + ".address.typeIndex", -1);
            addressComboBox.title           = (restoredAddressTypeIndex != -1 ? addressComboBox.model[restoredAddressTypeIndex] : contextHome)
            addressComboBox.selectedIndex   = (restoredAddressTypeIndex != -1 ? restoredAddressTypeIndex : 0)
        }
    }



    function parseDetailsModel(existingDetailsModel, contextModel) {
        var fieldOrder = localeUtils.getAddressFieldOrder();
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++) {
            var splitAddy = existingDetailsModel[i].split("\n");
            var arr2 = {};
            for (var k = 0; k < fieldOrder.length; k++) {
                var field = fieldOrder[k];
                arr2[field] = splitAddy[k];
            }
            arr2["type"] = contextModel[i];
            arr.push(arr2);
        }

        return arr;
    }

    function getNewDetailValues() {
        var streetList = new Array();
        var localeList = new Array();
        var regionList = new Array();
        var zipList = new Array();
        var countryList = new Array();
        var addressTypeList = new Array();
        var count = 0;

        for (var i = 0; i < newDetailsModel.count; i++) {
            if (newDetailsModel.get(i).street != "" ||
                newDetailsModel.get(i).street2 != "" ||
                newDetailsModel.get(i).locale != "" ||
                newDetailsModel.get(i).region != "" ||
                newDetailsModel.get(i).zip != ""  ||
                newDetailsModel.get(i).country != "") {
                streetList[count] = newDetailsModel.get(i).street + "\n"
                                    + newDetailsModel.get(i).street2;
                localeList[count] = newDetailsModel.get(i).locale;
                regionList[count] = newDetailsModel.get(i).region;
                zipList[count] = newDetailsModel.get(i).zip;
                countryList[count] = newDetailsModel.get(i).country;
                addressTypeList[count] = newDetailsModel.get(i).type;
                count = count + 1;
            }
        }

        return {"streets": streetList, "locales": localeList,
                "regions": regionList, "zips": zipList,
                "countries": countryList, "types": addressTypeList};
    }

    function getDetails(reset) {
        var data = new Array();
        for (var i = 0; i < addressColumn.children.length - 1; i++) {
            var key = addressColumn.children[i].fieldVal;
            data[key] = addressColumn.children[i].text;
        }
 
        var arr = {"street": data["street"], 
                   "street2": data["street2"],
                   "locale": data["locale"], 
                   "region": data["region"],
                   "zip": data["zip"], 
                   "country": data["country"], 
                   "type": addressComboBox.model[addressComboBox.selectedIndex]};

        if (reset)
            resetFields();

        return arr;
    }

    function resetFields() {
        for (var i = 0; i < addressColumn.children.length - 1; i++)
            addressColumn.children[i].text = "";

       addressComboBox.selectedIndex = 0;
    }

    ListModel {
        id: addressFields
        Component.onCompleted: {
            var pairs = {"street": streetAddress,
                         "street2": streetAddress,
                         "locale": localeAddress,
                         "region": regionAddress,
                         "zip": postcodeAddress,
                         "country": countryAddress};

            var fieldOrder = localeUtils.getAddressFieldOrder();
            for (var i = 0; i < fieldOrder.length; i++) {
                var field = fieldOrder[i];
                addressFields.append({"field": field, "dText": pairs[field]});
            }
        }
    }

    function getTextValue(field) {
        switch(field) {
            case "street":
                return newDetailsModel.get(rIndex).street;
            case "street2":
                return newDetailsModel.get(rIndex).street2;
            case "locale":
                return newDetailsModel.get(rIndex).locale;
            case "region":
                return newDetailsModel.get(rIndex).region;
            case "zip":
                return newDetailsModel.get(rIndex).zip;
            case "country":
                return newDetailsModel.get(rIndex).country;
            default:
                return ""
        }

        return ""
    }

    function getIndexVal(type) {
        if (updateMode) {
            for (var i = 0; i < addressComboBox.model.length; i++) {
                if (addressComboBox.model[i] == newDetailsModel.get(rIndex).type)
                    return i;
            }
        }
        return 0;
    }

    function updateDisplayedData(){
        if(updateMode){
            addressComboBox.title           = (updateMode) ? newDetailsModel.get(rIndex).type : contextHome
            addressComboBox.selectedIndex   = (updateMode) ? getIndexVal(newDetailsModel.get(rIndex).type) : 0

            if(addressFieldRepeater){
                for(var i = 0; i < addressFieldRepeater.itemCount; i++){
                    var tempItem = addressFieldRepeater.itemList[i]
                    if(tempItem){
                        if(tempItem.fieldVal == "street"){
                            tempItem.text = newDetailsModel.get(rIndex).street
                        }else if(tempItem.fieldVal == "locale"){
                            tempItem.text = newDetailsModel.get(rIndex).locale
                        }else if(tempItem.fieldVal == "region"){
                            tempItem.text = newDetailsModel.get(rIndex).region
                        }else if(tempItem.fieldVal == "zip"){
                            tempItem.text = newDetailsModel.get(rIndex).zip
                        }else if(tempItem.fieldVal == "country"){
                            tempItem.text = newDetailsModel.get(rIndex).country
                        }
                    }
                }
            }
        }
    }

    DropDown {
        id: addressComboBox

        anchors {left: parent.left; leftMargin: 10;}
        titleColor: theme_fontColorNormal

        width: 250
        minWidth: width
        maxWidth: width + 50

        model: [contextHome, contextWork, contextOther]

        title: (updateMode) ? newDetailsModel.get(rIndex).type : contextHome
        selectedIndex: (updateMode) ? getIndexVal(newDetailsModel.get(rIndex).type) : 0
        replaceDropDownTitle: true
    }

    Column {
        id: addressColumn
        spacing: 10
        anchors {left: addressComboBox.right; right: parent.right;
                 leftMargin: 10}
        width: parent.width - addressComboBox.width
        height: childrenRect.height

        Repeater {
            id: addressFieldRepeater

            width: parent.width
            height: childrenRect.height

            model: addressFields

            property bool validData: false

            property int itemCount
            property variant itemList: []

            delegate: TextEntry {
                id: addressTextField
                text: (updateMode) ? getTextValue(field) : ""
                defaultText: dText
                width: 400
                parent: addressFieldRepeater

                property string fieldVal: field

                Component.onCompleted : {
                    addressFieldRepeater.itemCount += 1;
                    var items = addressFieldRepeater.itemList;
                    items.push(addressTextField);
                    addressFieldRepeater.itemList = items;
                }

                Binding {target: addressFieldRepeater; property: "validData";
                         value: true; when: (text != "")}
                Binding {target: addressFieldRepeater; property: "validData";
                         value: false; when: (text == "")}
            }
        }
    }

    Binding {target: addressRect; property: "validInput"; value: true;
             when: (addressFieldRepeater.validData == true)
            }

    Binding {target: addressRect; property: "validInput"; value: false;
             when: (addressFieldRepeater.validData == false)
            }
}

