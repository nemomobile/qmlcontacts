/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Contacts 0.1

Flickable {
    id: listOfGridsView
    property PeopleModel dataPeople: null
    property ProxyModel sortPeople: null
    property Component delegate: null
    property Component sectionDelegate: null
    property Item topLevel: null
    property int itemSpacing: 25
    property int count: 0
    property variant headerCharacterToYMap: null
    property string cUuid: ""

    flickableDirection: Flickable.VerticalFlick

    Component {
        id: itemComponent
        Item {}
    }

    Component {
        id: gridComponent
        Grid { columns: 6; spacing: listOfGridsView.itemSpacing }
    }

    function positionViewAtHeader(headerCharacter) {
        if (headerCharacter in headerCharacterToYMap)
        {
            listOfGridsView.contentY = headerCharacterToYMap[headerCharacter]
        }
    }

    function createItems() {

        if (topLevel)
        {
            topLevel.destroy()
        }

        topLevel = itemComponent.createObject(listOfGridsView.contentItem)
        topLevel.anchors.fill = listOfGridsView.contentItem

        if (dataPeople == null || sortPeople == null ||
            delegate == null || dataPeople.rowCount() == 0)
        {
            count = 0
            headerCharacterToYMap = {}
            return
        }

        count = dataPeople.rowCount()

        var localHeaderCharacterToYMap = {}
        var currentY = 0
        var currentSectionFirstChar = "empty" // an invalid, non-empty value
        var currentGrid = null
        for (var proxyIndex = 0; proxyIndex < dataPeople.rowCount(); ++proxyIndex) {

            var sourceIndex = sortPeople.getSourceRow(proxyIndex)
            var firstChar = dataPeople.data(sourceIndex, PeopleModel.FirstCharacterRole)
            if (firstChar == undefined) continue;

            if (firstChar != currentSectionFirstChar) {
                currentSectionFirstChar = firstChar

                // If we have an existing grid, account for its size
                if (currentGrid) {
                    currentY += currentGrid.height + (2*itemSpacing)
                }

                // Create a new header (unless this is the Me contact)
                if (!dataPeople.data(sourceIndex, PeopleModel.IsSelfRole)) {
                    var header = sectionDelegate.createObject(topLevel)
                    header.y = currentY
                    header.anchors.left = topLevel.left
                    header.anchors.right = topLevel.right
                    header.section = currentSectionFirstChar
                    localHeaderCharacterToYMap[header.section] = header.y
                    currentY += header.height
                }

                // Create a new grid
                var currentGrid = gridComponent.createObject(topLevel)
                currentGrid.y += currentY + itemSpacing
                currentGrid.x += itemSpacing
            }

            // Create delegate item and add to grid
            var delegateItem = delegate.createObject(currentGrid)
            delegateItem.sourceIndex = sourceIndex
            delegateItem.proxyIndex = proxyIndex
        }

        headerCharacterToYMap = localHeaderCharacterToYMap
        listOfGridsView.contentHeight = currentY + currentGrid.height + (2*itemSpacing)
        listOfGridsView.cUuid = dataPeople.data(sortModel.getSourceRow(0),
                                                PeopleModel.UuidRole);
    }

    onDataPeopleChanged: createItems()

    Connections {
        target: sortPeople
        onModelReset: createItems()
        onDataChanged: createItems()
        onRowsInserted: createItems()
        onRowsRemoved: createItems()
    }

    Connections {
        target: dataPeople
        onModelReset: createItems()
        onDataChanged: createItems()
        onRowsInserted: createItems()
        onRowsRemoved: createItems()
    }
}

