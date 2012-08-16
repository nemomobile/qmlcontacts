import QtQuick 1.1
import com.nokia.meego 1.1
import org.nemomobile.contacts 1.0

Repeater {
    id: root
    property string placeholderText
    property bool edited : false
    property variant originalData
    model: ListModel {
    }
    property bool isSetup: false

    function setModelData(modelData) {
        isSetup = false
        model.clear()

        for (var i = 0; i < modelData.length; ++i) {
            model.append({ data: modelData[i] })
        }

        model.append({ data: "" })
        originalData = modelData
        isSetup = true
    }

    function modelData() {
        var modelData = []

        // the -1 here is because we want to skip the always-added empty on the
        // end of the model.
        for (var i = 0; i < model.count - 1; ++i) {
            modelData.push(model.get(i).data)
        }
        return modelData;
    }

    delegate: TextField {
        text: model.data
        placeholderText: root.placeholderText
        width: root.width

        onTextChanged: {
            if (!root.isSetup)
                return

            root.model.get(index).data = text
            if (index == (root.model.count - 1)) {
                root.model.append({ data: "" })
            } else if (text == "" && index != (root.model.count - 1)) {
                root.model.remove(index)
            }
            if (!root.originalData[index] && text != "") {
                edited = true
            } else if(root.originalData[index] && root.originalData[index] != text) {
                edited = true
            }
            else {
                edited = false
            }
        }
    }
}

