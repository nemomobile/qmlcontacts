/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import com.nokia.meego 1.0
import MeeGo.App.Contacts 0.1

Flickable{

    id: newContactPage
    contentWidth: parent.width
    contentHeight: detailsList.height
    flickableDirection: Flickable.VerticalFlick
    anchors.horizontalCenter:  parent.horizontalCenter
    height: parent.height
    width: parent.width
    clip: true
    interactive: true
    opacity:  1

    property PeopleModel dataModel: newContactModel

    property string contextHome: qsTr("Home")
    property string contextWork: qsTr("Work")
    property string contextOther: qsTr("Other")
    property string contextMobile: qsTr("Mobile")
    property string defaultFirstName: qsTr("First name")
    property string defaultPronounciation: qsTr("Pronounciation")
    property string defaultLastName: qsTr("Last name")
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string defaultBirthday: qsTr("Enter birthday")
    property string headerBirthday: qsTr("Birthday")
    property string headerNote: qsTr("Note")

    property string favoriteValue: "Favorite"
    property string unfavoriteValue: "Unfavorite"
    
    //: Remove favorite flag / remove contact from favorites list
    property string unfavoriteTranslated: qsTr("Unfavorite")

    //: Add favorite flag / add contact to favorites list
    property string favoriteTranslated: qsTr("Favorite", "Verb")

    property string phoneLabel: qsTr("Phone numbers")
    property string addPhones: qsTr("Add number")
    property string imLabel: qsTr("Instant messaging")
    property string emailLabel: qsTr("Email")
    property string addEmails: qsTr("Add email address")
    property string urlLabel: qsTr("Web")
    property string addUrls: qsTr("Add web page")
    property string addressLabel: qsTr("Address")
    property string addAddress: qsTr("Add address")

    property bool validInput: false

    function finishPageLoad() {
        phones.loadExpandingBox(null, null);
        emails.loadExpandingBox(null, null);
        urls.loadExpandingBox(null, null);
        addys.loadExpandingBox(null, null);
    }

    function contactSave(){
        var newPhones = phones.getNewDetails();
        var newEmails = emails.getNewDetails();
        var newWebs = urls.getNewDetails();
        var addresses = addys.getNewDetails();
        var avatar = ""
        var thumburi = ""

        var ret = peopleModel.createPersonModel(avatar, thumburi,
                                                data_first.text, data_first_p.text,
                                                data_last.text, data_last_p.text,
                                                data_company.text,
                                                newPhones["numbers"], newPhones["types"],
                                                (icn_faves.state == favoriteValue),
                                                "", "",
                                                newEmails["emails"], newEmails["types"],
                                                addresses["streets"], addresses["locales"],
                                                addresses["regions"], addresses["zips"],
                                                addresses["countries"], addresses["types"],
                                                newWebs["urls"], newWebs["types"],
                                                "", data_notes.text);

        if (!ret) //REVISIT
            console.log("[contactSave] Unable to create new contact due to missing info");
    }

    Rectangle {
        id: detailsRect
        width: parent.width
        height: parent.height
        color: "white"

    Column{
        id: detailsList
        spacing: 1
        width: parent.width
        //REVISIT: anchors {left:parent.left; right: parent.right; leftMargin:10; rightMargin:10;}
        Image{
            id: detailHeader
            width: parent.width
            height: (data_first_p.visible ? 175 : 150)
            source: "image://themedimage/widgets/common/header/header-inverted-small"

            Item{
                id: avatar
                width: 150
                height: 150
                anchors {top: detailHeader.top; left: parent.left; }

                LimitedImage{
                    id: avatar_img
                    source: "image://themedimage/icons/internal/contacts-avatar-add"
                    anchors.centerIn: avatar
                    opacity: 1
                    signal clicked
                    width: 100
                    height: 100
                    smooth:  true
                    clip: true
                    state: "default"
                    fillMode: Image.PreserveAspectCrop

                    MouseArea{
                        id: mouseArea_avatar_img
                        anchors.fill: parent
                        onClicked:{
                            console.log("photo picker, TODO")
                        }
                        onPressed: {
                            avatar.opacity = .5;
                            avatar_img.source = (avatar_img.source == "image://themedimage/icons/internal/contacts-avatar-add" ? "image://themedimage/icons/internal/contacts-avatar-add-selected" : avatar_img.source)
                        }
                    }
                }
            }
            Grid{
                id: headerGrid
                columns: 2
                rows: 2
                anchors{ left: avatar.right; right: detailHeader.right; verticalCenter: detailHeader.verticalCenter}
                Item{
                    id: quad1
                    width: headerGrid.width/2
                    height: (data_first_p.visible ? childrenRect.height : data_first.height)
                    TextField {
                        id: data_first
                        placeholderText: defaultFirstName
                        width: (parent.width-avatar.width)
                        anchors {top: parent.top;
                                 left: parent.left; leftMargin: 20;
                                 right: parent.right; rightMargin: 10}
                    }
                    TextField {
                        id: data_first_p
                        text: ""
                        placeholderText: defaultPronounciation
                        width: (parent.width - avatar.width)
                        anchors {top: data_first.bottom; topMargin: 10;
                                 left: parent.left; leftMargin: 20;
                                 right: parent.right; rightMargin: 10}
                        visible: localeUtils.needPronounciationFields()
                    }
                }
                Item{
                    id: quad2
                    width: headerGrid.width/2
                    height: (data_last_p.visible ? childrenRect.height : data_last.height)
                    TextField {
                        id: data_last
                        placeholderText: defaultLastName
                        width:(parent.width-avatar.width)
                        anchors {top: parent.top;
                                 left: parent.left; leftMargin: 10;
                                 right: parent.right; rightMargin: 20}
                    }
                    TextField {
                        id: data_last_p
                        text: ""
                        placeholderText: defaultPronounciation
                        width: (parent.width - avatar.width)
                        anchors {top: data_last.bottom; topMargin: 10;
                                 left: parent.left; leftMargin: 10;
                                 right: parent.right; rightMargin: 20}
                        visible: localeUtils.needPronounciationFields()
                    }
                }
                Item{
                    id: quad3
                    width: headerGrid.width/2
                    height: childrenRect.height
                    TextField {
                        id: data_company
                        placeholderText: defaultCompany
                        width:(parent.width-avatar.width)
                        anchors{ top: parent.top; topMargin: 10; left: parent.left; leftMargin: 20; right: parent.right; rightMargin: 10;}
                    }
                }
                Item{
                    id: quad4
                    width: headerGrid.width/2
                    height: childrenRect.height
                    Item{
                        anchors{ top: parent.top; topMargin: 10; left: parent.left; leftMargin: 10}
                        width: childrenRect.width
                        height: childrenRect.height
                        Image {
                            id: icn_faves
                            source: "image://themedimage/icons/actionbar/favorite-selected"
                            opacity: 1
                            state: unfavoriteValue

                            property string favoriteText: unfavoriteTranslated
                            states: [
                                State{ name: favoriteValue
                                    PropertyChanges{target: icn_faves; favoriteText: favoriteTranslated}
                                    PropertyChanges{target: icn_faves; source: "image://themedimage/icons/actionbar/favorite-selected"}
                                },
                                State{ name: unfavoriteValue
                                    PropertyChanges{target: icn_faves; favoriteText: unfavoriteTranslated}
                                    PropertyChanges{target: icn_faves; source: "image://themedimage/icons/actionbar/favorite"}
                                }
                            ]
                        }
                    }
                    MouseArea{
                        id: fav
                        anchors.fill: parent
                        onClicked: {
                            icn_faves.state = (icn_faves.source != "image://themedimage/icons/actionbar/favorite-selected" ? favoriteValue : unfavoriteValue)
                        }
                    }
                }
            }
        }

        ContactsExpandableDetails {
            id: phones

            headerLabel: phoneLabel
            expandingBoxTitle: addPhones
            newDetailsComponent: PhoneEditWidget{}
            existingDetailsComponent: PhoneEditWidget{}
        }

        ContactsExpandableDetails {
            id: emails 

            headerLabel: emailLabel
            expandingBoxTitle: addEmails
            newDetailsComponent: EmailEditWidget{}
            existingDetailsComponent: EmailEditWidget{}
        }

        ContactsExpandableDetails {
            id: urls 

            headerLabel: urlLabel
            expandingBoxTitle: addUrls
            newDetailsComponent: WebPageEditWidget{}
            existingDetailsComponent: WebPageEditWidget{}
        }

        ContactsExpandableDetails {
            id: addys 

            headerLabel: addressLabel
            expandingBoxTitle: addAddress
            newDetailsComponent: AddressEditWidget{}
            existingDetailsComponent: AddressEditWidget{}
        }

        Item{
            id: birthdayHeader
            width: parent.width
            height: 70
            opacity: 1

            Text{
                id: label_birthday
                text: headerBirthday
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorInactive
                smooth: true
                anchors {bottom: birthdayHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }

        Image{
            id: birthday
            width: parent.width
            height: 80
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            TextField {
                id: data_birthday
                text: ""
                placeholderText: defaultBirthday
                anchors {verticalCenter: birthday.verticalCenter; left: parent.left; topMargin: 30; leftMargin: 30; right: delete_button.left; rightMargin: 30}
                MouseArea{
                    id: mouse_birthday
                    anchors.fill: parent
                    onClicked: {
                        console.log("datepicker, TODO")
                    }
                }
                states: [
                    State{ name: "default"
                        PropertyChanges{target: data_birthday; text: defaultBirthday}
                        PropertyChanges{target: data_birthday; color: theme_fontColorInactive}
                    },
                    State{ name: "edit"
                        PropertyChanges{target: data_birthday; text: ""}
                        PropertyChanges{target: data_birthday; color: theme_fontColorNormal}
                    }
                ]
            }
            Image {
                id: delete_button
                source: "image://themedimage/icons/internal/contact-information-delete"
                width: 36
                height: 36
                anchors {verticalCenter: birthday.verticalCenter; right: parent.right; rightMargin: 10}
                opacity: 1
                MouseArea {
                    id: mouse_delete
                    anchors.fill: parent
                    onPressed: {
                        delete_button.source = "image://themedimage/icons/internal/contact-information-delete-active"
                    }
                    onClicked: {
                        data_birthday.text = "";
                    }
                }
                Binding{target: delete_button; property: "visible"; value: true; when: data_birthday.text != ""}
                Binding{target: delete_button; property: "visible"; value: false; when: data_birthday.text == ""}
            }
        }

        /*
        DatePicker {
            id:datePicker
            parent: newContactPage

            property date datePicked
            property string selectedBirthday: Qt.formatDate(newContactPage.restoredBirthday, window.dateFormat)

            onDateSelected: {
                datePicked = selectedDate;
                selectedBirthday = Qt.formatDate(selectedDate, window.dateFormat);
                data_birthday.state = (data_birthday.state == "default" ? "edit" : data_birthday.state)
            }

            Component.onCompleted: {
                if (newContactPage.restoredBirthday != "")
                    selectedDate: newContactPage.restoredBirthday
            }
        }
        */

        Item{
            id: notesHeader
            width: parent.width
            height: 70
            opacity: 1

            Text{
                id: label_notes
                text: headerNote
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_fontColorInactive
                smooth: true
                anchors {bottom: notesHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }

        Image{
            id: notesBar
            width: parent.width
            height: 340
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            TextField{
                id: data_notes
                text: newContactPage.restoredNotes
                placeholderText: defaultNote
                width:540
                height: 300
                anchors {top: parent.top; left: parent.left; topMargin: 20; leftMargin: 30}
            }
        }
    }
    }
    Binding{ target: newContactPage; property: "validInput"; value: true; when: {
            ((data_first.text != "")||(data_last.text != "")||(data_company.text != "")||(phones.validInput)||(emails.validInput)||(urls.validInput)||(addys.validInput)||(data_birthday.text != "")||(data_notes.text != ""))
        }
    }
    Binding{ target: newContactPage; property: "validInput"; value: false; when: {
            ((data_first.text == "")&&(data_last.text == "")&&(data_company.text == "")&&(!phones.validInput)&&(!emails.validInput)&&(!urls.validInput)&&(!addys.validInput)&&(data_birthday.text == "")&&(data_notes.text == ""))
        }
    }
}

