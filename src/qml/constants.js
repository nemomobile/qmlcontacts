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

