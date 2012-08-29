/**
 * Copyright (c) 2012 Nokia Corporation.
 * All rights reserved.
 *
 * For the applicable distribution terms see the license text file included in
 * the distribution.
 */

import QtQuick 1.1
import com.nokia.meego 1.0

// A Custom made search box element, as there is no SearchBox in MeeGo Qt Quick
// Components Extras. Some implementation ripped from the QQC Symbian
// SearchBox.
Item {
    id: root

    // Declared properties
    property alias searchText: searchTextInput.text
    property alias placeHolderText: searchTextInput.placeholderText
    property alias maximumLength: searchTextInput.maximumLength
    property alias activeFocus: searchTextInput.activeFocus
    // Styling for the SearchBox
    property Style platformStyle: ToolBarStyle {}

    // Signals & functions
    signal backClicked

    // Attribute definitions
    width: parent ? parent.width : 0
    height: bgImage.height


    // SearchBox background.
    BorderImage {
        id: bgImage
        width: root.width
        border.left: 10
        border.right: 10
        border.top: 10
        border.bottom: 10
        source: platformStyle.background
    }

    FocusScope {
        id: textPanel

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 20
        height: parent.height

        TextField {
            id: searchTextInput

            // Helper function ripped from QQC platform sources. Used for
            // getting the correct URI for the platform toolbar images.
            function __handleIconSource(iconId) {
                var prefix = "icon-m-"
                // check if id starts with prefix and use it as is
                // otherwise append prefix and use the inverted version if required
                if (iconId.indexOf(prefix) !== 0)
                    iconId =  prefix.concat(iconId).concat(theme.inverted ? "-white" : "");
                return "image://theme/" + iconId;
            }

            clip: true
            inputMethodHints: Qt.ImhNoPredictiveText

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: textPanel.verticalCenter
                margins: 10
            }

            // Save some empty space for the text on the left & right,
            // for the icon graphics.
            platformStyle: TextFieldStyle {
                paddingLeft: searchIcon.width + 10 * 2
                paddingRight: clearTextIcon.width
            }

            onActiveFocusChanged: {
                if (!searchTextInput.activeFocus) {
                    searchTextInput.platformCloseSoftwareInputPanel()
                }
            }

            // Search icon, just for styling the SearchBox a bit.
            Image {
                id: searchIcon

                property string __searchIconId: "toolbar-search"

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: 10 * 2
                }

                smooth: true
                fillMode: Image.PreserveAspectFit
                source: searchTextInput.__handleIconSource(__searchIconId)
                height: parent.height - 10 * 2
                width: parent.height - 10 * 2
            }

            // A trash can image, clicking it allows the user to quickly
            // remove the typed text.
            Image {
                id: clearTextIcon

                property string __clearTextIconId: "toolbar-delete"

                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                smooth: true;
                fillMode: Image.PreserveAspectFit
                source: searchTextInput.__handleIconSource(__clearTextIconId)
                visible: searchTextInput.text.length > 0

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        searchTextInput.text = ""
                        searchTextInput.forceActiveFocus()
                    }
                }
            }
        }
    }
}
