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

    property bool canSave: false

    SaveRestoreState {
        id: srsWebPage
        onSaveRequired: {
            if(!updateMode && webRect.canSave){
                // Save the phone number that is currently being edited
                var pageTitle = window.pageStack.currentPage.pageTitle;
                setValue(pageTitle + ".web.address", data_url.text)
                setValue(pageTitle + ".web.typeIndex", urlComboBox.selectedIndex)
            }

            sync()
        }
    }

    function restoreData() {
        if(srsWebPage.restoreRequired && !updateMode){
            var pageTitle = window.pageStack.currentPage.pageTitle;
            var restoredWeb = srsWebPage.restoreOnce(pageTitle + ".web.address", "")
            var index = srsWebPage.restoreOnce(pageTitle + ".web.typeIndex", -1)

            data_url.text = restoredWeb;

            if (index != -1) {
                urlComboBox.title = urlComboBox.model[index];
                urlComboBox.selectedIndex = index;
            }
            else {
                urlComboBox.title = bookmarkWeb;
                urlComboBox.selectedIndex = 0;
            }
        }

        webRect.canSave = true
    }


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

    function updateDisplayedData() {
        if (updateMode) {
            urlComboBox.title = newDetailsModel.get(rIndex).type;
            urlComboBox.selectedIndex = getIndexVal(newDetailsModel.get(rIndex).type);
        }
    }

    DropDown {
        id: urlComboBox

        anchors {left: parent.left; leftMargin: itemMargins;}
        titleColor: theme_fontColorNormal

        width: Math.round(parent.width/2) - 4*anchors.leftMargin
        minWidth: width
        maxWidth: width

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

