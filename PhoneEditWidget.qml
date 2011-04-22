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

    property int initialHeight: childrenRect.height

    property variant phoneModel: contactModel
    property variant contextModel : typeModel
    property bool    validInput   : false

    property alias detailsBoxExpanded: phoneDetailsItem.expanded

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

    ContactsExpandableDetails {
        id: phoneDetailsItem

        headerLabel: phoneHeaderLabel
        expandingBoxTitle: addPhone
        repeaterComponent: phoneExistingComponent

        detailsModel: phones 
        fieldDetailComponent: phoneNewComponent

        onDetailsBoxExpandingChanged: {
            phonesRect.height = expanded ? (initialHeight + newHeight) : initialHeight;
        }
    }

    Component {
        id: phoneExistingComponent

        Item {
            id: itemDelegate
            height: 80;
            width: parent.width
            signal clicked()

            //Need to store the repeater index, 
            // as the drop down overwrites index with its own value
            property int repeaterIndex: index
            Image{
                id: phoneBar
                source: "image://theme/contacts/active_row"
                anchors.fill:  parent

                DropDown {
                    id: phoneComboBox

                    anchors {verticalCenter: phoneBar.verticalCenter; 
                             left: phoneBar.left; leftMargin: 10}
                    title: phones.get(repeaterIndex).type
                    titleColor: theme_fontColorNormal
                    replaceDropDownTitle: true

                    width: 250
                    minWidth: width
                    maxWidth: width + 50

                    model: [mobileContext, homeContext, workContext, otherContext]
                    onTriggered: {
                        phones.setProperty(repeaterIndex, "type", data);
                    }
                }

                TextEntry {
                    id: data_phone
                    text: phone
                    defaultText: defaultPhone
                    width: 400
                    anchors {verticalCenter: parent.verticalCenter; 
                             left:phoneComboBox.right; leftMargin: 10; 
                             right: delete_button.left; rightMargin: 10}
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
                    anchors {verticalCenter: data_phone.verticalCenter; 
                             right:parent.right; rightMargin: 20}
                    opacity: 1
                    MouseArea {
                        id: mouse_delete_phone
                        anchors.fill: parent
                        onPressed: {
                            delete_button.source = "image://theme/contacts/icn_trash_dn";
                        }
                        onClicked: {
                            if (phones.count != 1) {
                                phones.remove(index);
                                if (phonesRect.height > initialHeight)
                                    phonesRect.height = phonesRect.height-itemDelegate.height;

                            } else {
                                data_phone.text = "";
                                phoneComboBox.selectedTitle = mobileContext;
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

    Component {
        id: phoneNewComponent

        Item {
            id: phoneBar2
            height: 100

            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                id: phoneComboBox2

                anchors {left: phoneBar2.left; leftMargin: 10;}
                title: mobileContext
                titleColor: theme_fontColorNormal
                replaceDropDownTitle: true

                width: 250
                minWidth: width
                maxWidth: width + 50

                model: [mobileContext, homeContext, workContext, otherContext]
            }

            TextEntry {
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
                text: addLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                bgSourceUp: "image://theme/btn_blue_up"
                bgSourceDn: "image://theme/btn_blue_dn"
                anchors {right:cancelButton.left; top: data_phone2.bottom; 
                         topMargin: 15; rightMargin: 5;}
                onClicked: {
                    phones.append({"phone": data_phone2.text, 
                                   "type": phoneComboBox2.selectedTitle});
                    detailsBoxExpanded = false;
                    data_phone2.text = "";
                    phoneComboBox2.selectedTitle = mobileContext;
                }
            }

            Button {
                id: cancelButton
                width: 100
                height: 36
                text: cancelLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                anchors {right:data_phone2.right; top: data_phone2.bottom; 
                         topMargin: 15;}
                onClicked: {
                    detailsBoxExpanded = false;
                    data_phone2.text = "";
                    phoneComboBox2.selectedTitle = mobileContext;
                }
            }
        }
    }
}
