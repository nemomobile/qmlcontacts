/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

Item {
    id: addressRect
    height: childrenRect.height
    width:  parent.width

    property int initialHeight: childrenRect.height

    property variant addressModel: contactModel
    property variant contextModel: typeModel
    property bool    validInput   : false

    property string addressLabel: qsTr("Address")
    property string homeContext: qsTr("Home")
    property string workContext: qsTr("Work")
    property string otherContext: qsTr("Other")
    property string streetAddress: qsTr("Street address")
    property string localeAddress: qsTr("Town / City")
    property string regionAddress: qsTr("Region / State")
    property string countryAddress:  qsTr("Country")
    property string postcodeAddress:  qsTr("Postcode / Zip")
    property string addAddress: qsTr("Add address")
    property string cancelLabel: qsTr("Cancel")
    property string addLabel: qsTr("Add")

    function getNewAddresses() {
        var streetList = new Array();
        var localeList = new Array();
        var regionList = new Array();
        var zipList = new Array();
        var countryList = new Array();
        var addressTypeList = new Array();
        var count = 0;

        for (var i = 0; i < addresss.count; i++) {
            if (addresss.get(i).street != "" || addresss.get(i).locale != "" || addresss.get(i).region != "" || addresss.get(i).zip != "" || addresss.get(i).country != "") {
                streetList[count] = addresss.get(i).street;
                localeList[count] = addresss.get(i).locale;
                regionList[count] = addresss.get(i).region;
                zipList[count] = addresss.get(i).zip;
                countryList[count] = addresss.get(i).country;
                addressTypeList[count] = addresss.get(i).type;
                count = count + 1;
            }
        }

        return {"streets": streetList, "locales": localeList, "regions": regionList, "zips": zipList, "countries": countryList, "types": addressTypeList};
    }

    ListModel{
        id: addresss
        Component.onCompleted:{
            for (var i =0; i < addressModel.length; i++) {
                var splitAddy = addressModel[i].split("\n");
                if (splitAddy.length == 5) //REVISIT: magic number, 5 elements?
                    addresss.append({"street": splitAddy[0], "locale": splitAddy[1], "region": splitAddy[2], "zip": splitAddy[3], "country": splitAddy[4], "type": contextModel[i]});
            }
        }
    }

    Column{
        spacing: 1
        anchors {left:parent.left; right: parent.right; }

        Item {
            id: addressHeader
            width: parent.width
            height: 70
            opacity:1

            Text{
                id: label_address
                text: addressLabel
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorNormal
                smooth: true
                anchors {bottom: addressHeader.bottom; bottomMargin: 10; left: addressHeader.left; leftMargin: 30}
            }
        }

        Repeater{
            model: addresss
            width: parent.width
            height: childrenRect.height
            opacity:  (addressModel.length > 0 ? 1  : 0)
            delegate: Item {
                id: itemDelegate
                height: 370
                width: parent.width
                signal clicked()

                //Need to store the repeater index, as the drop down overwrites index with its own value
                property int repeaterIndex: index
                Image{
                    id: addressBar
                    source: "image://theme/contacts/active_row"
                    anchors.fill:  parent

                    DropDown {
                        id: addressComboBox
                        height: 60
                        delegateComponent: stringDelegate
                        selectedIndex: 0

                        anchors {top: parent.top; topMargin: 20; left: addressBar.left; leftMargin: 10}
                        width: 150

                        selectedValue: type

                        dataList: [contextHome, contextWork, contextOther]

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
                            addresss.setProperty(repeaterIndex, "type", data);
                        }
                    }

                    Column{
                        spacing: 10
                        anchors.left:  parent.left
                        anchors.right:  parent.right
                        anchors.topMargin: 20
                        anchors.top:  parent.top
                        width: parent.width

                        TextEntry{
                            id: data_street
                            text: street
                            defaultText: streetAddress
                            width: 400
                            anchors {left:parent.left; leftMargin: 170; right: delete_button.left; rightMargin: 10}

                            onTextChanged: {
                                addresss.setProperty(index, "street", data_street.text);
                            }
                        }

                        TextEntry{
                            id: data_locale
                            text: locale
                            defaultText: localeAddress
                            width: 400
                            anchors {left:parent.left; leftMargin: 170; right: delete_button.left; rightMargin: 10}
                            onTextChanged: {
                                addresss.setProperty(index, "locale", data_locale.text);
                            }
                        }//textentry

                        TextEntry{
                            id: data_region
                            text: region
                            defaultText: regionAddress
                            width: 400
                            anchors { left:parent.left; leftMargin: 170; right: delete_button.left; rightMargin: 10}
                            onTextChanged: {
                                addresss.setProperty(index, "region", data_region.text);
                            }
                        }

                        TextEntry{
                            id: data_zip
                            text: zip
                            defaultText: postcodeAddress
                            width: 400
                            anchors {left:parent.left; leftMargin: 170; right: delete_button.left; rightMargin: 10}
                            onTextChanged: {
                                addresss.setProperty(index, "zip", data_zip.text);
                            }
                        }

                        TextEntry{
                            id: data_country
                            text: country
                            defaultText: countryAddress
                            width: 400
                            anchors { left:parent.left; leftMargin: 170; right: delete_button.left; rightMargin: 10}
                            onTextChanged: {
                                addresss.setProperty(index, "country", data_country.text);
                            }
                        }
                        Binding{ target: addressRect; property: "validInput"; value: true; when: ((data_street.text != "")||(data_locale.text != "")||(data_region.text != "")||(data_zip.text != "")||(data_country.text != ""))}
                        Binding{ target: addressRect; property: "validInput"; value: false; when: ((data_street.text == "")&&(data_locale.text == "")&&(data_region.text == "")&&(data_zip.text == "")&&(data_country.text == ""))}

                        Image {
                            id: delete_button
                            source: "image://theme/contacts/icn_trash"
                            width: 36
                            height: 36
                            anchors {right: parent.right;}
                            opacity: 1
                            MouseArea{
                                id: mouse_delete_address
                                anchors.fill: parent
                                onPressed: {
                                    delete_button.source = "image://theme/contacts/icn_trash_dn";
                                }
                                onClicked: {
                                    if(addresss.count != 1 ){
                                        addresss.remove(index);
                                        addressRect.height = addressRect.height-itemDelegate.height;
                                    }else{
                                        data_street.text = "";
                                        data_locale.text = "";
                                        data_region.text = "";
                                        data_zip.text = "";
                                        data_country.text = "";
                                        addressComboBox.selectedValue = contextHome;
                                    }
                                    delete_button.source = "image://theme/contacts/icn_trash";
                                }
                            }
                            Binding{target: delete_button; property: "visible"; value: false; when: addresss.count < 2}
                            Binding{target: delete_button; property: "visible"; value: true; when: addresss.count > 1}
                        }
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
                        anchors{ verticalCenter: addressBox.verticalCenter; left: addressBox.left; leftMargin: 20}
                        width: 36
                        height: 36
                        opacity: 1
                    }//button add

                    id: addressBox
                    detailsComponent: addressComponent

                    expanded: false
                    width: parent.width
                    anchors{ verticalCenter: addBar.verticalCenter; top: addBar.top; leftMargin: 15;}
                    titleTextItem.text: addAddress
                    titleTextItem.color: theme_fontColorNormal
                    titleTextItem.anchors.leftMargin: add_button.width + add_button.anchors.leftMargin + addressBox.anchors.leftMargin
                    titleTextItem.font.bold: true
                    titleTextItem.font.pixelSize: theme_fontPixelSizeLarge
                    pulldownImageSource: "image://theme/contacts/active_row"

                    expandedHeight: detailsItem.height + expandButton.height

                    onExpandedChanged: {
                        addressRect.height = expanded ? (initialHeight + expandedHeight) : initialHeight;
                        add_button.source = expanded ? "image://theme/contacts/icn_add_dn" : "image://theme/contacts/icn_add";
                        pulldownImageSource = expanded ? "image://theme/contacts/active_row_dn" : "image://theme/contacts/active_row"
                    }

                    Component {
                        id: addressComponent
                        Item {
                            id: addressBar2
                            height: 380
                            width: parent.width

                            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                                id: addressComboBox2
                                height: 60
                                delegateComponent: stringDelegate2

                                anchors {left: addressBar2.left; leftMargin: addressBox.titleTextItem.anchors.leftMargin - addressBox.anchors.leftMargin;}
                                width: 150

                                selectedValue: type

                                dataList: [contextHome, contextWork, contextOther]

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
                                id: data_street2
                                text: ""
                                defaultText: streetAddress
                                width: 400
                                anchors {left:addressComboBox2.right; leftMargin: 10;}
                            }
                            TextEntry{
                                id: data_locale2
                                text: ""
                                defaultText: localeAddress
                                width: 400
                                anchors {top: data_street2.bottom; topMargin: 20; left:addressComboBox2.right; leftMargin: 10;}
                            }
                            TextEntry{
                                id: data_region2
                                text: ""
                                defaultText: regionAddress
                                width: 400
                                anchors {top: data_locale2.bottom; topMargin: 20; left:addressComboBox2.right; leftMargin: 10;}
                            }
                            TextEntry{
                                id: data_zip2
                                text: ""
                                defaultText: postcodeAddress
                                width: 400
                                anchors {top: data_region2.bottom; topMargin: 20; left:addressComboBox2.right; leftMargin: 10;}
                            }
                            TextEntry{
                                id: data_country2
                                text: ""
                                defaultText: countryAddress
                                width: 400
                                anchors {top: data_zip2.bottom; topMargin: 20; left:addressComboBox2.right; leftMargin: 10;}
                            }//textentry

                            Button {
                                id: addButton
                                width: 100
                                height: 36
                                title: addLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                bgSourceUp: "image://theme/btn_blue_up"
                                bgSourceDn: "image://theme/btn_blue_dn"
                                anchors {right:cancelButton.left; top: data_country2.bottom; topMargin: 15; rightMargin: 5;}
                                onClicked: {
                                    addresss.append({"street": data_street2.text, "locale": data_locale2.text, "region": data_region2.text,
                                                    "zip": data_zip2.text, "country": data_country2.text, "type": addressComboBox2.dataList[addressComboBox2.selectedIndex]});
                                    addressBox.expanded = false;
                                    data_street2.text = "";
                                    data_locale2.text = "";
                                    data_region2.text = "";
                                    data_zip2.text = "";
                                    data_country2.text = "";
                                    addressComboBox2.selectedValue = contextHome;
                                }
                            }

                            Button {
                                id: cancelButton
                                width: 100
                                height: 36
                                title: cancelLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                anchors {right:data_country2.right; top: data_country2.bottom; topMargin: 15;}
                                onClicked: {
                                    addressBox.expanded = false;
                                    data_street2.text = "";
                                    data_locale2.text = "";
                                    data_region2.text = "";
                                    data_zip2.text = "";
                                    data_country2.text = "";
                                    addressComboBox2.selectedValue = contextHome;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
