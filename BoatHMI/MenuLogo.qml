import QtQuick
import QtQuick.Window 6.10
import QtQuick.Controls
import QtLocation
import QtPositioning
import QtQuick.Effects

Rectangle{
    id:framelogo
    height: 35
    width: 30
    color: "transparent"

    property bool open: false
    signal menuToggled(bool isOpen)
    MouseArea {
            anchors.fill: parent
            onClicked: {
                // Inverse l'état du menu
                framelogo.open = !framelogo.open
                console.log("click menu")
                console.log(framelogo.open)

                // Émet le signal vers le main
                framelogo.menuToggled(framelogo.open)
            }
        }
Rectangle{
    id:line1
    height: 5
    width: 30
    color: "#E6E6E6"
    anchors.top: parent.top
    anchors.topMargin: 5

}
Rectangle{
    id:line2
    height: 5
    width: 30
    color: "#E6E6E6"
    anchors.top: line1.bottom
    anchors.topMargin: 5

}
Rectangle{
    id:line3
    height: 5
    width: 30
    color: "#E6E6E6"
    anchors.top: line2.bottom
    anchors.topMargin: 5

}


}
