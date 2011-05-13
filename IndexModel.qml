import Qt 4.7

ListModel {
    id: indexModel

    function appendLetters()
    {
        var list = qsTr("A B C D E F G H I J K L M N O P Q R S T U V W X Y Z #");
        for(var i=0 ; i < list.length; i=i+2)
        {
            append({"dletter": list[i]});
        }
    }

    Component.onCompleted: {
        appendLetters();
    }
}
