/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Column {
    id: detailsColumn
    spacing: 1
    anchors {left:parent.left; right: parent.right; }

    property int initialHeight: childrenRect.height
    property bool validInput: false
    property int itemMargins: 3

    property string headerLabel
    property string expandingBoxTitle
    property Component newDetailsComponent: null
    property Component existingDetailsComponent: null

    property string addLabel: qsTr("Add")
    property string cancelLabel: qsTr("Cancel")

    function loadExpandingBox(detailData, contextData) {
        expandingLoader.sourceComponent = expandingComponent;

        if (detailData == null)
            return;

        var newFieldItem = existingDetailsComponent.createObject(detailsColumn);
        var tmpArr = newFieldItem.parseDetailsModel(detailData, contextData);
        var tmpFields = newFieldItem.getInitFields();

        for (var i = 0; i < tmpArr.length; i++) {
            detailsModel.append(tmpFields);
            for (var key in tmpArr[i])
                detailsModel.setProperty(i, key, tmpArr[i][key]);
        }
        newFieldItem.destroy();
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

    function appendIntoDetailsModel(){
        var newFieldItem = existingDetailsComponent.createObject(detailsColumn);
        var tmpFields = newFieldItem.getInitFields();
        detailsModel.append(tmpFields);
        newFieldItem.destroy();
    }

    ListModel{
        id: detailsModel 
    }

    Item {
        id: detailsHeader
        width: parent.width
        height: 70
        opacity: 1

        Label {
            id: label_details
            text: headerLabel
            smooth: true
            anchors {bottom: detailsHeader.bottom; bottomMargin: itemMargins;
                     left: detailsHeader.left; leftMargin: 30}
        }
    }

    Repeater {
        id: detailsRepeater

        model: detailsModel
        width: parent.width
        opacity: 1
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
                    oldDLoader.item.parent = imageBar;

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
                source: "image://themedimage/icons/internal/contact-information-delete"
                width: 36
                height: 36
                anchors {top: parent.top; right: parent.right;
                         margins: itemMargins;}
                opacity: 1
                MouseArea {
                    id: mouse_delete
                    anchors.fill: parent
                    onPressed: {
                        delete_button.source = "image://themedimage/icons/internal/contact-information-delete-active"
                    }
                    onClicked: {
                        if (detailsRepeater.count == 1) {
                            oldDLoader.item.resetFields();
                        } 
                        else if (detailsRepeater.count != 1) {
                            removeItemFromList(index);
                            detailsRepeater.model.remove(index);

                            //REVISIT: Should use states for this
                            detailsColumn.height -= oldDLoader.item.height
                        }

                        delete_button.source = "image://themedimage/icons/internal/contact-information-delete"
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

// TODO            property alias expanded: detailsBox.expanded
            property bool expanded: true

            Rectangle {
                id: detailsBox

                property int boxHeight

                parent: addBar
                anchors {top: parent.top; right: parent.right;
                         left: parent.left; leftMargin: itemMargins}
 
/*
 * TODO: this needs to be figured out
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
                    Label {
                        id: text_box
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: add_button.right
                        anchors.leftMargin: 10
                        text: expandingBoxTitle
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
*/
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

                height: 36
                text: addLabel
                anchors {right: cancelButton.left; rightMargin: itemMargins;
                         top: newDLoader.bottom; topMargin: itemMargins;}
                enabled: (newDLoader.item) ? newDLoader.item.validInput : false
                onClicked: {
                    expandingLoader.item.expanded = false;
                    var arr = newDLoader.item.getDetails(true);
                    appendIntoDetailsModel()
                    for (var key in arr)
                        detailsModel.setProperty(detailsModel.count - 1, key, arr[key]);
                }
            }

            Button {
                id: cancelButton

                height: 36
                text: cancelLabel
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

