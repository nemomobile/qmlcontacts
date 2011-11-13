/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0

Image{
    //: If a contact isn't sorted under one of the values in a locale's alphabet, it is sorted under '#'
    property string etcSymbol: qsTr("#")
    id: sectionBackground
    source: "image://themedimage/widgets/common/list/list-dividerbar"
    Text {
        id: headerTitle
        text: (section ? section.toUpperCase() : etcSymbol)
        anchors.verticalCenter: sectionBackground.verticalCenter
        anchors.left: sectionBackground.left
        anchors.leftMargin: 30
        smooth: true
    }
}

