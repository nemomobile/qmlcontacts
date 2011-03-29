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
    id: webRect
    height: childrenRect.height
    width:  parent.width

    property int initialHeight: childrenRect.height

    property variant webModel: contactModel
    property variant contextModel: typeModel
    property bool    validInput   : false

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

    Column{
        spacing: 1
        anchors {left:parent.left; right: parent.right; }
        Item {
            id: webHeader
            width: parent.width
            height: 70
            opacity: 1
            Text{
                id: label_web
                text: headerWeb
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorInactive
                smooth: true
                anchors {bottom: webHeader.bottom; bottomMargin: 10; left: webHeader.left; leftMargin: 30}
            }
        }

        Repeater{
            model: webs
            width: parent.width
            height: childrenRect.height
            opacity: (webModel.length > 0 ? 1  : 0)
            delegate: Item {
                id: itemDelegate
                width: parent.width;
                height: 80;
                signal clicked()

                //Need to store the repeater index, as the drop down overwrites index with its own value
                property int repeaterIndex: index
                Image{
                    id: webBar
                    source: "image://theme/contacts/active_row"
                    anchors.fill:  parent


                    DropDown {
                        id:  webComboBox
                        height: 60
                        delegateComponent: stringDelegate

                        anchors {verticalCenter: webBar.verticalCenter; left: webBar.left; leftMargin: 10}
                        width: 150

                        selectedValue: type

                        dataList: [favoriteWeb, bookmarkWeb]

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
                            webs.setProperty(repeaterIndex, "type", data);
                        }
                    }

                    TextEntry{
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
                        MouseArea{
                            id: mouse_delete_web
                            anchors.fill: parent
                            onPressed: {
                                delete_button.source = "image://theme/contacts/icn_trash_dn";
                            }
                            onClicked: {
                                if(webs.count != 1 ){
                                    webs.remove(index);
                                    webRect.height = webRect.height-itemDelegate.height;
                                }else{
                                    data_web.text = "";
                                    webComboBox.selectedValue = bookmarkWeb;
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
                        anchors{ verticalCenter: urlBox.verticalCenter; left: urlBox.left; leftMargin: 20}
                        width: 36
                        height: 36
                        opacity: 1
                    }

                    id: urlBox
                    detailsComponent: urlComponent

                    expanded: false
                    width: parent.width
                    anchors{ verticalCenter: addBar.verticalCenter; top: addBar.top; leftMargin: 15;}
                    titleTextItem.text: addWeb
                    titleTextItem.color: theme_fontColorNormal
                    titleTextItem.anchors.leftMargin: add_button.width + add_button.anchors.leftMargin + urlBox.anchors.leftMargin
                    titleTextItem.font.bold: true
                    titleTextItem.font.pixelSize: theme_fontPixelSizeLarge
                    pulldownImageSource: "image://theme/contacts/active_row"

                    expandedHeight: detailsItem.height + expandButton.height

                    onExpandedChanged: {
                        webRect.height = expanded ? (initialHeight + expandedHeight) : initialHeight;
                        add_button.source = expanded ? "image://theme/contacts/icn_add_dn" : "image://theme/contacts/icn_add";
                        pulldownImageSource = expanded ? "image://theme/contacts/active_row_dn" : "image://theme/contacts/active_row"
                    }

                    Component {
                        id: urlComponent
                        Item {
                            id: urlBar2
                            height: 100

                            DropDown { //REVISIT: Maybe max a component that all widgets can use?
                                id: urlComboBox2
                                height: 60
                                delegateComponent: stringDelegate2

                                anchors {left: urlBar2.left; leftMargin: urlBox.titleTextItem.anchors.leftMargin - urlBox.anchors.leftMargin;}
                                width: 150

                                selectedValue: type

                                dataList: [favoriteWeb, bookmarkWeb]

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
                                title: addLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                bgSourceUp: "image://theme/btn_blue_up"
                                bgSourceDn: "image://theme/btn_blue_dn"
                                anchors {right:cancelButton.left; top: data_url2.bottom; topMargin: 15; rightMargin: 5;}
                                onClicked: {
                                    webs.append({"web": data_url2.text, "type": urlComboBox2.dataList[urlComboBox2.selectedIndex]});
                                    urlBox.expanded = false;
                                    data_url2.text = "";
                                    urlComboBox2.selectedValue = bookmarkWeb;
                                }
                            }

                            Button {
                                id: cancelButton
                                width: 100
                                height: 36
                                title: cancelLabel
                                font.pixelSize: theme_fontPixelSizeMediumLarge
                                anchors {right:data_url2.right; top: data_url2.bottom; topMargin: 15;}
                                onClicked: {
                                    urlBox.expanded = false;
                                    data_url2.text = "";
                                    urlComboBox2.selectedValue = bookmarkWeb;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
