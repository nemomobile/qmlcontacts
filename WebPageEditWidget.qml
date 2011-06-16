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
    width:  parent.width

    property variant newDetailsModel: null 
    property int rIndex: -1
    property bool updateMode: false 
    property bool validInput: false 

    property string defaultWeb : qsTr("Site")
    property string bookmarkWeb : qsTr("Bookmark", "Noun")
    property string favoriteWeb : qsTr("Favorite", "Noun")

    SaveRestoreState {
        id: srsWebPage
        onSaveRequired: {
            if(newDetailsModel != null){
                if(newDetailsModel.count > 0){
                    setValue("web.count", newDetailsModel.count)
                    for (var i = 0; i < newDetailsModel.count; i++){
                        setValue("web.address" + i, newDetailsModel.get(i).web)
                        setValue("web.type" + i, newDetailsModel.get(i).type)
                    }
                }
            }
            sync()
        }
    }

    Component.onCompleted: {
        if (srsWebPage.restoreRequired) {
            var webCount = srsWebPage.value("web.count", 0)
            if(webCount > 0){
                for(var i = 0; i < webCount; i++){
                    newDetailsModel.set(i, {"web": srsWebPage.restoreOnce("web.address" + i, "")})
                    newDetailsModel.set(i, {"type": srsWebPage.restoreOnce("web.type" + i, "")})
                }
            }
        }
    }

    function parseDetailsModel(existingDetailsModel, contextModel) {
        var arr = new Array(); 
        for (var i = 0; i < existingDetailsModel.length; i++)
            arr[i] = {"web": existingDetailsModel[i], "type": contextModel[i]};

        return arr;
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

        anchors {left: parent.left; leftMargin: 10;}
        titleColor: theme_fontColorNormal

        width: 250
        minWidth: width
        maxWidth: width + 50

        model: [favoriteWeb, bookmarkWeb]

        title: (updateMode) ? newDetailsModel.get(rIndex).type : bookmarkWeb 
        selectedIndex: (updateMode) ? getIndexVal(newDetailsModel.get(rIndex).type) : 1
        replaceDropDownTitle: true
    }

    TextEntry {
        id: data_url
        text: (updateMode) ? newDetailsModel.get(rIndex).web : ""
        defaultText: defaultWeb
        width: 400
        anchors {left:urlComboBox.right; leftMargin: 10;}
        inputMethodHints: Qt.ImhUrlCharactersOnly
    }

    Binding {target: webRect; property: "validInput"; value: true;
             when: (data_url.text != "")
            }

    Binding {target: webRect; property: "validInput"; value: false;
             when: (data_url.text == "")
            }
}

