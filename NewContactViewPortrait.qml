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
import MeeGo.Media 0.1

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

    property string parentTitle: parent.pageTitle ? parent.pageTitle : ""

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
    property string addIms: qsTr("Add account")
    property string emailLabel: qsTr("Email")
    property string addEmails: qsTr("Add email address")
    property string urlLabel: qsTr("Web")
    property string addUrls: qsTr("Add web page")
    property string addressLabel: qsTr("Address")
    property string addAddress: qsTr("Add address")

    property bool validInput: false
    property string restoredFirstName: ""
    property string restoredLastName: ""
    property string restoredCompany: ""
    property string restoredNotes: ""
    property string restoredPhoto: ""
    property string restoredFavorite: ""
    property date restoredBirthday

    SaveRestoreState {
        id: justRestore
        onSaveRequired: sync()
    }

    Component.onCompleted: {
        if(justRestore.restoreRequired){
            restoredFirstName       = justRestore.restoreOnce(parentTitle + ".contact.firstName", "")
            restoredLastName        = justRestore.restoreOnce(parentTitle + ".contact.lastName", "")
            restoredCompany         = justRestore.restoreOnce(parentTitle + ".contact.company", "")
            restoredNotes           = justRestore.restoreOnce(parentTitle + ".contact.notes", "")
            restoredPhoto           = justRestore.restoreOnce(parentTitle + ".contact.photo", "")
            restoredFavorite        = justRestore.restoreOnce(parentTitle + ".contact.favorite", "")
            restoredBirthday        = justRestore.restoreOnce(parentTitle + ".contact.birthday", "")
        }
    }


    function finishPageLoad() {
        phones.loadExpandingBox();
        ims.loadExpandingBox();
        emails.loadExpandingBox();
        urls.loadExpandingBox();
        addys.loadExpandingBox();
    }

    function contactSave(){
        var newPhones = phones.getNewDetails();
        var newIms = ims.getNewDetails();
        var newEmails = emails.getNewDetails();
        var newWebs = urls.getNewDetails();
        var addresses = addys.getNewDetails();
        var avatar = photoPicker.selectedPhoto
        var thumburi = photoPicker.selectedPhotoThumb

        var ret = peopleModel.createPersonModel(avatar, thumburi,
                                                data_first.text, data_first_p.text,
                                                data_last.text, data_last_p.text,
                                                data_company.text,
                                                newPhones["numbers"], newPhones["types"],
                                                (icn_faves.state == favoriteValue),
                                                newIms["ims"], newIms["types"],
                                                newEmails["emails"], newEmails["types"],
                                                addresses["streets"], addresses["locales"],
                                                addresses["regions"], addresses["zips"],
                                                addresses["countries"], addresses["types"],
                                                newWebs["urls"], newWebs["types"],
                                                datePicker.datePicked, data_notes.text);

        if (!ret) //REVISIT
            console.log("[contactSave] Unable to create new contact due to missing info");
    }

    function restoreData(){
        phones.restoreData()
    }

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

                Image{
                    id: avatar_img
                    source: restoredPhoto != "" ? restoredPhoto : "image://themedimage/icons/internal/contacts-avatar-add"
                    anchors.centerIn: avatar
                    opacity: 1
                    signal clicked
                    width: (photoPicker.selectedPhoto ? 150 : 100)
                    height: (photoPicker.selectedPhoto ? 150 : 100)
                    smooth:  true
                    clip: true
                    state: "default"
                    fillMode: Image.PreserveAspectCrop

                    MouseArea{
                        id: mouseArea_avatar_img
                        anchors.fill: parent
                        onClicked:{
                            photoPicker.show();
                        }
                        onPressed: {
                            avatar.opacity = .5;
                            avatar_img.source = (avatar_img.source == "image://themedimage/icons/internal/contacts-avatar-add" ? "image://themedimage/icons/internal/contacts-avatar-add-selected" : avatar_img.source)
                        }
                    }
                }
            }
            PhotoPicker {
                id: photoPicker
                property string selectedPhoto
                property string selectedPhotoThumb

                albumSelectionMode: false
                onPhotoSelected: {
                    selectedPhoto = uris ? uris[0] : ""
                    selectedPhotoThumb = (thumbUris ? thumbUris[0] : selectedPhoto);
                    newContactPage.validInput = true;
                    if (selectedPhoto)
                    {
                        avatar_img.source = selectedPhotoThumb;
                        avatar.opacity = 1;
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
                    TextEntry{
                        id: data_first
                        text: newContactPage.restoredFirstName
                        defaultText: defaultFirstName
                        width: (parent.width-avatar.width)
                        anchors {top: parent.top;
                                 left: parent.left; leftMargin: 20;
                                 right: parent.right; rightMargin: 10}
                    }
                    TextEntry{
                        id: data_first_p
                        text: ""
                        defaultText: defaultPronounciation
                        width: (parent.width - avatar.width)
                        anchors {top: data_first.bottom; topMargin: 10;
                                 left: parent.left; leftMargin: 20;
                                 right: parent.right; rightMargin: 10}
                        visible: localeUtils.needPronounciationFields()
                    }

		    SaveRestoreState {
			id: srsMainView
			onSaveRequired: {
                            setValue(parentTitle + ".contact.firstName", data_first.text)
                            setValue(parentTitle + ".contact.lastName", data_last.text)
                            setValue(parentTitle + ".contact.company",data_company.text)
                            setValue(parentTitle + ".contact.photo", avatar_img.source)
                            setValue(parentTitle + ".contact.birthday", datePicker.selectedDate)
                            setValue(parentTitle + ".contact.notes",data_notes.text)
                            setValue(parentTitle + ".contact.favorite",icn_faves.state)
			    sync()
			}
		    }
                }
                Item{
                    id: quad2
                    width: headerGrid.width/2
                    height: (data_last_p.visible ? childrenRect.height : data_last.height)
                    TextEntry{
                        id: data_last
                        text: newContactPage.restoredLastName
                        defaultText: defaultLastName
                        width:(parent.width-avatar.width)
                        anchors {top: parent.top;
                                 left: parent.left; leftMargin: 10;
                                 right: parent.right; rightMargin: 20}
                    }
                    TextEntry{
                        id: data_last_p
                        text: ""
                        defaultText: defaultPronounciation
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
                    TextEntry{
                        id: data_company
                        text: newContactPage.restoredCompany
                        defaultText: defaultCompany
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
                            state: restoredFavorite == "" ? unfavoriteValue : restoredFavorite

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
            newDetailsComponent: PhoneEditWidget{
                prefixSaveRestore: parentTitle
            }
            existingDetailsComponent: PhoneEditWidget{
                prefixSaveRestore: parentTitle
            }
        }

        ContactsExpandableDetails {
            id: ims 

            headerLabel: imLabel
            expandingBoxTitle: addIms
            newDetailsComponent: ImEditWidget{
                prefixSaveRestore: parentTitle
            }
            existingDetailsComponent: ImEditWidget{
                prefixSaveRestore: parentTitle
            }
        }

        ContactsExpandableDetails {
            id: emails 

            headerLabel: emailLabel
            expandingBoxTitle: addEmails
            newDetailsComponent: EmailEditWidget{
                prefixSaveRestore: parentTitle
            }
            existingDetailsComponent: EmailEditWidget{
                prefixSaveRestore: parentTitle
            }
        }

        ContactsExpandableDetails {
            id: urls 

            headerLabel: urlLabel
            expandingBoxTitle: addUrls
            newDetailsComponent: WebPageEditWidget{
                prefixSaveRestore: parentTitle
            }
            existingDetailsComponent: WebPageEditWidget{
                prefixSaveRestore: parentTitle
            }
        }

        ContactsExpandableDetails {
            id: addys 

            headerLabel: addressLabel
            expandingBoxTitle: addAddress
            newDetailsComponent: AddressEditWidget{
                prefixSaveRestore: parentTitle
            }
            existingDetailsComponent: AddressEditWidget{
                prefixSaveRestore: parentTitle
            }
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
            TextEntry{
                id: data_birthday
                text: datePicker.selectedBirthday
                defaultText: defaultBirthday
                anchors {verticalCenter: birthday.verticalCenter; left: parent.left; topMargin: 30; leftMargin: 30; right: delete_button.left; rightMargin: 30}
                MouseArea{
                    id: mouse_birthday
                    anchors.fill: parent
                    onClicked: {
                        var map = mapToItem (window.content, mouseX, mouseY);
                        datePicker.show(map.x, map.y)
                    }
                }
                states: [
                    State{ name: "default"
                        PropertyChanges{target: data_birthday; text: defaultBirthday}
                        PropertyChanges{target: data_birthday; color: theme_fontColorInactive}
                    },
                    State{ name: "edit"
                        PropertyChanges{target: data_birthday; text: datePicker.selectedBirthday}
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
                defaultText: defaultNote
                width:540
                height: 300
                anchors {top: parent.top; left: parent.left; topMargin: 20; leftMargin: 30}
            }
        }
    }
    Binding{ target: newContactPage; property: "validInput"; value: true; when: {
            ((data_first.text != "")||(data_last.text != "")||(data_company.text != "")||(phones.validInput)||(ims.validInput)||(emails.validInput)||(urls.validInput)||(addys.validInput)||(data_birthday.text != "")||(data_notes.text != ""))
        }
    }
    Binding{ target: newContactPage; property: "validInput"; value: false; when: {
            ((data_first.text == "")&&(data_last.text == "")&&(data_company.text == "")&&(!phones.validInput)&&(!ims.validInput)&&(!emails.validInput)&&(!urls.validInput)&&(!addys.validInput)&&(data_birthday.text == "")&&(data_notes.text == ""))
        }
    }
}

