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

    property string homeContext: qsTr("Home")
    property string workContext: qsTr("Work")
    property string otherContext: qsTr("Other")
    property string streetAddress: qsTr("Street address")
    property string localeAddress: qsTr("Town / City")
    property string regionAddress: qsTr("Region / State")
    property string countryAddress:  qsTr("Country")
    property string postcodeAddress:  qsTr("Postcode / Zip")

    function parseDetailsModel(existingDetailsModel, contextModel) {
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++) {
            var splitAddy = existingDetailsModel[i].split("\n");
            if (splitAddy.length == 5) //REVISIT: magic number, 5 elements?
                arr[i] = {"street": splitAddy[0], 
                          "locale": splitAddy[1], 
                          "region": splitAddy[2], 
                          "zip": splitAddy[3], 
                          "country": splitAddy[4], 
                          "type": contextModel[i]};
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
            if (newDetailsModel.get(i).street != "" || newDetailsModel.get(i).locale != "" 
                || newDetailsModel.get(i).region != "" || newDetailsModel.get(i).zip != "" 
                || newDetailsModel.get(i).country != "") {
                streetList[count] = newDetailsModel.get(i).street;
                localeList[count] = newDetailsModel.get(i).locale;
                regionList[count] = newDetailsModel.get(i).region;
                zipList[count] = newDetailsModel.get(i).zip;
                countryList[count] = newDetailsModel.get(i).country;
                addressTypeList[count] = newDetailsModel.get(i).type;
                count = count + 1;
            }
        }

        return {"streets": streetList, "locales": localeList, "regions": regionList, 
                "zips": zipList, "countries": countryList, "types": addressTypeList};
    }

    function getDetails(reset) {
        var arr = {"street": data_street.text, 
                   "locale": data_locale.text, 
                   "region": data_region.text,
                   "zip": data_zip.text, 
                   "country": data_country.text, 
                   "type": addressComboBox.selectedTitle};
       
        if (reset)
            resetFields();

        return arr;
    }

    function resetFields() {
       data_street.text = "";
       data_locale.text = "";
       data_region.text = "";
       data_zip.text = "";
       data_country.text = "";
       addressComboBox.selectedTitle = contextHome;
    }

    DropDown {
        id: addressComboBox

        anchors {left: parent.left; leftMargin: 10;}
        titleColor: theme_fontColorNormal

        width: 250
        minWidth: width
        maxWidth: width + 50

        model: [contextHome, contextWork, contextOther]

        state: "notInUpdateMode"

        states: [
            State {
                name: "inUpdateMode"; when: (addressRect.updateMode == true)
                PropertyChanges{target: addressComboBox; title: newDetailsModel.get(rIndex).type}
                PropertyChanges{target: addressComboBox; selectedTitle: newDetailsModel.get(rIndex).type}
            },
            State {
                name: "notInUpdateMode"; when: (addressRect.updateMode == false)
                PropertyChanges{target: addressComboBox; title: contextHome}
                PropertyChanges{target: addressComboBox; selectedTitle: contextHome}
            }
        ]
    }

    TextEntry {
        id: data_street
        text: (updateMode) ? newDetailsModel.get(rIndex).street : ""
        defaultText: streetAddress
        width: 400
        anchors {left:addressComboBox.right; leftMargin: 10;}
    }
    TextEntry {
        id: data_locale
        text: (updateMode) ? newDetailsModel.get(rIndex).locale : ""
        defaultText: localeAddress
        width: 400
        anchors {top: data_street.bottom; topMargin: 20; left:addressComboBox.right; leftMargin: 10;}
    }
    TextEntry {
        id: data_region
        text: (updateMode) ? newDetailsModel.get(rIndex).region : ""
        defaultText: regionAddress
        width: 400
        anchors {top: data_locale.bottom; topMargin: 20; left:addressComboBox.right; leftMargin: 10;}
    }
    TextEntry {
        id: data_zip
        text: (updateMode) ? newDetailsModel.get(rIndex).zip : ""
        defaultText: postcodeAddress
        width: 400
        anchors {top: data_region.bottom; topMargin: 20; left:addressComboBox.right; leftMargin: 10;}
    }
    TextEntry {
        id: data_country
        text: (updateMode) ? newDetailsModel.get(rIndex).country : ""
        defaultText: countryAddress
        width: 400
        anchors {top: data_zip.bottom; topMargin: 20; left:addressComboBox.right; leftMargin: 10;}
    }//textentry
}

