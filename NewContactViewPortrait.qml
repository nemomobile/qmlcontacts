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
    property string defaultLastName: qsTr("Last name")
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string defaultBirthday: qsTr("Enter birthday")
    property string headerBirthday: qsTr("Birthday")
    property string headerNote: qsTr("Note")

    property string favoriteValue: "Favorite"
    property string unfavoriteValue: "Unfavorite"
    property string unfavoriteTranslated: qsTr("Unfavorite")
    property string favoriteTranslated: qsTr("Favorite")
    property bool   validInput: false

    function contactSave(){
        var addresses = addys.getNewAddresses();
        var newPhones = phones.getNewPhones();
        var newIms = ims.getNewIms();
        var newWebs = urls.getNewUrls();
        var newEmails = emails.getNewEmails();
        var avatar = photoPicker.selectedPhoto
        var thumburi = photoPicker.selectedPhotoThumb

        var ret = peopleModel.createPersonModel(avatar, thumburi, data_first.text, data_last.text, data_company.text, newPhones["numbers"], newPhones["types"],
                                                icn_faves.favoriteText, newIms["ims"], newIms["types"],
                                                newEmails["emails"], newEmails["types"], addresses["streets"], addresses["locales"], addresses["regions"],
                                                addresses["zips"], addresses["countries"], addresses["types"], newWebs["urls"], newWebs["types"], datePicker.selectedDate, data_notes.text);

        if (!ret) //REVISIT
            console.log("[contactSave] Unable to create new contact due to missing info");
    }

    Column{
        id: detailsList
        spacing: 1
        width: parent.width
        //REVISIT: anchors {left:parent.left; right: parent.right; leftMargin:10; rightMargin:10;}
        Image{
            id: detailHeader
            width: parent.width
            height: 150
            source: "image://theme/contacts/active_row"
            anchors.bottomMargin: 1

            Item{
                id: avatar
                width: 150
                height: 150
                anchors {top: detailHeader.top; left: parent.left; }

                Image{
                    id: avatar_img
                    source: "image://theme/contacts/img_blankavatar"
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
                property string selectedPhotoThumb

                albumSelectionMode: false
                onPhotoSelected: {
                    selectedPhoto = uri
                    selectedPhotoThumb = (thumburi ? thumburi : uri);
                }

                onClosed: {
                    if (selectedPhoto)
                    {
                        avatar_img.source = selectedPhotoThumb;
                        avatar.opacity = 1;
                    }
                }
            }
            Grid{
                id: headerGrid
                columns:  2
                rows: 2
                anchors{ left: avatar.right; right: detailHeader.right; top: detailHeader.top; bottom: detailHeader.bottom}
                Item{
                    id: quad1
                    width: headerGrid.width/2
                    height: headerGrid.height/2
                    TextEntry{
                        id: data_first
                        text: ""
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
                        text: ""
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
                        text: ""
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
                            source: "image://theme/contacts/icn_fav_star_dn"
                            opacity: 1
                            state: unfavoriteValue

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
            phoneModel: ""
            contextModel: ""
            anchors {top: detailHeader.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        ImEditWidget{
            id:ims
            width: parent.width
            height: childrenRect.height
            imModel: ""
            contextModel: ""
            anchors {top: phones.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        EmailEditWidget{
            id:emails
            width: parent.width
            height: childrenRect.height
            emailModel: ""
            contextModel: ""
            anchors {top: ims.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        WebPageEditWidget{
            id:urls
            width: parent.width
            height: childrenRect.height
            webModel: ""
            contextModel: ""
            anchors {top: emails.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
        }

        AddressEditWidget{
            id:addys
            width: parent.width
            height: childrenRect.height
            addressModel: ""
            contextModel: ""
            anchors {top: urls.bottom; left: parent.left; topMargin: 0; leftMargin: 0}
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
            source: "image://theme/contacts/active_row"
            anchors.bottomMargin: 1
            TextEntry{
                id: data_birthday
                text: datePicker.selectedBirthday
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
                        PropertyChanges{target: data_birthday; color: theme_fontColorNormal}
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
                selectedBirthday = Qt.formatDate(date, Qt.SystemLocaleDate);
            }

            onClosed: {
                data_birthday.state = (data_birthday.state == "default" ? "edit" : data_birthday.state)
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
            source: "image://theme/contacts/active_row"
            anchors.bottomMargin: 1
            TextEntry{
                id: data_notes
                text: ""
                defaultText: defaultNote
                width:540
                height: 300
                anchors {top: parent.top; left: parent.left; topMargin: 30; leftMargin: 30}
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

