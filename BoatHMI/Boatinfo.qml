import QtQuick
import QtQuick.Window 6.10
import QtQuick.Controls
import QtLocation
import QtPositioning
import QtQuick.Effects
import Boat 1.0


Rectangle {
    id: panel
    width: 600
    height: 600
    color: "transparent"
    property bool reduced: true  // ← obligatoire
    property int page: 1       // commence à 0
    property int maxPage: 5
    property int solarpowerin :0
    property Boat boat
    Rectangle {
        id:overviewboat
        anchors.fill: parent
        color: "transparent"
        opacity: panel.reduced ? 0 : 1
        visible: true

 //Page 1
        Rectangle{

            id:page1
            anchors.fill: parent
            color: "transparent"
            opacity: page == 1 ? 1 : 0


    Image {
        anchors.top:  parent.top
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.topMargin: 150
        height: 350
        width: 350
        source: "qrc:/pacoboat.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
        //opacity: page == 1 ? 1 : 0
        //Behavior on opacity { NumberAnimation { duration: 500 } }
        //visible: opacity > 0

    }
    Text {
        id: solarprodtext
        text: "Production Solaire"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 150
        anchors.topMargin: 5
        color: "#efe7e5"
        font.pixelSize: 24
        font.family: "Orbitron"
       // opacity: page == 1 ? 1 : 0
        //Behavior on opacity { NumberAnimation { duration: 500 } }
        //visible: opacity > 0

    }
    Text {
        id: solarprod
        text: solarpowerin + " W"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 150
        anchors.topMargin: 35
        color: "#efe7e5"
        font.pixelSize: 24
        font.family: "Orbitron"
        //opacity: page == 1 ? 1 : 0
        //Behavior on opacity { NumberAnimation { duration: 500 } }
        //visible: opacity > 0

    }

    Rectangle{
        id:batterystatlayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 500
        anchors.leftMargin: 100
        height: 50
        width: 300
        color: "#8F8F8F"
        radius: 5

        Rectangle{
            id:batterystatlayout2
            anchors.top: batterystatlayout.top
            anchors.left: batterystatlayout.right
            anchors.topMargin: 15
            anchors.leftMargin: -10
            height: 20
            width: 20
            color: "#8F8F8F"
            radius: 5


        }

        Rectangle{
            id:batterystat
            anchors.top: batterystatlayout.top
            anchors.left: batterystatlayout.left
            anchors.topMargin: 5
            anchors.leftMargin: 5
            height: 40
            width: 150
            color: "#56CC3F"
            radius: 5


        }
    }


    Behavior on opacity { NumberAnimation { duration: 500 } }
    visible: opacity > 0
        }

        //Page 2



        Rectangle {
            id: page2
            anchors.fill: parent
            color: "transparent"
            opacity: page == 2 ? 1 : 0
            visible: true   // ← toujours true
            Rectangle {
                id: graphmotorRFrame
                visible: true
                color: "transparent"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: 50
                height: 250
                width : 400
            Loader {
                id: graphLoader
                anchors.fill: parent
                active: panel.page === 2   // ← chargé une fois au démarrage, jamais détruit
                sourceComponent: Component {
                    GraphBoat {
                        boat: panel.boat
                        variable: "nav.MotorR"
                        label: "Moteur Droit"
                        unit: "RPM"
                        yMin: 0
                        yMax: 8000
                        historyPoints: 600
                        xDuration: 10
                        width: graphmotorRFrame.width
                        height: graphmotorRFrame.height
                    }
                }
            }
            }
            Rectangle {
                id: graphmotorLFrame
                visible: true
                color: "transparent"
                anchors.left: parent.left
                anchors.top: graphmotorRFrame.bottom
                anchors.topMargin: 50
                anchors.leftMargin: 50
                height: 250
                width : 400
            Loader {
                id: graphLoaderML
                anchors.fill: parent
                active: panel.page === 2   // ← chargé une fois au démarrage, jamais détruit
                sourceComponent: Component {
                    GraphBoat {
                        boat: panel.boat
                        variable: "nav.MotorL"
                        label: "Moteur Gauche"
                        unit: "RPM"
                        yMin: 0
                        yMax: 8000
                        historyPoints: 600
                        xDuration: 10
                        width: graphmotorRFrame.width
                        height: graphmotorRFrame.height
                    }
                }
            }
            }

            Behavior on opacity { NumberAnimation { duration: 500 } }
        }

    Behavior on opacity { NumberAnimation { duration: 500 } }

    }

}
