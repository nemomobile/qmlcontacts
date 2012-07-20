import QtQuick 1.1

ListModel {
    id: detailList

    function populateFrom(sourceList) {
        for (var i = 0; i < sourceList.length; ++i) {
            detailList.append({ "data": sourceList[i].number })
        }

        sourceList = undefined
    }

    function setValue(row, value) {
        detailList.set(row, { "data": value })
    }

    function addNew() {
        detailList.append({ "data": ""})
    }

    function dataList() {
        var list = []
        for (var i = 0; i < detailList.count; ++i) {
            console.log("item " + i)
            console.log("item " + detailList.get(i))
            console.log("item data " + detailList.get(i).data)
            list.push(detailList.get(i).data)
        }

        console.log(list)
        return list
    }
}
