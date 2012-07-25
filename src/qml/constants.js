var landscape = 0
var portrait = 90
var reverseLandscape = 180
var reversePortrait = 270

var homescreenWidgetRowsPortrait = 4
var homescreenWidgetColumnsPortrait = 3
var homescreenWidgetRowsLandscape = 3
var homescreenWidgetColumnsLandscape = 4

// 1024x600
var screen = { width: 540, height: 960 };
//var screen = { width: 400, height: 600 };

var componentCache = {}
var singletonObjects = {}

function loadSingleton(fileName, parent, callback, data) {
    if (singletonObjects[fileName]) {
        callback(singletonObjects[fileName])
        return
    }

    loadComponent(fileName, function(loadedComponent) {
            if (data)
                singletonObjects[fileName] = loadedComponent.createObject(parent, data)
            else
                singletonObjects[fileName] = loadedComponent.createObject(parent)
            callback(singletonObjects[fileName])
    });
}

function loadComponent(fileName, callback) {
    if (componentCache[fileName]) {
        callback(componentCache[fileName])
        return
    }

    // TODO: can Qt.createComponent work asynchronously (even for local files)
    // like Loader?
    var loadingComponent = Qt.createComponent(fileName);

    if (!loadingComponent) {
        console.log("FAILED LOADING COMPONENT: " + fileName + " - " + loadingComponent.errorString())
        return
    }

    if (loadingComponent.status == Component.Ready) {
        componentCache[fileName] = loadingComponent
        callback(loadingComponent)
    } else if (loadingComponent.status == Component.Error) {
        console.log("FAILED LOADING COMPONENT: " + fileName + " - " + loadingComponent.errorString())
    } else {
        loadingComponent.statusChanged.connect(function() {
            if (loadingComponent.status == Component.Ready) {
                componentCache[fileName] = loadingComponent
                callback(loadingComponent)
            } else if (loadingComponent.status == Component.Error) {
                console.log("FAILED LOADING COMPONENT: " + fileName + " - " + loadingComponent.errorString())
            }
        })
    }
}

