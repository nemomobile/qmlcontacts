/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.App.Contacts 0.1
import MeeGo.Media 0.1
import MeeGo.App.IM 0.1
import TelepathyQML 0.1

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
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string defaultBirthday: qsTr("Enter birthday")
    property string headerBirthday: qsTr("Birthday")
    property string headerNote: qsTr("Note")

    property string favoriteValue: "Favorite"
    property string favoriteTranslated: qsTr("Favorite")
    property string unfavoriteValue: "Unfavorite"
    property string unfavoriteTranslated: qsTr("Unfavorite")

    function contactSave(contactId){
        var addresses = addys.getNewAddresses();
        var newPhones = phones.getNewPhones();
        var newIms = ims.getNewIms();
        var newWebs = urls.getNewUrls();
        var newEmails = emails.getNewEmails();

        if (avatar_img.source == "image://theme/contacts/img_blankavatar")
            avatar_img.source = "";

                peopleModel.editPersonModel(contactId, avatar_img.source, data_first.text, data_last.text, data_company.text, newPhones["numbers"], newPhones["types"],
                                              icn_faves.favoriteText, newIms["ims"], newIms["types"],
                                              newEmails["emails"], newEmails["types"], addresses["streets"], addresses["locales"], addresses["regions"],
                                              addresses["zips"], addresses["countries"], addresses["types"],
                                              newWebs["urls"], newWebs["types"], datePicker.selectedDate, data_notes.text);
    }

    Column{
        id: editList
        spacing: 1
        anchors {left:parent.left; right: parent.right; leftMargin:10; rightMargin:10;}
        Image{
            id: editHeader
            width: parent.width
            height: 150
            source: "image://theme/contacts/active_row"
            anchors.bottomMargin: 1
            Item{
                id: avatar
                width: 150
                height: 150
                anchors {top: editHeader.top; left: parent.left; }

                Image{
                    id: avatar_img
                    //REVISIT: Instead of using the URI from AvatarRole, need to use thumbnail URI
                    source: (dataModel.data(index, PeopleModel.AvatarRole) ? dataModel.data(index, PeopleModel.AvatarRole) : "image://theme/contacts/img_blankavatar")
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
                            photoPicker.visible = true;
                        }
                        onPressed: {
                            avatar.opacity = .5;
                            avatar_img.source = (avatar_img.source == "image://theme/contacts/img_blankavatar" ? "image://theme/contacts/img_blankavatar_dn" : avatar_img.source)
                        }
                    }
                }
            }

            PhotoPicker {
                id: photoPicker
                parent: scene
                property string selectedPhoto

                albumSelectionMode: false
                onPhotoSelected: {
                    selectedPhoto = uri.split("file://")[1];
                }

                onClosed: {
                    if (selectedPhoto)
                    {
                        avatar_img.source = selectedPhoto
                        avatar.opacity = 1;
                    }
                }
            }

            Grid{
                id: headerGrid
                columns:  2
                rows: 2
                anchors{ left: avatar.right; right: editHeader.right; top: editHeader.top; bottom: editHeader.bottom}
                Item{
                    id: quad1
                    width: headerGrid.width/2
                    height: headerGrid.height/2
                    TextEntry{
                        id: data_first
                        text: dataModel.data(index, PeopleModel.FirstNameRole)
                        defaultText: defaultFirstName
                        width: (parent.width-avatar.width)
                        anchors{verticalCenter: quad1.verticalCenter; right: quad1.right; left: quad1.left; leftMargin: 20; rightMargin: 10}
                    }
                }
                Item{
                    id: quad2
                    width: headerGrid.width/2
                    height: headerGrid.height/2
                    TextEntry{
                        id: data_last
                        text: dataModel.data(index, PeopleModel.LastNameRole)
                        defaultText: defaultLastName
                        width:(parent.width-avatar.width)
                        anchors{ verticalCenter: quad2.verticalCenter; left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 20}
                    }
                }
                Item{
                    id: quad3
                    width: headerGrid.width/2
                    height: headerGrid.height/2
                    TextEntry{
                        id: data_company
                        text: dataModel.data(index, PeopleModel.CompanyNameRole)
                        defaultText: defaultCompany
                        width:(parent.width-avatar.width)
                        anchors{ verticalCenter: quad3.verticalCenter; left: parent.left; leftMargin: 20; right: parent.right; rightMargin: 10;}
                    }
                }
                Item{
                    id: quad4
                    width: headerGrid.width/2
                    height: headerGrid.height/2
                    Item{
                        anchors{  verticalCenter: quad4.verticalCenter; left: parent.left; leftMargin: 10}
                        width: childrenRect.width
                        height: childrenRect.height
                        Image {
                            id: icn_faves
                            source: (dataModel.data(index, PeopleModel.FavoriteRole) == favoriteValue ? "image://theme/contacts/icn_fav_star_dn" : "image://theme/contacts/icn_fav_star" )
                            opacity: 1

                            state: (dataModel.data(index, PeopleModel.FavoriteRole) == favoriteValue ? favoriteValue: unfavoriteValue)
                            property string favoriteText: unfavoriteTranslated

                            states: [
                                State{ name: favoriteValue
                                    PropertyChanges{target: icn_faves; favoriteText: favoriteTranslated}
                                    PropertyChanges{target: icn_faves; source: "image://theme/contacts/icn_fav_star_dn"}
                                },
                                State{ name: unfavoriteValue
                                    PropertyChanges{target: icn_faves; favoriteText: unfavoriteTranslated}
                                    PropertyChanges{target: icn_faves; source: "image://theme/contacts/icn_fav_star"}
                                }
                            ]
                        }
                    }
                    MouseArea{
                        id: fav
                        anchors.fill: parent
                        onClicked: {
                            icn_faves.state = (icn_faves.source != "image://theme/contacts/icn_fav_star_dn" ? favoriteValue : unfavoriteValue)
                        }
                    }
                }
            }
        }

        PhoneEditWidget{
            id:phones
            width: parent.width
            height: childrenRect.height
            phoneModel: dataModel.data(index, PeopleModel.PhoneNumberRole)
            contextModel: dataModel.data(index, PeopleModel.PhoneContextRole)
            anchors {top: editHeader.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        ImEditWidget{
            id:ims
            width: parent.width
            height: childrenRect.height
            imModel: dataModel.data(index, PeopleModel.OnlineAccountUriRole)
            contextModel: dataModel.data(index, PeopleModel.OnlineServiceProviderRole)
            anchors {top: phones.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        EmailEditWidget{
            id:emails
            width: parent.width
            height: childrenRect.height
            emailModel: dataModel.data(index, PeopleModel.EmailAddressRole)
            contextModel: dataModel.data(index, PeopleModel.EmailContextRole)
            anchors {top: ims.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        WebPageEditWidget{
            id:urls
            width: parent.width
            height: childrenRect.height
            webModel: dataModel.data(index, PeopleModel.WebUrlRole)
            contextModel: dataModel.data(index, PeopleModel.WebContextRole)
            anchors {top: emails.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        AddressEditWidget{
            id:addys
            width: parent.width
            height: childrenRect.height
            addressModel: dataModel.data(index, PeopleModel.AddressRole)
            contextModel: dataModel.data(index, PeopleModel.AddressContextRole)
            anchors {top: urls.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        Item{
            id: birthdayHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(index, PeopleModel.BirthdayRole).length > 0 ? 1: 0)

            Text{
                id: label_birthday
                text: defaultBirthday
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_iconfontBackgroundcolor
                smooth: true
                anchors {bottom: birthdayHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }
        Image{
            id: birthday
            width: parent.width
            height: 80
            source: "image://theme/contacts/active_row"
            anchors.bottomMargin: 1
            TextEntry{
                id: data_birthday
                text: dataModel.data(index, PeopleModel.BirthdayRole)
                defaultText: defaultBirthday
                width:540
                anchors {verticalCenter: birthday.verticalCenter; left: parent.left; topMargin: 30; leftMargin: 30}
                MouseArea{
                    id: mouse_birthday
                    anchors.fill: parent
                    onClicked: {
                        var map = mapToItem (scene.content, mouseX, mouseY);
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
                        PropertyChanges{target: data_birthday; color: theme_iconfontBackgroundcolor}
                    }
                ]
            }
        }
        DatePickerDialog {
            id:datePicker
            parent: newContactPage

            property date selectedDate
            property string selectedBirthday

            onTriggered: {
                selectedDate = date;
                selectedBirthday = Qt.formatDate(date, "d MMMM yyyy");
            }

            onClosed: {
                data_birthday.text = datePicker.selectedBirthday;
                data_birthday.state = (data_birthday.state == "default" ? "edit" : data_birthday.state)
            }
        }

        Item{
            id: notesHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(index, PeopleModel.NotesRole).length > 0 ? 1: 0)

            Text{
                id: label_notes
                text: notesLabel
                color: theme_fontColorNormal
                font.pixelSize: theme_fontPixelSizeLarge
                styleColor: theme_iconfontBackgroundcolor
                smooth: true
                anchors {bottom: notesHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }
        Image{
            id: notesBar
            width: parent.width
            height: 340
            source: "image://theme/contacts/active_row"
            anchors.bottomMargin: 1
            TextEntry{
                id: data_notes
                text: dataModel.data(index, PeopleModel.NotesRole)
                defaultText: defaultNote
                width:540
                height: 300
                anchors {top: parent.top; left: parent.left; topMargin: 30; leftMargin: 30}
            }
        }
    }
    Binding{ target: editViewPortrait; property: "validInput"; value: true; when: {
            ((data_first.text != "")||(data_last.text != "")||(data_company.text != "")||(phones.validInput)||(ims.validInput)||(emails.validInput)||(urls.validInput)||(addys.validInput)||(data_birthday.text != "")||(data_notes.text != ""))
        }
    }
    Binding{ target: editViewPortrait; property: "validInput"; value: false; when: {
            ((data_first.text == "")&&(data_last.text == "")&&(data_company.text == "")&&(!phones.validInput)&&(!ims.validInput)&&(!emails.validInput)&&(!urls.validInput)&&(!addys.validInput)&&(data_birthday.text == "")&&(data_notes.text == ""))
        }
    }
}
