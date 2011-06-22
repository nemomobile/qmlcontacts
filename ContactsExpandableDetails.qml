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

Column {
    id: detailsColumn
    spacing: 1
    anchors {left:parent.left; right: parent.right; }

    property int initialHeight: childrenRect.height
    property bool validInput: false
    property int itemMargins: 10

    property variant existingDetailsModel: null
    property variant contextModel: null

    property string headerLabel
    property string expandingBoxTitle
    property Component newDetailsComponent: null
    property Component existingDetailsComponent: null

    property string addLabel: qsTr("Add")
    property string cancelLabel: qsTr("Cancel")

    property alias expanded: detailsBox.expanded
    property alias itemCount: detailsRepeater.itemCount
    property alias repeaterItemList: detailsRepeater.itemList

    property bool initializedData: false
    property string parentTitle: detailsColumn.parent.parent.parent.parentTitle
    property string prefixSaveRestore: detailsColumn.parent.parent.parent.parentTitle + "." + headerLabel + ".expandableDetails"

    SaveRestoreState {
        id: srsExpandableDetails
        onSaveRequired: {

            var canSave = true
            if(!initializedData)
                canSave = srsExpandableDetails.value(prefixSaveRestore + ".valid", true);

            if(initializedData && canSave){
                // Header
                var detailId = headerLabel + "."

                setValue(prefixSaveRestore + ".expanded", expanded)
                setValue(prefixSaveRestore + ".itemCount", detailsRepeater.itemCount)

                // Repeater data
                if(detailsRepeater.model.count > 0){
                    var propIndex = 0;

                    for(var i = 0; i < detailsRepeater.count; i++){
                        var entryName = prefixSaveRestore + ".items." + i + "."

                        var arr = repeaterItemList[i].getDetails(false);
                        propIndex = 0;
                        for (var key in arr){
                            var keyName     = entryName + "property." + propIndex + ".name";
                            var keyValue    = entryName + "property." + propIndex + ".value";

                            setValue(keyName, key)
                            setValue(keyValue, arr[key])
                            propIndex++
                        }
                    }

                    setValue(prefixSaveRestore + ".items.property.count", propIndex)
                }
            }

            sync()
        }
    }

    Component.onCompleted: {
        if(srsExpandableDetails.restoreRequired){
            expanded = srsExpandableDetails.restoreOnce(prefixSaveRestore + ".expanded", false)
        }
	}

    function loadExpandingBox() {
        expandingLoader.sourceComponent = expandingComponent;
    }

    function getNewDetails() {
        if (detailsRepeater.itemCount <= 0)
            return [""];

        for (var i = 0; i < detailsRepeater.itemCount; i++) {
            var arr = detailsRepeater.itemList[i].getDetails(false);
            for (var key in arr)
                detailsModel.setProperty(i, key, arr[key]);
        }

        //We only need to query the first one because each child
        //has red only access to the full model
        return detailsRepeater.itemList[0].getNewDetailValues();
    }

    function removeItemFromList (index) {
        var items = detailsRepeater.itemList;
        var results = items.splice(index, 1);
        detailsRepeater.itemList = items;
        detailsRepeater.itemCount -= 1;
    }

    function restoreData(){
        if(!initializedData){
            if(srsExpandableDetails.restoreRequired){

                // I. Restore data for the model items
                var detailId = headerLabel + "."
                var itemCount = srsExpandableDetails.value(prefixSaveRestore + ".itemCount", 0)

                if(itemCount > 0){
                    var entryNameHeader = prefixSaveRestore + ".items."
                    var propertyCount = srsExpandableDetails.restoreOnce(prefixSaveRestore + ".items.property.count", 0)

                    for(var i = 0; i < itemCount; i++){
                        var entryName = entryNameHeader + i + ".property."

                        appendIntoDetailsModel()

                        for(var j = 0; j < propertyCount; j++){
                            var key     = srsExpandableDetails.restoreOnce(entryName + j + ".name", "")
                            var value   = srsExpandableDetails.restoreOnce(entryName + j + ".value", "")

                            detailsModel.setProperty(i, key, value);
                        }

                        updateModelDisplayedData()
                    }
                }

                // II. Restore data in the newFieldItem
                if(newFieldItem)
                    newFieldItem.restoreData()

                srsExpandableDetails.setValue(prefixSaveRestore + ".valid", false);
                srsExpandableDetails.sync()
                initializedData = true
            }
        }
    }

    function appendIntoDetailsModel(){
        if(headerLabel == detailsColumn.parent.parent.parent.phoneLabel){
            detailsModel.append({"phone" : "", "type" : ""})
        }else if(headerLabel == detailsColumn.parent.parent.parent.addressLabel){
            detailsModel.append({"street" : "", "locale" : "", "region" : "", "zip" : "", "country" : "", "type" : ""})
        }else if(headerLabel == detailsColumn.parent.parent.parent.imLabel){
            detailsModel.append({"im" : "", "account" : "", "type" : ""})
        }else if(headerLabel == detailsColumn.parent.parent.parent.emailLabel){
            detailsModel.append({"email" : "", "type" : ""})
        }else if(headerLabel == detailsColumn.parent.parent.parent.urlLabel){
            detailsModel.append({"web" : "", "type" : ""})
        }
    }

    function updateModelDisplayedData(){
        if( headerLabel == detailsColumn.parent.parent.parent.phoneLabel
            || headerLabel == detailsColumn.parent.parent.parent.emailLabel
            || headerLabel == detailsColumn.parent.parent.parent.addressLabel){
            if(detailsRepeater){
                if(detailsRepeater.itemCount > 0)
                    detailsRepeater.itemList[detailsRepeater.itemCount - 1].updateDisplayedData()
            }
        }
    }

    ListModel{
        id: detailsModel 
        Component.onCompleted:{
            if ((existingDetailsModel) && (existingDetailsModel != "")) {
                var newFieldItem = existingDetailsComponent.createObject(detailsColumn);
                var tmpArr = newFieldItem.parseDetailsModel(existingDetailsModel, contextModel);
                for (var i = 0; i < tmpArr.length; i++) {
                    appendIntoDetailsModel()
                    for (var key in tmpArr[i])
                         detailsModel.setProperty(i, key, tmpArr[i][key]);
                }
                newFieldItem.destroy();
            }
        }
    }

    Item {
        id: detailsHeader
        width: parent.width
        height: 70
        opacity: 1

        Text {
            id: label_details
            text: headerLabel
            color: theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
            styleColor: theme_fontColorInactive
            smooth: true
            anchors {bottom: detailsHeader.bottom; bottomMargin: itemMargins;
                     left: detailsHeader.left; leftMargin: 30}
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: false

        onTriggered: {
            restoreData()
        }
    }

    Repeater {
        id: detailsRepeater

        model: detailsModel
        width: parent.width
        opacity: (model.count > 0 ? 1  : 0)
        clip: true

        property int itemCount 
        property variant itemList: []

        delegate: Image {
            id: imageBar
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            parent: detailsRepeater
            width: parent.width

            Loader {
                id: oldDLoader

                anchors {top: parent.top; bottom: parent.bottom; 
                         margins: itemMargins;}

                sourceComponent: existingDetailsComponent

                Component.onCompleted: {
                    oldDLoader.item.newDetailsModel = detailsRepeater.model;
                    oldDLoader.item.rIndex = index;
                    oldDLoader.item.updateMode = true;

                    //REVISIT: Better way to calculate? Use a state?
                    //We need to grow the parent based on the height
                    //of the children we're stuffing in
                    imageBar.height = oldDLoader.item.childrenRect.height
                                      + (itemMargins * 2);
                    detailsColumn.height += imageBar.height;

                    //REVISIT: We can replace this with the itemAt() Repeater
                    //function once its available - QtQuick 1.1
                    detailsRepeater.itemCount += 1;
                    var items = detailsRepeater.itemList;
                    items.push(oldDLoader.item);
                    detailsRepeater.itemList = items;
                }
            }
        
            Image {
                id: delete_button
                source: "image://themedimage/icon/internal/contact-information-delete"
                width: 36
                height: 36
                anchors {top: parent.top; right: parent.right;
                         margins: itemMargins;}
                opacity: 1
                MouseArea {
                    id: mouse_delete
                    anchors.fill: parent
                    onPressed: {
                        delete_button.source = "image://themedimage/icon/internal/contact-information-delete-active"
                    }
                    onClicked: {
                        if (detailsRepeater.count == 1) {
                            oldDLoader.item.resetFields();
                        } 
                        else if (detailsRepeater.count != 1) {
                            removeItemFromList(index);
                            detailsRepeater.model.remove(index);
                        }

                        delete_button.source = "image://themedimage/icon/internal/contact-information-delete"
                        //REVISIT: Should use states for this
                        detailsColumn.height -= oldDLoader.item.height
                    }
                }
                Binding{target: delete_button; property: "visible"; value: false; when: !oldDLoader.item.validInput}
                Binding{target: delete_button; property: "visible"; value: true; when: oldDLoader.item.validInput}
            }
        }
    }

    Binding {target: detailsColumn; property: "validInput"; value: true; when: detailsRepeater.count > 0}
    Binding {target: detailsColumn; property: "validInput"; value: false; when: detailsRepeater.count <= 0}

    Item {
        id: addFooter
        width: parent.width
        height: 80

        Image {
            id: addBar
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            anchors {fill: parent; bottomMargin: 1}

            Loader {
                id: expandingLoader
            }
        }
    }

    Component {
        id: expandingComponent 
        Item {
            id: expandingItem
            parent: addBar

            property alias expanded: detailsBox.expanded

            ExpandingBox {
                id: detailsBox

                property int boxHeight

                lazyCreation: true
                parent: addBar
                anchors {top: parent.top; right: parent.right;
                         left: parent.left; leftMargin: itemMargins}
 
                headerContent: Item {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.fill: parent

                    Image {
                        id: add_button
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: "image://themedimage/icons/internal/contact-information-add"
                    }
                    Text {
                        id: text_box
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: add_button.right
                        anchors.leftMargin: 10
                        text: expandingBoxTitle
                        font.pixelSize: theme_fontPixelSizeLarge
                    }
                }

                detailsComponent: fieldDetailComponent

                onExpandingChanged: {
                    if (expanded) {
                        add_button.source = "image://themedimage/icons/internal/contact-information-add-active"
                        detailsColumn.height = (initialHeight + detailsItem.height);
                    }

                    else {
                        add_button.source = "image://themedimage/icons/internal/contact-information-add";
                        detailsColumn.height = initialHeight;
                    }
                }
            }
        }
    }

    Component {
        id: fieldDetailComponent

        Item {
            id: fieldDetailItem
            height: childrenRect.height + itemMargins*2
            width: parent.width
            anchors {left:parent.left; top: parent.top; margins: itemMargins;}

            Loader {
                id: newDLoader

                height: childrenRect.height
                width: parent.width

                sourceComponent: newDetailsComponent

                Component.onCompleted: {
                    newDLoader.item.newDetailsModel = detailsModel;
                    newDLoader.item.rIndex = detailsModel.count;
                }
            }

            Button {
                id: addButton

                minWidth: 100
                maxWidth: Math.round(parent.width/3)
                height: 36
                text: addLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                bgSourceUp: "image://themedimage/widgets/common/button/button-default"
                bgSourceDn: "image://themedimage/widgets/common/button/button-default-pressed"
                anchors {right: cancelButton.left; rightMargin: itemMargins;
                         top: newDLoader.bottom; topMargin: itemMargins;}
                enabled: (newDLoader.item) ? newDLoader.item.validInput : false
                onClicked: {
                    expandingLoader.item.expanded = false;
                    var arr = newDLoader.item.getDetails(true);
                    appendIntoDetailsModel()
                    for (var key in arr)
                        detailsModel.setProperty(detailsModel.count - 1, key, arr[key]);

                    updateModelDisplayedData()
                }
            }

            Button {
                id: cancelButton

                minWidth: 100
                maxWidth: Math.round(parent.width/3)
                height: 36
                text: cancelLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                anchors {right: newDLoader.right; rightMargin: itemMargins;
                         top: newDLoader.bottom; topMargin: itemMargins;}
                onClicked: {
                    expandingLoader.item.expanded = false;
                    newDLoader.item.resetFields();
                }
            }
        }
    }
}

