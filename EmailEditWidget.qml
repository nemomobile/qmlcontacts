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
    id: emailRect
    height: childrenRect.height
    width:  parent.width

    property int initialHeight: childrenRect.height

    property variant emailModel: contactModel
    property variant contextModel: typeModel

    property string contextHome : qsTr("Home")
    property string contextWork : qsTr("Work")
    property string contextOther : qsTr("Other")
    property string defaultEmail : qsTr("Email address")
    property string labelEmail : qsTr("Email")
    property string addEmail: qsTr("Add email address")
    property string cancelLabel: qsTr("Cancel")
    property string addLabel: qsTr("Add")

    function getNewEmails() {
        var emailAddyList = new Array();
        var emailTypeList = new Array();
        var count = 0;

        for (var i = 0; i < emails.count; i++) {
            if (emails.get(i).email != "") {
                emailAddyList[count] = emails.get(i).email;
                emailTypeList[count] = emails.get(i).type;
                count = count + 1;
            }
        }
        return {"emails": emailAddyList, "types": emailTypeList};
    }

    ListModel{
        id: emails
        Component.onCompleted:{
            for(var i =0; i < emailModel.length; i++)
                emails.append({"email": emailModel[i], "type": contextModel[i]});
        }
    }

    Column{
        spacing: 1
        anchors {left:parent.left; right: parent.right; }

        Item {
            id: emailHeader
            width: parent.width
            height: 70
            opacity: 1

            Text{
                id: label_email
                text: labelEmail
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                smooth: true
                anchors {bottom: emailHeader.bottom; bottomMargin: 10; left: emailHeader.left; leftMargin: 30}
            }
        }

        Repeater{
            model: emails
            width: parent.width
            height: childrenRect.height
            opacity: (emailModel.length > 0 ? 1  : 0)
            delegate: Item {
                id: itemDelegate
                width: parent.width;
                height: 80;
                signal clicked()

                //Need to store the repeater index, as the drop down overwrites index with its own value
                property int repeaterIndex: index

                Image{
                    id: emailBar
                    source: "image://theme/contacts/active_row" //REVIST: Do we need a downstate for this?
                    anchors.fill:  parent

                    DropDown {
                        id: emailComboBox
                        height: 60
                        delegateComponent: stringDelegate

                        anchors {verticalCenter: emailBar.verticalCenter; left: emailBar.left; leftMargin: 10}
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
                            emails.setProperty(repeaterIndex, "type", data);
                        }
                    }


                    TextEntry{
                        id: data_email
                        text: email
                        defaultText: defaultEmail
                        width: 400
                        anchors {verticalCenter: parent.verticalCenter; left:emailComboBox.right; leftMargin: 10; right: delete_button.left; rightMargin: 10}
                        inputMethodHints: Qt.ImhEmailCharactersOnly
                        onTextChanged: {
                            if (emails.get(index).type == "")
                                emails.set(index, {"email": data_email.text, "type": emailComboBox.dataList[emailComboBox.selectedIndex]});
                            else
                                emails.setProperty(index, "email", data_email.text);
                        }
                    }

                    Image {
                        id: delete_button
                        source: "image://theme/contacts/icn_trash"
                        width: 36
                        height: 36
                        anchors {verticalCenter: data_email.verticalCenter; right:parent.right; rightMargin: 20}
                        opacity: 1
                        MouseArea{
                            id: mouse_delete_email
                            anchors.fill: parent
                            onPressed: {
                                delete_button.source = "image://theme/contacts/icn_trash_dn";
                            }
                            onClicked: {
                                if(emails.count != 1 ){
                                    emails.remove(index);
                                    emailRect.height = emailRect.height-itemDelegate.height;
                                }else{
                                    data_email.text = "";
                                    emailComboBox.selectedValue = contextHome;
                                }
                                delete_button.source = "image://theme/contacts/icn_trash";
                            }
                        }
                        Binding{target: delete_button; property: "visible"; value: false; when: emails.count < 2}
                        Binding{target: delete_button; property: "visible"; value: true; when: emails.count > 1}
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
                        anchors{ verticalCenter: emailBox.verticalCenter; left: emailBox.left; leftMargin: 20}
                        width: 36
                        height: 36
                        opacity: 1
                    }

                    id: emailBox
                    detailsComponent: emailComponent

                    expanded: false
                    width: parent.width
                    anchors{ verticalCenter: addBar.verticalCenter; top: addBar.top; leftMargin: 15;}
                    titleTextItem.text: addEmail
                    titleTextItem.color: theme_fontColorNormal
                    titleTextItem.anchors.leftMargin: add_button.width + add_button.anchors.leftMargin + emailBox.anchors.leftMargin
                    titleTextItem.font.bold: true
                    titleTextItem.font.pixelSize: theme_fontPixelSizeLarge
                    pulldownImageSource: "image://theme/contacts/active_row"

                    expandedHeight: detailsItem.height + expandButton.height

                    onExpandedChanged: {
                        emailRect.height = expanded ? (initialHeight + expandedHeight) : initialHeight;
                        add_button.source = expanded ? "image://theme/contacts/icn_add_dn" : "image://theme/contacts/icn_add";
                        pulldownImageSource = expanded ? "image://theme/contacts/active_row_dn" : "image://theme/contacts/active_row"
                    }

                    Component {
                        id: emailComponent
                        Item {
                            id: emailBar2
                            height: 100

                            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                                id: emailComboBox2
                                height: 60
                                delegateComponent: stringDelegate2

                                anchors {left: emailBar2.left; leftMargin: emailBox.titleTextItem.anchors.leftMargin - emailBox.anchors.leftMargin;}
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
                                id: data_email2
                                text: ""
                                defaultText: defaultEmail
                                width: 400
                                anchors {left:emailComboBox2.right; leftMargin: 10;}
                            }

                            Button {
                                id: addButton
                                width: 100
                                height: 36
                                title: addLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                bgSourceUp: "image://theme/btn_blue_up"
                                bgSourceDn: "image://theme/btn_blue_dn"
                                anchors {right:cancelButton.left; top: data_email2.bottom; topMargin: 15; rightMargin: 5;}
                                onClicked: {
                                    emails.append({"email": data_email2.text, "type": emailComboBox2.dataList[emailComboBox2.selectedIndex]});
                                    emailBox.expanded = false;
                                    data_email2.text = "";
                                    emailComboBox2.selectedValue = contextHome;
                                }
                            }

                            Button {
                                id: cancelButton
                                width: 100
                                height: 36
                                title: cancelLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                anchors {right:data_email2.right; top: data_email2.bottom; topMargin: 15;}
                                onClicked: {
                                    emailBox.expanded = false;
                                    data_email2.text = "";
                                    emailComboBox2.selectedValue = contextHome;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
