import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: groupedViewPage

/*            onSearch: {
        if(needle != "")
            peopleModel.searchContacts(needle);
    }*/

    ContactListWidget {
        id: gvp
        anchors.fill: parent
        dataModel: peopleModel
        sortModel: proxyModel
    }

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "icon-m-common-add"
            onClicked: {
                newContactLoader.openSheet()
            }
        }
//        ToolIcon { iconId: "icon-m-toolbar-view-menu" }
    }

    Loader {
        id: newContactLoader

        function openSheet() {
            if (sheetUnloadTimer.running)
                sheetUnloadTimer.stop()

            var sourceUri = Qt.resolvedUrl("NewContactSheet.qml")
            if (newContactLoader.source != sourceUri)
                newContactLoader.source = sourceUri;
            else
                item.open(); // already connected, just reopen it
        }

        Timer {
            id: sheetUnloadTimer
            interval: 60000 // leave it a while in case they want it again
            onTriggered: {
                console.log("SHEET: freeing resources")
                newContactLoader.source = ""
            }
        }

        function closeSheet() {
            sheetUnloadTimer.start()
        }

        onLoaded: {
            item.accepted.connect(closeSheet)
            item.rejected.connect(closeSheet)
            item.open()
        }
    }

/*
// FIXME
            onActivating: {
                setAllFilter(false, false);

                if (window.currentFilter == PeopleModel.FavoritesFilter)
                    setFavoritesFilter();
            }
*/
}

