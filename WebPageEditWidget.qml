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
    id: webRect
    height: childrenRect.height
    width: parent.width

    property variant newDetailsModel: null 
    property int rIndex: -1
    property bool updateMode: false 
    property bool validInput: false 
    property int itemMargins: 10

    property string defaultWeb : qsTr("Site")
    property string bookmarkWeb : qsTr("Bookmark", "Noun")
    property string favoriteWeb : qsTr("Favorite", "Noun")

    function parseDetailsModel(existingDetailsModel, contextModel) {
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++)
            arr[i] = {"web": existingDetailsModel[i], "type": contextModel[i]};

        return arr;
    }

    function getInitFields() {
        return {"web" : "", "type" : ""};
    }

    function getNewDetailValues() {
        var webUrlList = new Array();
        var webTypeList = new Array();
        var count = 0;

        for (var i = 0; i < newDetailsModel.count; i++) {
            if (newDetailsModel.get(i).web != "") {
                webUrlList[count] = newDetailsModel.get(i).web;
                webTypeList[count] = newDetailsModel.get(i).type;
                count = count + 1;
            }
        }
        return {"urls": webUrlList, "types": webTypeList};
    }

    function getDetails(reset) {
        var arr = {"web": data_url.text, 
                   "type": urlComboBox.model[urlComboBox.selectedIndex]};

        if (reset)
            resetFields();

        return arr;
    }

    function resetFields() {
       data_url.text = "";
       urlComboBox.selectedIndex = 0;
    }

    function getIndexVal(type) {
        if (updateMode) {
            for (var i = 0; i < urlComboBox.model.length; i++) {
                if (urlComboBox.model[i] == newDetailsModel.get(rIndex).type)
                    return i;
            }
        }
        return 0;
    }

    DropDown {
        id: urlComboBox

        property int marginTotal: 4*anchors.leftMargin

        anchors {left: parent.left; leftMargin: itemMargins;}
        titleColor: theme_fontColorNormal

        width: Math.round(parent.width/2) - marginTotal
        maxWidth: (width > 0) ? width : Math.round(window.width/2) - marginTotal

        model: [favoriteWeb, bookmarkWeb]

        title: (updateMode) ? newDetailsModel.get(rIndex).type : bookmarkWeb
        selectedIndex: (updateMode) ? getIndexVal(newDetailsModel.get(rIndex).type) : 1
        replaceDropDownTitle: true
    }

    TextEntry {
        id: data_url
        text: (updateMode) ? newDetailsModel.get(rIndex).web : ""
        defaultText: defaultWeb
        width: Math.round(parent.width/2) - 4*anchors.leftMargin
        anchors {left:urlComboBox.right; leftMargin: itemMargins;}
        inputMethodHints: Qt.ImhUrlCharactersOnly
    }

    Binding {target: webRect; property: "validInput"; value: true;
             when: (data_url.text != "")
            }

    Binding {target: webRect; property: "validInput"; value: false;
             when: (data_url.text == "")
            }
}

