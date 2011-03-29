/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

Item{
    id: phonesRect
    height: childrenRect.height
    width:  parent.width

    property int initialHeight: childrenRect.height

    property variant phoneModel: contactModel
    property variant contextModel : typeModel
    property bool    validInput   : false

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

    function getNewPhones() {
        var phoneNumList = new Array();
        var phoneTypeList = new Array();
        var count = 0;
        for (var i = 0; i < phones.count; i++) {
            if (phones.get(i).phone != "") {
                phoneNumList[count] = phones.get(i).phone;
                phoneTypeList[count] = phones.get(i).type;
                count = count + 1;
            }
        }
        return {"numbers": phoneNumList, "types": phoneTypeList};
    }

    ListModel{
        id: phones
        Component.onCompleted:{
            for(var i =0; i < phoneModel.length; i++)
                phones.append({"phone": phoneModel[i], "type": contextModel[i]});
        }
    }

    Column{
        spacing: 1
        anchors {left:parent.left; right: parent.right;}

        Item {
            id: phoneHeader
            width: parent.width
            height: 70
            opacity: 1

            Text{
                id: label_phone
                text: phoneHeaderLabel
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorInactive
                smooth: true
                anchors {bottom: phoneHeader.bottom; bottomMargin: 10; left: phoneHeader.left; leftMargin: 30}
            }
        }

        Repeater{
            model: phones
            width: parent.width
            height: childrenRect.height
            opacity: (phoneModel.length > 0 ? 1  : 0)
            delegate: Item {
                id: itemDelegate
                height: 80;
                signal clicked()

                //Need to store the repeater index, as the drop down overwrites index with its own value
                property int repeaterIndex: index
                Image{
                    id: phoneBar
                    source: "image://theme/contacts/active_row"
                    anchors.fill:  parent

                    DropDown {
                        id: phoneComboBox
                        height: 60
                        delegateComponent: stringDelegate

                        anchors {verticalCenter: phoneBar.verticalCenter; left: phoneBar.left; leftMargin: 10}
                        width: 150

                        selectedValue: type

                        dataList: [mobileContext, homeContext, workContext, otherContext]

                        Component {
                            id: stringDelegate
                            Text {
                                id: listVal
                                property variant data
                                x: 15
                                text: "<b>" + data + "</b>"
                            }
                        }
                        onSelectionChanged: {
                            phones.setProperty(repeaterIndex, "type", data);
                        }
                    }

                    TextEntry{
                        id: data_phone
                        text: phone
                        defaultText: defaultPhone
                        width: 400
                        anchors {verticalCenter: parent.verticalCenter; left:phoneComboBox.right; leftMargin: 10; right: delete_button.left; rightMargin: 10}
                        inputMethodHints: Qt.ImhDialableCharactersOnly
                        onTextChanged: {
                            phones.setProperty(index, "phone", data_phone.text);
                        }
                    }
                    Binding{ target: phonesRect; property: "validInput"; value: true; when: data_phone.text != "";}
                    Binding{ target: phonesRect; property: "validInput"; value: false; when: data_phone.text == "";}

                    Image {
                        id: delete_button
                        source: "image://theme/contacts/icn_trash"
                        width: 36
                        height: 36
                        anchors {verticalCenter: data_phone.verticalCenter; right:parent.right; rightMargin: 20}
                        opacity: 1
                        MouseArea{
                            id: mouse_delete_phone
                            anchors.fill: parent
                            onPressed: {
                                delete_button.source = "image://theme/contacts/icn_trash_dn";
                            }
                            onClicked: {
                                if(phones.count != 1 ){
                                    phones.remove(index);
                                    phonesRect.height = phonesRect.height-itemDelegate.height;
                                }else{
                                    data_phone.text = "";
                                    phoneComboBox.selectedValue = mobileContext;
                                }
                                delete_button.source = "image://theme/contacts/icn_trash";
                            }
                        }
                        Binding{target: delete_button; property: "visible"; value: false; when: phones.count < 2}
                        Binding{target: delete_button; property: "visible"; value: true; when: phones.count > 1}
                    }
                }
            }
        }

        Item {
            id: addFooter
            width: parent.width
            height: 80
            Image{
                id: addBar
                source: "image://theme/contacts/active_row"
                anchors.fill:  parent
                anchors.bottomMargin: 1

                ExpandingBox {
                    Image {
                        id: add_button
                        source: "image://theme/contacts/icn_add"
                        anchors{ verticalCenter: phoneBox.verticalCenter; left: phoneBox.left; leftMargin: 20}
                        width: 36
                        height: 36
                        opacity: 1
                    }

                    id: phoneBox
                    detailsComponent: phoneComponent

                    expanded: false
                    width: parent.width
                    anchors{ verticalCenter: addBar.verticalCenter; top: addBar.top; leftMargin: 15;}
                    titleTextItem.text: addPhone
                    titleTextItem.color: theme_fontColorNormal
                    titleTextItem.anchors.leftMargin: add_button.width + add_button.anchors.leftMargin + phoneBox.anchors.leftMargin
                    titleTextItem.font.bold: true
                    titleTextItem.font.pixelSize: theme_fontPixelSizeLarge
                    pulldownImageSource: "image://theme/contacts/active_row"

                    expandedHeight: detailsItem.height + expandButton.height

                    onExpandedChanged: {
                        phonesRect.height = expanded ? (initialHeight + expandedHeight) : initialHeight;
                        add_button.source = expanded ? "image://theme/contacts/icn_add_dn" : "image://theme/contacts/icn_add";
                        pulldownImageSource = expanded ? "image://theme/contacts/active_row_dn" : "image://theme/contacts/active_row"
                    }

                    Component {
                        id: phoneComponent
                        Item {
                            id: phoneBar2
                            height: 100

                            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                                id: phoneComboBox2
                                height: 60
                                delegateComponent: stringDelegate2

                                anchors {left: phoneBar2.left; leftMargin: phoneBox.titleTextItem.anchors.leftMargin - phoneBox.anchors.leftMargin;}
                                width: 150

                                selectedValue: type

                                dataList: [mobileContext, homeContext, workContext, otherContext]

                                Component {
                                    id: stringDelegate2
                                    Text {
                                        id: listVal
                                        property variant data
                                        x: 15
                                        text: "<b>" + data + "</b>"
                                    }
                                }
                            }

                            TextEntry{
                                id: data_phone2
                                text: ""
                                defaultText: defaultPhone
                                width: 400
                                anchors {left:phoneComboBox2.right; leftMargin: 10;}
                            }

                            Button {
                                id: addButton
                                width: 100
                                height: 36
                                title: addLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                bgSourceUp: "image://theme/btn_blue_up"
                                bgSourceDn: "image://theme/btn_blue_dn"
                                anchors {right:cancelButton.left; top: data_phone2.bottom; topMargin: 15; rightMargin: 5;}
                                onClicked: {
                                    phones.append({"phone": data_phone2.text, "type": phoneComboBox2.dataList[phoneComboBox2.selectedIndex]});
                                    phoneBox.expanded = false;
                                    data_phone2.text = "";
                                    phoneComboBox2.selectedValue = mobileContext;
                                }
                            }

                            Button {
                                id: cancelButton
                                width: 100
                                height: 36
                                title: cancelLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                anchors {right:data_phone2.right; top: data_phone2.bottom; topMargin: 15;}
                                onClicked: {
                                    phoneBox.expanded = false;
                                    data_phone2.text = "";
                                    phoneComboBox2.selectedValue = mobileContext;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
