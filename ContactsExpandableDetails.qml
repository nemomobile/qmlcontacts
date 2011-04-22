/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
import MeeGo.App.Contacts 0.1

Column {
    id: detailsColumn
    spacing: 1
    anchors {left:parent.left; right: parent.right; }

    property string headerLabel
    property string expandingBoxTitle
    property Component repeaterComponent

    property alias expanded: detailsBox.expanded
    property alias detailsModel: detailsRepeater.model
    property alias fieldDetailComponent: detailsBox.detailsComponent

    signal detailsBoxExpandingChanged(int newHeight)

    Item {
        id: detailsHeader
        width: parent.width
        height: 70
        opacity: 1

        Text {
            id: label_details
            text: headerLabel
            color: theme_fontColorNormal
            font.pixelSize: theme_fontPixelSizeLarge
            styleColor: theme_fontColorInactive
            smooth: true
            anchors {bottom: detailsHeader.bottom; bottomMargin: 10; left: detailsHeader.left; leftMargin: 30}
        }
    }

    Repeater {
        id: detailsRepeater

        //model: //No need to set this as we're using an alias
        width: parent.width
        height: childrenRect.height
        opacity: (model.count > 0 ? 1  : 0)

        delegate: repeaterComponent
    }

    Item {
        id: addFooter
        width: parent.width
        height: 80

        Image {
            id: addBar
            source: "image://theme/contacts/active_row"
            anchors {fill: parent; bottomMargin: 1}

            ExpandingBox {
                id: detailsBox

                property int boxHeight

                anchors {verticalCenter: addBar.verticalCenter; top: addBar.top; leftMargin: 15;}
                width: parent.width
                titleText: expandingBoxTitle
                titleTextColor: theme_fontColorNormal

                iconRow: [
                    Image {
                        id: add_button
                        source: "image://theme/contacts/icn_add"
                        anchors { verticalCenter: parent.verticalCenter; }
                        fillMode: Image.PreserveAspectFit
                        opacity: 1
                    }
                ]

                //detailsComponent: fieldDetailComponent //No need to set this as there's an alias

                onExpandingChanged: {
                    add_button.source = expanded ? "image://theme/contacts/icn_add_dn" : "image://theme/contacts/icn_add";
                    detailsColumn.detailsBoxExpandingChanged(detailsItem.height + add_button.height);
                }
            }
        }
    }
}
