/*
 * Copyright (C) 2011-2012 Robin Burchell <robin+mer@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 2.0
import com.nokia.meego 2.0
import org.nemomobile.contacts 1.0

Repeater {
    id: root
    property string placeholderText
    property bool edited : false
    property variant originalData
    model: ListModel {
    }
    property bool isSetup: false
    
    function addNewData(nText)
    {
         model.append({ data: nText, data_street: "", data_city: "", data_state: "", data_postalcode: "", data_country: "", data_postofficebox: "" })
         edited = true
    }
    
    function isAddressTypeExists(nType)
    {
        for (var i=0;i<model.count;++i) 
        {
            if (model.get(i).data == nType)
            {
                return true;            
            }    
        }
        
        return false;
    } 
    
    function setModelData(modelDataType, modelData) {
        isSetup = false
        edited = false
        model.clear()

        for (var i = 0; i < modelData.length; ++i) {
            var words = modelData[i].split("\n")   
            switch (modelDataType[i])
            {
                case 14:
                    model.append({ data: "Home", data_street: words[0], 
                            data_city: words[1], data_state: words[2], 
                            data_postalcode: words[3], data_country: words[4],
                            data_postofficebox: words[5] })
                        break;
                case 15:
                    model.append({ data: "Work", data_street: words[0], 
                            data_city: words[1], data_state: words[2], 
                            data_postalcode: words[3], data_country: words[4],
                            data_postofficebox: words[5] })
                        break;
                case 16:
                    model.append({ data: "Other", data_street: words[0], 
                            data_city: words[1], data_state: words[2], 
                            data_postalcode: words[3], data_country: words[4],
                            data_postofficebox: words[5] })
                        break;
                default:
                    model.append({ data: modelDataType[i], 
                            data_street: words[0], data_city: words[1], 
                            data_state: words[2], data_postalcode: words[3], 
                            data_country: words[4], 
                            data_postofficebox: words[5] })
                    break;
            } 
        }

        originalData = modelDataFull()
        isSetup = true
    }
        
    
    function modelData() {
        var modelData = []

        for (var i=0;i<model.count;++i) {
            if (model.get(i).data_street ||
                model.get(i).data_city || 
                model.get(i).data_state ||
                model.get(i).data_postalcode ||
                model.get(i).data_country)
            {
                modelData.push(model.get(i).data_street + "\n" + model.get(i).data_city + "\n" + 
                    model.get(i).data_state + "\n" + model.get(i).data_postalcode +
                    "\n" + model.get(i).data_country +
                    "\n" + model.get(i).data_postofficebox  );
            }
        }
        return modelData;
    }

    function modelDataFull() {
        var modelData = []

        for (var i=0;i<model.count;++i) {
            modelData.push(
                    model.get(i).data + "\n" +
                    model.get(i).data_street + "\n" + model.get(i).data_city + "\n" + 
                    model.get(i).data_state + "\n" + model.get(i).data_postalcode +
                    "\n" + model.get(i).data_country +
                    "\n" + model.get(i).data_postofficebox  );
        }
        return modelData;
    }


    function modelDataTypes() {
        var modelData = []

        for (var i=0;i<model.count;++i) {
            if (model.get(i).data_street ||
                model.get(i).data_city || 
                model.get(i).data_state ||
                model.get(i).data_postalcode ||
                model.get(i).data_country)
            {
                if (model.get(i).data == "Home")
                {
                    modelData.push(14)
                }
                else if (model.get(i).data == "Work")
                {
                    modelData.push(15)
                }
                else
                {
                    modelData.push(16)
                }
            }
        }
        return modelData;
    }
    
    function isEdited()
    {
        edited = false; 
        var modelData = modelDataFull()
        edited = false

        if (originalData.length == modelData.length)
        {
            for (var i=0;i<originalData.length;++i) {
                if (modelData[i] != originalData[i])
                {
                    edited = true
                    return true
                }
            }        
        }
        else
        {
            edited = true
        }

        return edited;     
    }

    Item {
         id: rootItem
         anchors.left: parent.left
         anchors.right: parent.right
         height: 320
         property alias strAddressType: addressType.text
         
         Label {
                id: addressType
                text: model.data
                font.family: "Helvetica"
                font.pointSize: 20
                color: "black"
        }
                    
        TextField {
                id: data_street
                text: model.data_street
                placeholderText: qsTr("Street address")
                anchors { top: addressType.bottom;
            }
                onTextChanged: { 
                    root.model.get(index).data_street = text
                    if (isSetup)
                    {
                        isEdited()
                    }
                }
        }

        TextField {
                id: data_city
                text: model.data_city
                placeholderText: qsTr("City")
                anchors { top: data_street.bottom;
                    topMargin:  data_street.topMargin;
                    right: data_street.right; left: data_street.left
            }
                onTextChanged: { 
                    root.model.get(index).data_city = text 
                    if (isSetup)
                    {
                        isEdited()
                    }
                }
        }

        TextField {
                id: data_state
                text: model.data_state
                placeholderText: qsTr("State")
                anchors { top: data_city.bottom;
                    topMargin:  data_street.topMargin;
                    right: data_street.right; left: data_street.left
            }
                onTextChanged: { 
                    root.model.get(index).data_state = text 
                    if (isSetup)
                    {
                        isEdited()
                    }
                }
        }
        
        TextField {
                id: data_postalcode
                text: model.data_postalcode                
                placeholderText: qsTr("Postal code")
                anchors { top: data_state.bottom;
                    topMargin:  data_street.topMargin;
                    right: data_street.right; left: data_street.left
            }
                onTextChanged: { 
                    root.model.get(index).data_postalcode = text 
                    if (isSetup)
                    {
                        isEdited()
                    }
                }
        }
        
        TextField {
                id: data_country
                text: model.data_country                
                placeholderText: qsTr("Country")
                anchors { top: data_postalcode.bottom;
                    topMargin:  data_street.topMargin;
                    right: data_street.right; left: data_street.left
            }
                onTextChanged: { 
                    root.model.get(index).data_country = text 
                    if (isSetup)
                    {
                        isEdited()
                    }
                }
        }      
        
        TextField {
                id: data_postofficebox
                text: model.data_postofficebox                
                placeholderText: qsTr("Post Office Box")
                anchors { top: data_country.bottom;
                    topMargin:  data_street.topMargin;
                    right: data_street.right; left: data_street.left
            }
                onTextChanged: { 
                    root.model.get(index).data_postofficebox = text
                    if (isSetup)
                    {
                        isEdited()
                    }
                }
        }        
    }
}

