.pragma library
var peopleModel
var contactIds = []

var editorComponent = Qt.createComponent(Qt.resolvedUrl("ContactEditorSheet.qml"));
var cardComponent = Qt.createComponent(Qt.resolvedUrl("ContactCardPage.qml"));

function initialize(peopleModelInstance) {
    peopleModel = peopleModelInstance
}

function openContactEditor(parentObject, contactId) {
    console.log("Opening editor for " + contactId)
    contactIds.push(contactId)

    console.log("ERROR: HERE IT IS " + editorComponent.errorString())

    var editor = editorComponent.createObject(parentObject)
    editor.open()
}

function openContactCard(pageStack, contactId) {
    console.log("Opening card for " + contactId)
    contactIds.push(contactId)

    pageStack.push(cardComponent);
}

function createNextPerson() {
    var contactId = contactIds.pop()
    console.log("Fetching person instance for " + contactId)
    if (contactId == undefined) {
        return peopleModel.newPerson()
    } else {
        var person = peopleModel.personById(contactId)
        console.log("Got person " + person)
        return person
    }
}

function peopleModel()
{
    return peopleModel
}
