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

Flickable {
    id: editViewPortrait
    contentWidth: parent.width
    contentHeight: editList.height
    flickableDirection: Flickable.VerticalFlick
    anchors.horizontalCenter:  parent.horizontalCenter
    height: parent.width
    width: parent.width
    clip: true
    interactive: true
    opacity: 1

    property PeopleModel dataModel: contactModel
    property int index: personRow
    property bool validInput: false

    property string contextHome: qsTr("Home")
    property string contextWork: qsTr("Work")
    property string contextOther: qsTr("Other")
    property string contextMobile: qsTr("Mobile")
    property string defaultFirstName: qsTr("First name")
    property string defaultLastName: qsTr("Last name")
    property string defaultPronounciation: qsTr("Pronounciation")
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string defaultBirthday: qsTr("Enter birthday")
    property string headerBirthday: qsTr("Birthday")
    property string headerNote: qsTr("Note")

    property string favoriteValue: "Favorite"
    property string unfavoriteValue: "Unfavorite"

    //: Add favorite flag / add contact to favorites list
    property string favoriteTranslated: qsTr("Favorite", "Verb")

    //: Remove favorite flag / remove contact from favorites list
    property string unfavoriteTranslated: qsTr("Unfavorite")

    property string phoneLabel: qsTr("Phone numbers")
    property string addPhones: qsTr("Add number")

    //: Instant Messaging Accounts for this contact
    property string imLabel: qsTr("Instant messaging")
    property string emailLabel: qsTr("Email")
    property string addEmails: qsTr("Add email address")

    //: The header for the section that shows the web sites for this contact
    property string urlLabel: qsTr("Web")
    property string addUrls: qsTr("Add web page")
    property string addressLabel: qsTr("Address")
    property string addAddress: qsTr("Add address")

    function finishPageLoad() {
        var detailData = dataModel.data(index, PeopleModel.PhoneNumberRole);
        var contextData = dataModel.data(index, PeopleModel.PhoneContextRole);
        phones.loadExpandingBox(detailData, contextData);

        detailData = dataModel.data(index, PeopleModel.OnlineAccountUriRole);
        contextData = dataModel.data(index, PeopleModel.OnlineServiceProviderRole);

        detailData = dataModel.data(index, PeopleModel.EmailAddressRole);
        contextData = dataModel.data(index, PeopleModel.EmailContextRole);
        emails.loadExpandingBox(detailData, contextData);

        detailData = dataModel.data(index, PeopleModel.WebUrlRole);
        contextData = dataModel.data(index, PeopleModel.WebContextRole);
        urls.loadExpandingBox(detailData, contextData);

        detailData = dataModel.data(index, PeopleModel.AddressRole);
        contextData = dataModel.data(index, PeopleModel.AddressContextRole);
        addys.loadExpandingBox(detailData, contextData);
    }

    function getFavoriteState() {
        if (dataModel.data(index, PeopleModel.FavoriteRole))
            return favoriteValue;
        return unfavoriteValue;
    }

    function contactSave(contactId){
        var newPhones = phones.getNewDetails();
        var newEmails = emails.getNewDetails();
        var newWebs = urls.getNewDetails();
        var addresses = addys.getNewDetails();

        if (avatar_img.source == "image://themedimage/icons/internal/contacts-avatar-add")
            avatar_img.source = "";
            
                peopleModel.editPersonModel(contactId, avatar_img.source,
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
                                            "TODO date here", data_notes.text);
    }

    Rectangle {
        id: editDetailsRect
        width: parent.width
        height: parent.height
        color: "white"

    Column{
        id: editList
        spacing: 1
        anchors {left:parent.left; right: parent.right; leftMargin:10; rightMargin:10;}
        Image{
            id: editHeader
            width: parent.width
            height: (data_first_p.visible ? 175 : 150)
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            opacity:  (dataModel.data(index, PeopleModel.IsSelfRole) ? .5 : 1)
            Item{
                id: avatar
                width: 150
                height: 150
                anchors {top: editHeader.top; left: parent.left; }

                LimitedImage{
                    id: avatar_img
                    //REVISIT: Instead of using the URI from AvatarRole, need to use thumbnail URI
                    source: (dataModel.data(index, PeopleModel.AvatarRole) ? dataModel.data(index, PeopleModel.AvatarRole) : "image://themedimage/icons/internal/contacts-avatar-add")
                    anchors.centerIn: avatar
                    opacity: 1
                    signal clicked
                    width: avatar.width
                    height: avatar.height
                    smooth:  true
                    clip: true
                    state: "default"
                    fillMode: Image.PreserveAspectCrop

                    MouseArea{
                        id: mouseArea_avatar_img
                        anchors.fill: parent
                        onClicked:{
                            console.log("no photopicker component written, TODO");
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
                columns:  2
                rows: 2
                anchors{ left: avatar.right; right: editHeader.right; verticalCenter: editHeader.verticalCenter}
                Item{
                    id: quad1
                    width: headerGrid.width/2
                    height: (data_first_p.visible ? childrenRect.height : data_first.height)
                    TextField {
                        id: data_first
                        text: (dataModel.data(index, PeopleModel.FirstNameRole) ? dataModel.data(index, PeopleModel.FirstNameRole) : "")
                        placeholderText: defaultFirstName
                        width: (parent.width-avatar.width)
                        anchors {top: parent.top;
                                 left: parent.left; leftMargin: 20;
                                 right: parent.right; rightMargin: 10}
                    }
                    TextField {
                        id: data_first_p
                        text: dataModel.data(index, PeopleModel.FirstNameProRole) ? dataModel.data(index, PeopleModel.FirstNameProRole) : ""
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
                        text: (dataModel.data(index, PeopleModel.LastNameRole) ? dataModel.data(index, PeopleModel.LastNameRole) : "")
                        placeholderText: defaultLastName
                        width:(parent.width-avatar.width)
                        anchors {top: parent.top;
                                 left: parent.left; leftMargin: 10;
                                 right: parent.right; rightMargin: 20}
                    }
                    TextField {
                        id: data_last_p
                        text: dataModel.data(index, PeopleModel.LastNameProRole) ? dataModel.data(index, PeopleModel.LastNameProRole) : ""
                        placeholderText: defaultPronounciation
                        width: (parent.width-avatar.width)
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
                        text: (dataModel.data(index, PeopleModel.CompanyNameRole) ? dataModel.data(index, PeopleModel.CompanyNameRole) : "")
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
                            source: (dataModel.data(index, PeopleModel.FavoriteRole) ? "image://themedimage/icons/actionbar/favorite-selected" : "image://themedimage/icons/actionbar/favorite" )
                            opacity: (dataModel.data(index, PeopleModel.IsSelfRole) ? 0 : 1)

                            state: getFavoriteState()
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
            opacity:  1

            Text{
                id: label_birthday
                text: defaultBirthday
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
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
                text: dataModel.data(index, PeopleModel.BirthdayRole) ? dataModel.data(index, PeopleModel.BirthdayRole) : ""
                placeholderText: defaultBirthday
                anchors {verticalCenter: birthday.verticalCenter; left: parent.left; topMargin: 30; leftMargin: 30; right: delete_button.left; rightMargin: 30}
                MouseArea{
                    id: mouse_birthday
                    anchors.fill: parent
                    onClicked: {
                        console.log("TODO: date picker");
                    }
                }
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
                smooth: true
                anchors {bottom: notesHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }

        Image{
            id: notesBar
            width: parent.width
            height: 340
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            anchors.bottomMargin: 1
            TextField{
                id: data_notes
                text: (dataModel.data(index, PeopleModel.NotesRole) ? dataModel.data(index, PeopleModel.NotesRole) : "")
                placeholderText: defaultNote
                height: 300
                anchors {top: parent.top; left: parent.left; right: parent.right; rightMargin: 30; topMargin: 20; leftMargin: 30}
            }
        }
    }
    }
    Binding{ target: editViewPortrait; property: "validInput"; value: true; when: {
            ((data_first.text != "")||(data_last.text != "")||(data_company.text != "")||(phones.validInput)||(emails.validInput)||(urls.validInput)||(addys.validInput)||(data_birthday.text != "")||(data_notes.text != ""))
        }
    }
    Binding{ target: editViewPortrait; property: "validInput"; value: false; when: {
            ((data_first.text == "")&&(data_last.text == "")&&(data_company.text == "")&&(!phones.validInput)&&(!emails.validInput)&&(!urls.validInput)&&(!addys.validInput)&&(data_birthday.text == "")&&(data_notes.text == ""))
        }
    }
}

