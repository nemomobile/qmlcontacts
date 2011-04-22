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

    property int initialHeight: childrenRect.height

    property variant webModel: contactModel
    property variant contextModel: typeModel
    property bool    validInput   : false

    property alias detailsBoxExpanded: webDetailsItem.expanded

    property string addWeb : qsTr("Add web page")
    property string defaultWeb : qsTr("Site")
    property string headerWeb : qsTr("Web")
    property string bookmarkWeb : qsTr("Bookmark")
    property string favoriteWeb : qsTr("Favorite")
    property string cancelLabel: qsTr("Cancel")
    property string addLabel: qsTr("Add")

    function getNewUrls() {
        var webUrlList = new Array();
        var webTypeList = new Array();
        var count = 0;

        for (var i = 0; i < webs.count; i++) {
            if (webs.get(i).web != "") {
                webUrlList[count] = webs.get(i).web;
                webTypeList[count] = webs.get(i).type;
                count = count + 1;
            }
        }
        return {"urls": webUrlList, "types": webTypeList};
    }

    ListModel{
        id: webs
        Component.onCompleted:{
            for(var i =0; i < webModel.length; i++)
                webs.append({"web": webModel[i], "type": contextModel[i]});
        }
    }

    ContactsExpandableDetails {
        id: webDetailsItem

        headerLabel: headerWeb
        expandingBoxTitle: addWeb
        repeaterComponent: webExistingComponent

        detailsModel: webs 
        fieldDetailComponent: webNewComponent

        onDetailsBoxExpandingChanged: {
            webRect.height = expanded ? (initialHeight + newHeight) : initialHeight;
        }
    }

   Component {
        id: webExistingComponent

        Item {
            id: itemDelegate
            width: parent.width;
            height: 80;
            signal clicked()

            //Need to store the repeater index, as the drop down overwrites index with its own value
            property int repeaterIndex: index
            Image {
                id: webBar
                source: "image://theme/contacts/active_row"
                anchors.fill:  parent

                DropDown {
                    id:  webComboBox

                    anchors {verticalCenter: webBar.verticalCenter; left: webBar.left; leftMargin: 10}
                    title: webs.get(repeaterIndex).type
                    titleColor: theme_fontColorNormal
                    replaceDropDownTitle: true

                    width: 250
                    minWidth: width
                    maxWidth: width + 50

                    model: [favoriteWeb, bookmarkWeb]

                    onTriggered: {
                        webs.setProperty(repeaterIndex, "type", data);
                    }
                }

                TextEntry {
                    id: data_web
                    text: web
                    defaultText: defaultWeb
                    width: 400
                    anchors {verticalCenter: parent.verticalCenter; left:webComboBox.right; leftMargin: 10; right: delete_button.left; rightMargin: 10}
                    inputMethodHints: Qt.ImhUrlCharactersOnly
                    onTextChanged: {
                        webs.setProperty(index, "web", data_web.text);
                    }
                }
                Binding{ target: webRect; property: "validInput"; value: true; when: data_web.text != "";}
                Binding{ target: webRect; property: "validInput"; value: false; when: data_web.text == "";}

                Image {
                    id: delete_button
                    source: "image://theme/contacts/icn_trash"
                    width: 36
                    height: 36
                    anchors {verticalCenter: data_web.verticalCenter; right:parent.right; rightMargin: 20}
                    opacity: 1
                    MouseArea {
                        id: mouse_delete_web
                        anchors.fill: parent
                        onPressed: {
                            delete_button.source = "image://theme/contacts/icn_trash_dn";
                        }
                        onClicked: {
                            if (webs.count != 1) {
                                webs.remove(index);
                                if (webRect.height > initialHeight) 
                                    webRect.height = webRect.height-itemDelegate.height;
                            } else {
                                data_web.text = "";
                                webComboBox.selectedTitle = bookmarkWeb;
                            }
                            delete_button.source = "image://theme/contacts/icn_trash";
                        }
                    }
                    Binding{target: delete_button; property: "visible"; value: false; when: webs.count < 2}
                    Binding{target: delete_button; property: "visible"; value: true; when: webs.count > 1}
                }
            }
        }
    }

    Component {
        id: webNewComponent

        Item {
            id: urlBar2
            height: 100

            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                id: urlComboBox2

                anchors {left: urlBar2.left; leftMargin: 10;}
                title: bookmarkWeb
                titleColor: theme_fontColorNormal
                replaceDropDownTitle: true

                width: 250
                minWidth: width
                maxWidth: width + 50

                model: [favoriteWeb, bookmarkWeb]
             }

            TextEntry {
                id: data_url2
                text: ""
                defaultText: defaultWeb
                width: 400
                anchors {left:urlComboBox2.right; leftMargin: 10;}
            }

            Button {
                id: addButton
                width: 100
                height: 36
                text: addLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                bgSourceUp: "image://theme/btn_blue_up"
                bgSourceDn: "image://theme/btn_blue_dn"
                anchors {right:cancelButton.left; top: data_url2.bottom; topMargin: 15; rightMargin: 5;}
                onClicked: {
                    webs.append({"web": data_url2.text, "type": urlComboBox2.selectedTitle});
                    detailsBoxExpanded = false;
                    data_url2.text = "";
                    urlComboBox2.selectedTitle = bookmarkWeb;
                }
            }

            Button {
                id: cancelButton
                width: 100
                height: 36
                text: cancelLabel
                font.pixelSize: theme_fontPixelSizeMediumLarge
                anchors {right:data_url2.right; top: data_url2.bottom; topMargin: 15;}
                onClicked: {
                    detailsBoxExpanded = false;
                    data_url2.text = "";
                    urlComboBox2.selectedTitle = bookmarkWeb;
                }
            }
        }
    }
}
