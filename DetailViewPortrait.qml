/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.1
import MeeGo.App.Contacts 0.1

Flickable {
    id: detailViewPortrait
    contentWidth: parent.width
    contentHeight: detailsList.height
    flickableDirection: Flickable.VerticalFlick
    height: parent.height
    width: parent.width
    interactive: true
    clip: true;
    opacity: 1

    property PeopleModel detailModel: contactModel
    property int indexOfPerson: personRow

    property string contextHome: qsTr("Home")
    property string contextWork: qsTr("Work")
    property string contextOther: qsTr("Other")
    property string contextMobile: qsTr("Mobile")

    //: Denotes whether the web page for this contact is just a bookmark
    property string contextBookmark: qsTr("Bookmark", "Noun")

    //: Denotes whether the web page for this contact is a favorite bookmark
    property string contextFavorite: qsTr("Favorite", "Noun")

    property string defaultFirstName: qsTr("First name")
    property string defaultLastName: qsTr("Last name")
    property string defaultCompany: qsTr("Company")
    property string defaultNote: qsTr("Enter note")
    property string defaultBirthday: qsTr("Enter birthday")

    //: Default website - the user should enter a URL in this field
    property string defaultWeb : qsTr("Site")

    property string headerPhone: qsTr("Phone numbers")

    //: Instant Messaging Accounts for this contact
    property string headerEmail: qsTr("Email")

    //: The header for the section that shows the web sites for this contact
    property string headerWeb: qsTr("Web")
    property string headerAddress : qsTr("Address")
    property string headerBirthday: qsTr("Birthday")
    property string headerDate: qsTr("Date")
    property string headerNote: qsTr("Note")

    property string aimTr : qsTr("AIM")
    property string msnTr : qsTr("MSN")
    property string jabberTr : qsTr("Jabber")
    property string yahooTr : qsTr("Yahoo!")
    property string facebookTr : qsTr("Facebook")
    property string gtalkTr : qsTr("Google Talk")
    property string imTr : qsTr("IM")

    //: Add favorite flag / add contact to favorites list
    property string favoriteTranslated: qsTr("Favorite", "Verb")

    //: Remove favorite flag / remove contact from favorites list
    property string unfavoriteTranslated: qsTr("Unfavorite")

    //do not internationalize
    property string favoriteWeb: "Favorite"
    property string homeValue: "Home"
    property string workValue: "Work"
    property string otherValue: "Other"
    property string mobileValue: "Mobile"
    property string bookmarkValue: "Bookmark"

    property string aimValue : "im-aim"
    property string msnValue : "im-jabber"
    property string jabberValue : "im_msn"
    property string yahooValue : "im-facebook"
    property string facebookValue : "im-google-talk"
    property string gtalkValue : "im-yahoo"

    //: Load the details for the selected contact
    property string viewUrl: qsTr("View")

    //: Truncate string - used when a string is too long for the display area
    property string stringTruncater: qsTr("...")

    function getTruncatedString(valueStr, stringLen) {
        var MAX_STR_LEN = stringLen;
        var multiline = (valueStr.indexOf("\n") == -1 ? false : true);
        var valueStr = valueStr.split("\n");
        var MAX_NEWLINE = valueStr.length-1;
        var newStr = "";
        for(var i = 0; i < valueStr.length; i++){
            //Make sure string is no longer than MAX_STR_LEN characters
            //Use MAX_STR_LEN - stringTruncater.length to make room for ellipses
            if (valueStr[i].length > MAX_STR_LEN) {
                valueStr[i] = valueStr[i].substring(0, MAX_STR_LEN - stringTruncater.length);
                valueStr[i] = valueStr[i] + stringTruncater;
            }
            if(multiline && (i<MAX_NEWLINE))
                newStr = newStr + valueStr[i] + "\n";
            else
                newStr = newStr + valueStr[i];
        }
        return newStr;
    }

    //Strip out any empty fields in the address - must do this on the
    //QML side, as the "\n" are needed in the EditView to denote the
    //different fields
    function getAddressDisplayVal(modelData) {
        var addy = getTruncatedString(modelData, 25);
        var res = addy.split("\n");
        addy = "";

        for (var i = 0; i < res.length; i++) {
            if (res[i] != "") {
                if (i > 0)
                    addy += "\n" + res[i];
                else
                    addy += res[i];
            }
        }
        return addy;
    }

    Rectangle {
        id: detailsRect
        width: parent.width
        height: window.height
        color: "white"

    Column{
        id: detailsList
        spacing: 1
        anchors {left:parent.left; right: parent.right; leftMargin:10; rightMargin:10;}
        Image{
            id: detailHeader
            width: parent.width
            height: (firstname_p.visible ? 175 : 150)
            source: "image://themedimage/widgets/common/header/header-inverted-small"
            opacity: (detailModel.data(indexOfPerson, PeopleModel.IsSelfRole) ? .5 : 1)
            LimitedImage{
                id: avatar_image
                //REVISIT: Instead of using the URI from AvatarRole, need to use thumbnail URI
                source: (detailModel.data(indexOfPerson, PeopleModel.AvatarRole) ? detailModel.data(indexOfPerson, PeopleModel.AvatarRole): "image://themedimage/widgets/common/avatar/avatar-default")
                anchors {top: detailHeader.top; left: parent.left; }
                opacity: 1
                signal clicked
                width: 150
                height: 150
                smooth:  true
                clip: true
                fillMode: Image.PreserveAspectCrop
                //Image.Error
                Binding{target: avatar_image; property: "source"; value:"image://themedimage/widgets/common/avatar/avatar-default"; when: avatar_image.status == Image.Error }
            }
            Grid{
                id: headerGrid
                columns:  2
                rows: 2
                anchors{ left: avatar_image.right; right: detailHeader.right; top: detailHeader.top; bottom: detailHeader.bottom}
                Item{
                    id: quad1
                    width: headerGrid.width*(2/3)
                    height: headerGrid.height/2
                    Item{
                        anchors{verticalCenter: quad1.verticalCenter; left: quad1.left; leftMargin: 50}
                        width: parent.width
                        height: childrenRect.height
                        Text{
                            id: firstname
                            width: parent.width/2
                            text: (detailModel.data(indexOfPerson, PeopleModel.FirstNameRole)? detailModel.data(indexOfPerson, PeopleModel.FirstNameRole) : "")
                            elide: Text.ElideRight
                            smooth: true
                        }
                        Text{
                            id: firstname_p
                            text: (detailModel.data(indexOfPerson, PeopleModel.FirstNameProRole)? getTruncatedString(detailModel.data(indexOfPerson, PeopleModel.FirstNameProRole), 25) : "")
                            smooth: true
                            visible: localeUtils.needPronounciationFields()
                            anchors {top: firstname.bottom; topMargin: 10;}
                        }
                        Text{
                            id: lastname
                            width: parent.width/2
                            text: (detailModel.data(indexOfPerson, PeopleModel.LastNameRole) ? detailModel.data(indexOfPerson, PeopleModel.LastNameRole) : "")
                            elide: Text.ElideRight
                            smooth: true
                            anchors{left: firstname.right; leftMargin: 15;}
                        }
                    }
                }
                Item{
                    id: quad3
                    width: headerGrid.width*(2/3)
                    height: headerGrid.height/2
                    Text{
                        id: company
                        width: parent.width
                        text: (detailModel.data(indexOfPerson, PeopleModel.CompanyNameRole) ? detailModel.data(indexOfPerson, PeopleModel.CompanyNameRole) : "")
                        elide: Text.ElideRight
                        smooth: true
                        anchors{ verticalCenter: quad3.verticalCenter; left: parent.left; leftMargin: 50}
                    }
                }
                Item{
                    id: quad4
                    width: headerGrid.width/3
                    height: headerGrid.height/2
                    Item{
                        anchors.left: parent.left
                        anchors.leftMargin: 100
                        anchors.verticalCenter: parent.verticalCenter
                        width: childrenRect.width
                        height: childrenRect.height
                        Image {
                            id: icon_favorite
                            anchors{right: parent.left;  rightMargin: 10}
                            source: (detailModel.data(indexOfPerson, PeopleModel.FavoriteRole) ? "image://themedimage/icons/actionbar/favorite-selected" : "image://themedimage/icons/actionbar/favorite" )
                            opacity: (detailModel.data(indexOfPerson, PeopleModel.IsSelfRole) ? 0 : 1)
                        }
                    }
                }
            }
        }

        Item{
            id: phoneHeader
            width: parent.width-20
            height: 70
            opacity: (detailModel.data(indexOfPerson, PeopleModel.PhoneNumberRole).length > 0 ? 1: 0)

            Text{
                id: label_phone
                text: headerPhone
                smooth: true
                anchors {bottom: phoneHeader.bottom; bottomMargin: 10; left: phoneHeader.left; leftMargin: 30}
            }
        }

        Repeater{
            id: detailsPhone
            width: parent.width-20
            height: childrenRect.height
            opacity: phoneHeader.opacity
            model: detailModel.data(indexOfPerson, PeopleModel.PhoneNumberRole)
            property variant phoneContexts: detailModel.data(indexOfPerson, PeopleModel.PhoneContextRole)
            Item{
                id: delegatePhone
                width: parent.width
                height: 80
                Image{
                    id: phoneBar
                    source: "image://themedimage/widgets/common/header/header-inverted-small"
                    anchors.fill:  parent
                    Text{
                        id: label
                        text: {
                            if(detailsPhone.phoneContexts[index] == mobileValue)
                                return mobileValue;
                            else if(detailsPhone.phoneContexts[index] == homeValue)
                                return homeValue;
                            else if(detailsPhone.phoneContexts[index] == workValue)
                                return workValue;
                            else if(detailsPhone.phoneContexts[index] == otherValue)
                                return otherValue;
                            else
                                return homeValue;
                        }
                        smooth: true
                        anchors {verticalCenter: phoneBar.verticalCenter; left: phoneBar.left; leftMargin: 20}
                        opacity: 1
                    }
                    Text{
                        id: data_phone
                        text: getTruncatedString(modelData, 25)
                        smooth: true
                        font.bold: true
                        anchors {verticalCenter: phoneBar.verticalCenter; left: phoneBar.left; leftMargin: 145}
                        opacity: 1
                    }
                }
            }
        }

        Item{
            id: emailHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(indexOfPerson, PeopleModel.EmailAddressRole).length > 0 ? 1 : 0)

            Text{
                id: label_email
                text: headerEmail
                smooth: true
                anchors {bottom: emailHeader.bottom; bottomMargin: 10; left: parent.left; leftMargin: 30}
            }
        }

        Repeater{
            id: detailsEmail
            width: parent.width
            opacity: emailHeader.opacity
            height: childrenRect.height
            model: detailModel.data(indexOfPerson, PeopleModel.EmailAddressRole)
            property variant emailContexts: detailModel.data(indexOfPerson, PeopleModel.EmailContextRole)

            Item{
                id: delegateemail
                width: parent.width
                height: 80

                Image{
                    id: emailBar
                    source: "image://themedimage/widgets/common/header/header-inverted-small"
                    anchors.fill: parent
                    Text{
                        id: email_txt
                        text:  {
                            if(detailsEmail.emailContexts[index] == homeValue)
                                return contextHome;
                            else if(detailsEmail.emailContexts[index] == workValue)
                                return contextWork;
                            else if(detailsEmail.emailContexts[index] == otherValue)
                                return contextOther;
                            else
                                return contextHome;
                        }
                        smooth: true
                        anchors {verticalCenter: emailBar.verticalCenter; left: emailBar.left; leftMargin: 20 }
                        opacity: 1
                    }
                    Text{
                        id: data_email
                        text: getTruncatedString(modelData, 25)
                        smooth: true
                        font.bold: true
                        anchors {verticalCenter: emailBar.verticalCenter; left: emailBar.left; leftMargin: 110 }
                        opacity: 1
                    }
                }
            }
        }

        Item{
            id: webHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(indexOfPerson, PeopleModel.WebUrlRole).length > 0 ? 1 : 0)

            Text{
                id: label_web
                text: headerWeb
                smooth: true
                anchors {bottom: webHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 10; leftMargin: 30}
            }
        }
        Repeater{
            id: detailsWeb
            width: parent.width
            opacity: webHeader.opacity
            model: detailModel.data(indexOfPerson, PeopleModel.WebUrlRole)
            property variant webContexts: detailModel.data(indexOfPerson, PeopleModel.WebContextRole)

            Item{
                id: delegateweb
                width: parent.width
                height: 80

                Image{
                    id: webBar
                    source: "image://themedimage/widgets/common/list/list-single-selected"
                    anchors.fill: parent

                    Text{
                        id: button_web_txt
                        text:  {
                            if(detailsWeb.webContexts[index] == favoriteWeb)
                                return contextFavorite;
                            else if(detailsWeb.webContexts[index] == bookmarkValue)
                                return contextBookmark;
                            else
                                return contextBookmark;
                        }
                        smooth: true
                        anchors {verticalCenter: webBar.verticalCenter; left: webBar.left; leftMargin: 20 }
                        opacity: 1
                    }
                    Text{
                        id: data_web
                        text: getTruncatedString(modelData, 25)
                        smooth: true
                        font.bold: true
                        anchors {verticalCenter: webBar.verticalCenter; left: webBar.left; leftMargin: 145 }
                        opacity: 1
                    }

                    MouseArea{
                        id: mouseArea_url
                        anchors.fill: parent
                        onPressed: {
                            console.log("FIXME browser in detail view, ask Robin");
//                            var cmd = "meego-app-browser " + data_web.text;
//                            appModel.launch(cmd);
                        }
                    }
                }
            }
        }

        Item{
            id: addressHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(indexOfPerson, PeopleModel.AddressRole).length > 0 ? 1: 0)

            Text{
                id: label_address
                text: headerAddress
                smooth: true
                anchors {bottom: addressHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }
        Repeater{
            id: detailsAddress
            width: parent.width
            opacity: addressHeader.opacity
            model: detailModel.data(indexOfPerson, PeopleModel.AddressRole)
            property variant addressContexts: detailModel.data(indexOfPerson, PeopleModel.AddressContextRole)
            Item{
                id: delegateaddy
                width: parent.width
                height: 200

                Image{
                    id: addyBar
                    source: "image://themedimage/widgets/common/header/header-inverted-small"
                    anchors.fill: parent

                    Text{
                        id: button_addy_txt
                        text: {
                            if(detailsAddress.addressContexts[index] == homeValue)
                                return contextHome;
                            else if(detailsAddress.addressContexts[index] == workValue)
                                return contextWork;
                            else if(detailsAddress.addressContexts[index] == otherValue)
                                return contextOther;
                            else
                                return contextHome;
                        }
                        smooth: true
                        anchors {verticalCenter: addyBar.verticalCenter; left: addyBar.left; leftMargin: 20 }
                        opacity: 1
                    }
                    Column{
                        width: parent.width-100
                        height: childrenRect.height
                        anchors {verticalCenter: addyBar.verticalCenter; left: addyBar.left; leftMargin: 145 }
                        spacing: 10

                        Item{
                            id: address_rect
                            height: childrenRect.height
                            width: parent.width

                            Text{
                                id: data_street
                                anchors.verticalCenter: address_rect.verticalCenter
                                text: getAddressDisplayVal(modelData);
                                smooth: true
                                font.bold: true
                                opacity: 1
                            }
                        }

                    }
                }
            }
        }

        Item{
            id: birthdayHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(indexOfPerson, PeopleModel.BirthdayRole).length > 0 ? 1: 0)

            Text{
                id: label_birthday
                text: headerBirthday
                smooth: true
                anchors {bottom: birthdayHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }

        Item{
            id: delegatebday
            width: parent.width
            opacity: birthdayHeader.opacity
            height: 80
            Image{
                id: bdayBar
                source: "image://themedimage/widgets/common/header/header-inverted-small"
                anchors.fill: parent

                Text{
                    id: button_birthday_txt
                    text: headerDate
                    smooth: true
                    anchors {verticalCenter: bdayBar.verticalCenter; left: bdayBar.left; leftMargin: 20 }
                    opacity: 1
                }
                Text{
                    id: data_birthday
                    text: detailModel.data(indexOfPerson, PeopleModel.BirthdayRole)
                    smooth: true
                    font.bold: true
                    anchors {verticalCenter: bdayBar.verticalCenter; left: button_birthday_txt.right; leftMargin: 20 }
                    opacity: 1
                }
            }
        }

        Item{
            id: notesHeader
            width: parent.width
            height: 70
            opacity: (detailModel.data(indexOfPerson, PeopleModel.NotesRole).length > 0 ? 1: 0)

            Text{
                id: label_notes
                text: headerNote
                smooth: true
                anchors {bottom: notesHeader.bottom; bottomMargin: 10; left: parent.left; topMargin: 0; leftMargin: 30}
            }
        }
        Item{
            id: delegateNote
            width: parent.width
            height: 200
            opacity:  notesHeader.opacity
            Image{
                id: noteBar
                source: "image://themedimage/widgets/common/toolbar-item/toolbar-item-background-selected"
                anchors.fill:  parent

                Text{
                    id: data_notes
                    text: getTruncatedString(detailModel.data(indexOfPerson, PeopleModel.NotesRole), 50)
                    smooth: true
                    font.bold: true
                    anchors {top: noteBar.top; left: noteBar.left; leftMargin: 30; topMargin: 30}
                    opacity: 1
                }
            }
        }
    }
    }
}

