import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Page {
    id: detailViewPage
//            pageTitle: labelDetailView
    Component.onCompleted : {
        window.toolBarTitle = labelDetailView;
        detailViewPage.disableSearch = true;
    }
    ContactCardContentWidget {
        id: detailViewContact
        anchors.fill:  parent
        detailModel: peopleModel
        indexOfPerson: proxyModel.getSourceRow(window.currentContactIndex)
    }
/*            actionMenuModel: [contextShare, contextEdit]
    actionMenuPayload: [0, 1]

    onActionMenuTriggered: {
        if (selectedItem == 0) {
            console.log("TODO this needs fixing (contacts app, ask Robin)")
//                    peopleModel.exportContact(window.currentContactId,  "/tmp/vcard.vcf");
//                    var cmd = "/usr/bin/meego-qml-launcher --app meego-app-email --fullscreen --cmd openComposer --cdata \"file:///tmp/vcard.vcf\"";
//                    appModel.launch(cmd);
        }
        else if (selectedItem == 1) {
            if (window.pageStack.currentPage == detailViewPage)
                window.addPage(myAppEdit);
        }
    }
    onActivated: {
        detailViewContact.indexOfPerson = proxyModel.getSourceRow(window.currentContactIndex);
    }
*/
    tools: ToolBarLayout {
        ToolItem {
            iconId: "icon-m-toolbar-back"
            onClicked: pageStack.pop()
        }
        ToolItem {
            iconId: "icon-m-toolbar-view-menu";
            onClicked: {
                console.log("TODO menu")
                pageStack.push(Qt.resolvedUrl("EditContactSheet.qml"))
            }
        }
    }
}

