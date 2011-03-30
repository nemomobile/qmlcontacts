/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.Settings 0.1
import MeeGo.App.Contacts 0.1

ApplicationPage {
    id: settingsPage
    property string titleStr: qsTr("Contacts Settings")
    property string sortPreferenceStr: qsTr("Sort Order:")
    property string byFirstNameStr: qsTr("Sort by first name")
    property string byLastNameStr: qsTr("Sort by last name")

    title: titleStr

    function getSelectedValStr() {
        if (settingsDataStore.getSortOrder() == ProxyModel.SortLastName)
            return byLastNameStr;
        else
            return byFirstNameStr;
    }

    Item {
        anchors.fill: settingsPage.content

        Flickable {
            contentHeight: contents.height
            anchors.fill: parent
            clip: true

            Column {
                id: contents
                width: parent.width

                Image {
                    id: sortSettingItem
                    source: "image://theme/pulldown_box"
                    width: parent.width

                    Text {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: sortPreferenceStr
                        width: 100
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }

                    DropDown {
                        delegateComponent: Text {
                            property string data
                            text: data
                        }
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        selectedValue: getSelectedValStr()
                        dataList: [byFirstNameStr, byLastNameStr]
                        width: 300

                        onSelectionChanged: {
                            if (data == byFirstNameStr)
                                settingsDataStore.setSortOrder(ProxyModel.SortFirstName);
                            else if (data == byLastNameStr)
                                settingsDataStore.setSortOrder(ProxyModel.SortLastName);
                        }
                    } //DropDown
                }  //Image
            } //Column
        } //Flickable
    } //Item
}
