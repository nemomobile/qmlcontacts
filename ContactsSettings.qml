/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.Settings 0.1
import MeeGo.App.Contacts 0.1

AppPage {
    id: settingsPage
    property string titleStr: qsTr("Contacts Settings")
    property string sortPreferenceStr: qsTr("Sort Order:")

    //: How contacts will be displayed to the user - last first or first last
    property string displayPreferenceStr: qsTr("Display Order:")
    property string sortByFirst: qsTr("Sort by first name")
    property string sortByLast: qsTr("Sort by last name")

    //: Display contacts with the first name first - FirstName LastName
    property string displayByFirst: qsTr("Display by first name")

    //: Display contacts with the last name first - LastName FirstName
    property string displayByLast: qsTr("Display by last name")
    property int itemMargins: 10

    Translator { catalog: "meego-app-contacts" }
    pageTitle: titleStr
    height: contents.height
    anchors.fill: parent

    function getSettingText(type) {
        if (type == "sort")
            return sortPreferenceStr;

        return displayPreferenceStr;
    }

    function getCurrentVal(type) {
        if (type == "sort") {
            if (settingsDataStore.getSortOrder() == PeopleModel.LastNameRole)
                return 1;
            else
                return 0;
        }

        if (settingsDataStore.getDisplayOrder() == PeopleModel.LastNameRole)
            return 1;
        else
            return 0;
    }

    function getDataList(type) {
        if (type == "sort")
            return [sortByFirst, sortByLast];

        return [displayByFirst, displayByLast];
    }

    function handleSelectionChanged(type, data, dataList) {
        if (type == "sort") {
            if (dataList[data] == sortByFirst)
                settingsDataStore.setSortOrder(PeopleModel.FirstNameRole);
            else if (dataList[data] == sortByLast)
                settingsDataStore.setSortOrder(PeopleModel.LastNameRole);
        }

        if (dataList[data] == displayByFirst)
            settingsDataStore.setDisplayOrder(PeopleModel.FirstNameRole);
        else if (dataList[data] == displayByLast)
            settingsDataStore.setDisplayOrder(PeopleModel.LastNameRole);
    }

    ListModel {
        id: settingsList
        ListElement { type: "sort" }
        ListElement { type: "display" }
    }

    Column {
        id: contents
        width: parent.width

        Repeater {
            model: settingsList
            width: parent.width
            height: childrenRect.height
            delegate: settingsComponent
        }
    } //Column

    Component {
        id: settingsComponent

        Image {
            id: sortSettingItem
            source: "image://themedimage/images/pulldown_box"
            width: parent.width

            Text {
                id: settingsText
                anchors.left: parent.left
                anchors.leftMargin: itemMargins
                text: getSettingText(modelData)
                width: Math.round(parent.width/2) - itemMargins
                height: parent.height
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                id: dropDownItem
                anchors {verticalCenter: parent.verticalCenter;
                         left: settingsText.right;
                         leftMargin: itemMargins;
                         right: parent.right
                         rightMargin: 10 }
                DropDown {
                    anchors {verticalCenter: parent.verticalCenter;}
                    selectedIndex: getCurrentVal(modelData)
                    titleColor: theme_fontColorNormal
                    replaceDropDownTitle: true

                    model: getDataList(modelData)

                    maxWidth: (parent.width <= 0) ? 400 : Math.round(parent.width/2)

                    onTriggered: {
                        handleSelectionChanged(modelData, selectedIndex, model);
                    }
                } //DropDown
            } //Item
        }  //Image
    }  //Component
}
