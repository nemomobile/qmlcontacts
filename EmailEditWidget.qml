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
    id: emailRect
    height: childrenRect.height
    width:  parent.width

    property int initialHeight: childrenRect.height

    property variant emailModel: contactModel
    property variant contextModel: typeModel
    property bool    validInput   : false

    property alias detailsBoxExpanded: emailDetailsItem.expanded

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

    ContactsExpandableDetails {
        id: emailDetailsItem

        headerLabel: labelEmail
        expandingBoxTitle: addEmail
        repeaterComponent: emailExistingComponent

        detailsModel: emails
        fieldDetailComponent: emailNewComponent

        onDetailsBoxExpandingChanged: {
            emailRect.height = expanded ? (initialHeight + newHeight) : initialHeight;
        }
    }


   Component {
        id: emailExistingComponent

        Item {
            id: itemDelegate
            width: (parent ? parent.width : 0)
            height: 80;
            signal clicked()

            //Need to store the repeater index, as the drop down overwrites index with its own value
            property int repeaterIndex: index

            Image {
                id: emailBar
                source: "image://theme/contacts/active_row" //REVIST: Do we need a downstate for this?
                anchors.fill:  parent

                DropDown {
                    id: emailComboBox

                    anchors {verticalCenter: emailBar.verticalCenter; left: emailBar.left; leftMargin: 10}
                    title: emails.get(repeaterIndex).type
                    titleColor: theme_fontColorNormal
                    replaceDropDownTitle: true

                    width: 250
                    minWidth: width
                    maxWidth: width + 50

                    model: [contextHome, contextWork, contextOther]

                    onTriggered: {
                        emails.setProperty(repeaterIndex, "type", data);
                    }
                }

                TextEntry {
                    id: data_email
                    text: email
                    defaultText: defaultEmail
                    width: 400
                    anchors {verticalCenter: parent.verticalCenter; left:emailComboBox.right; leftMargin: 10; right: delete_button.left; rightMargin: 10}
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                    onTextChanged: {
                        if (emails.get(index).type == "")
                            emails.set(index, {"email": data_email.text, "type": emailComboBox.selectedTitle});
                        else
                            emails.setProperty(index, "email", data_email.text);
                    }
                }
                Binding{ target: emailRect; property: "validInput"; value: true; when: data_email.text != "";}
                Binding{ target: emailRect; property: "validInput"; value: false; when: data_email.text == "";}

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
                            if (emails.count != 1) {
                                emails.remove(index);
                                if (emailRect.height > initialHeight)
                                    emailRect.height = emailRect.height-itemDelegate.height;
                            } else {
                                data_email.text = "";
                                emailComboBox.selectedTitle = contextHome;
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

    Component {
        id: emailNewComponent

        Item {
            id: emailBar2
            height: 100

            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                id: emailComboBox2

                anchors {left: emailBar2.left; leftMargin: 10;}
                title: contextHome
                titleColor: theme_fontColorNormal
                replaceDropDownTitle: true

                width: 250
                minWidth: width
                maxWidth: width + 50

                model: [contextHome, contextWork, contextOther]
            }

            TextEntry {
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
                text: addLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                bgSourceUp: "image://theme/btn_blue_up"
                bgSourceDn: "image://theme/btn_blue_dn"
                anchors {right:cancelButton.left; top: data_email2.bottom; topMargin: 15; rightMargin: 5;}
                onClicked: {
                    emails.append({"email": data_email2.text, "type": emailComboBox2.selectedTitle});
                    detailsBoxExpanded = false;
                    data_email2.text = "";
                    emailComboBox2.selectedTitle = contextHome;
                }
            }

            Button {
                id: cancelButton
                width: 100
                height: 36
                text: cancelLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                anchors {right:data_email2.right; top: data_email2.bottom; topMargin: 15;}
                onClicked: {
                    detailsBoxExpanded = false;
                    data_email2.text = "";
                    emailComboBox2.selectedTitle = contextHome;
                }
            }
        }
    }
}
