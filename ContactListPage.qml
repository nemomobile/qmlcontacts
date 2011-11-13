import QtQuick 1.1
import com.nokia.meego 1.0

Page {
    id: groupedViewPage

/*            onSearch: {
        if(needle != "")
            peopleModel.searchContacts(needle);
    }*/

    Item {
        id: groupedView
        anchors {top: parent.top; bottom: groupedViewFooter.top; left: parent.left; right: parent.right;}

        GroupedViewPortrait {
            id: gvp
            anchors.fill: parent
            dataModel: peopleModel
            sortModel: proxyModel
            onAddNewContact:{
                window.addPage(myAppNewContact);
            }
        }
    }

    FooterBar { 
        id: groupedViewFooter 
        type: ""
        currentView: gvp
        letterBar: true
        proxy:  proxyModel
        people: peopleModel
        onDirectoryCharacterClicked: {
            // Update landscape view
            gvl.cards.positionViewAtHeader(character)

            // Update portrait view
            for(var i=0; i < gvp.cards.count; i++){
                var c = peopleModel.data(proxyModel.getSourceRow(i), PeopleModel.FirstCharacterRole);
                var exemplar = localeUtils.getExemplarForString(c);
                if(exemplar == character){
                    gvp.cards.positionViewAtIndex(i, ListView.Beginning);
                    break;
                }
            }
        }
    }
// FIXME
/*
//            actionMenuModel: [labelNewContactView]
//            actionMenuPayload: [0]

    onActionMenuTriggered: {
        if (selectedItem == 0) {
            if (window.pageStack.currentPage == groupedViewPage)
                window.addPage(myAppNewContact);
        }
    }
//            onActivating: {
//                setAllFilter(false, false);
//
//                if (window.currentFilter == PeopleModel.FavoritesFilter)
//                    setFavoritesFilter();
//            }
*/
}

