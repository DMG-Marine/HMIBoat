import QtQuick 6.10
import QtQuick.Window 6.10
import QtQuick.Controls
import QtLocation
import QtPositioning
import QtQuick.Effects
import Boat 1.0




Window {


    id:mainwindow
    width: 1620
    height: 820
    visible: true
    color: "black"
    flags: Qt.FramelessWindowHint

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Escape)
            Qt.quit()
    }
    Boat { id: boat }

    Connections {
        target: boat.rootMap ? boat.rootMap : null
        onValueChanged: function(name, value) {
            console.log("[rootMap] " + name + " -> " + value)
        }
    }

    property real motorLValue: boat.rootMap.nav && boat.rootMap.nav.MotorL ?
                                boat.rootMap.nav.MotorL / 8000 * 400 : 0
    property real motorRValue: boat.rootMap.nav && boat.rootMap.nav.MotorR ?
                                boat.rootMap.nav.MotorR / 8000 * 400 : 0
    property real rpmValueR: boat.rootMap.nav && boat.rootMap.nav.MotorR ? boat.rootMap.nav.MotorR  : 0

    property color rpmColorR: {
        if (rpmValueR < 4000) return "#E6E6E6";
        else return "#EB4D4D";
    }

    property bool menuopen : false

    Plugin {
        id: osmPlugin
        name: "osm"
        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: true }
        PluginParameter { name: "osm.mapping.offline.directory"; value: "" }
        PluginParameter { name: "osm.mapping.custom.host"; value: "https://tile.openstreetmap.org" }
    }

    // --- Carte OpenSeaMap à l'intérieur du rectangle
    Map {
        id: map
        width: 1100
         anchors.right: parent.right
         anchors.bottom: parent.bottom
         anchors.top: parent.top
        plugin: osmPlugin
        center: QtPositioning.coordinate(43.3, 5.4) // exemple: Marseille
        zoomLevel: 11
        layer.enabled:true
        copyrightsVisible: false
        visible: true
        Behavior on width {
            NumberAnimation{
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }


        PinchHandler {
                   id: pinch
                   target: null
                   onActiveChanged: if (active) {
                       map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
                   }
                   onScaleChanged: (delta) => {
                       map.zoomLevel += Math.log2(delta)
                       map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                   }
                   onRotationChanged: (delta) => {
                       map.bearing -= delta
                       map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
                   }
                   grabPermissions: PointerHandler.TakeOverForbidden
               }
               WheelHandler {
                   id: wheel
                   // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
                   // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
                   // and we don't yet distinguish mice and trackpads on Wayland either
                   acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                                    ? PointerDevice.Mouse | PointerDevice.TouchPad
                                    : PointerDevice.Mouse
                   rotationScale: 1/120
                   property: "zoomLevel"
               }
               DragHandler {
                   id: drag
                   target: map
                   onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
                   acceptedDevices: PointerDevice.TouchPad | PointerDevice.TouchScreen
                       // ignore les événements hors de la Map
               }
               Shortcut {
                   enabled: map.zoomLevel < map.maximumZoomLevel
                   sequence: StandardKey.ZoomIn
                   onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
               }
               Shortcut {
                   enabled: map.zoomLevel > map.minimumZoomLevel
                   sequence: StandardKey.ZoomOut
                   onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
               }



        // Position du bateau
        MapQuickItem {
            id: boatimg
            anchorPoint.x: 16
            anchorPoint.y: 16
            coordinate: QtPositioning.coordinate(43.3, 5.4)
            sourceItem: Image {
                source: "qrc:/icons8-navigation-50.png" // ton icône
                width: 32
                height: 32
            }
        }



    }


    MenuBoat{
        id:mainmenuboat
        dynamicsize:mainwindow.height
        anchors.top: parent.top
        anchors.left: parent.left


    }
    MenuLogo{
        id:menulogo
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 10
        z:10
        onMenuToggled: function(isOpen) {
            mainwindow.menuopen = isOpen
        }
    }

    Rectangle {

        id: rectangle
        width: 860
        //anchors.left: mainmenuboat.right
        x: mainwindow.menuopen ? 0:80
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#4e4949"
        radius: 20

        property bool reduced : false
        property int page: 1       // commence à 1
        property int maxpage: 5

        Behavior on width {
            NumberAnimation{
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }
        Behavior on x {
            NumberAnimation{
                duration: 800
                easing.type: Easing.InOutQuad
            }
        }



        Boatinfo {
               id: boatPanel
               anchors.left: parent.left
               anchors.top: parent.top
               anchors.leftMargin: 50
               anchors.topMargin: 100
               boat: boat

               reduced: rectangle.reduced   // passe la variable Reduced du rectangle
               solarpowerin: boat.rootMap && boat.rootMap.energy ? boat.rootMap.energy.solarprod : "0"
               page: rectangle.page
               opacity: rectangle.reduced ? 0 : 1
               Behavior on opacity { NumberAnimation { duration: 500 } }
               visible: opacity > 0
                          }
        Text {
            id: clockText
            text: Qt.formatTime(new Date(), "hh:mm")
            //anchors.left: rectangle.left
            anchors.top: parent.top
            x: mainwindow.menuopen ? 50:20
            anchors.topMargin: 12
            color: "#efe7e5"
            font.pixelSize: 24
            font.family: "Orbitron"

            Behavior on x {
                NumberAnimation{
                    duration: 800
                    easing.type: Easing.InOutQuad
                }
            }

            Image {
                width: 30
                height: 30
                anchors.top: clockText.top
                anchors.left: clockText.right
                anchors.leftMargin: 20
                source: "qrc:/satellite.png"
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
        Timer {
                id: clockTimer
                interval: 1000          // toutes les secondes
                running: true
                repeat: true            // ⏳ redémarre à chaque tick
                onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")

        }
        Rectangle {
            id: battRight
            width: 80
            height: Math.min(boat.rootMap.BMS && boat.rootMap.BMS.RightBattLevel ?
                                 boat.rootMap.BMS.RightBattLevel  / 100 * 400: 50, 500)
            anchors.left: rpmRightGrey.right
            anchors.bottom: rectangle.bottom
            anchors.margins: -65
            anchors.rightMargin: -70
            anchors.bottomMargin: 150
            color:"#20CC16"
            radius: 20
            Behavior on height{
                NumberAnimation{
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                }

        }

        Rectangle {
            id: rpmRightGrey
            width: 80
            height: 400
            anchors.right: rectangle.right
            anchors.bottom: rectangle.bottom
            anchors.margins: -20
            anchors.rightMargin: 60
            anchors.bottomMargin: 150
            color:"#8F8F8F"
            radius: 20
            bottomRightRadius: 2
            Text {
                id: motorRLabel
                text: "Right"
                anchors.top: parent.top
                anchors.topMargin: -40
                anchors.centerIn: parent
                color: "#efe7e5"
                font.pixelSize: 24
                font.family: "Orbitron"
            }
        }


        Rectangle {
            id: rpmRight
            width: 80
            height:Math.min(motorRValue, 500)
            anchors.right: rectangle.right
            anchors.bottom: parent.bottom
            anchors.margins: -30
            anchors.rightMargin: 60
            anchors.bottomMargin: 150
            color:"#E6E6E6"
            radius: 20
            bottomRightRadius: 2
            Behavior on height{
                NumberAnimation{
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }


            Text {
                id: motorRRPM
                text: boat.rootMap && boat.rootMap.nav ? boat.rootMap.nav.MotorR : "0"
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.centerIn: parent
                color: "#333333"
                font.pixelSize: 20
                font.family: "Orbitron"
            }
        }

        Rectangle {
            id: battLeft
            width: 80
            height: Math.min(boat.rootMap.BMS && boat.rootMap.BMS.LeftBattLevel ?
                                 boat.rootMap.BMS.LeftBattLevel  / 100 * 400: 50, 500)
            anchors.left: rpmLeftGrey.left
            anchors.bottom: rectangle.bottom
            anchors.margins: -15
            anchors.rightMargin: -70
            anchors.bottomMargin: 150
            color:"#20CC16"
            radius: 20
            Behavior on height{
                NumberAnimation{
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
                }

        }
        Rectangle {
            id: rpmLeftGrey
            width: 80
            height: 400
            anchors.right: rectangle.right
            anchors.bottom: rectangle.bottom
            anchors.margins: -30
            anchors.rightMargin: 170
            anchors.bottomMargin: 150
            color:"#8F8F8F"
            radius: 20
            bottomLeftRadius: 2
            Text {
                id: motorLLabel
                text: "Left"
                anchors.top: rpmLeftGrey.top
                anchors.topMargin: -40
                anchors.centerIn: parent
                color: "#efe7e5"
                font.pixelSize: 24
                font.family: "Orbitron"
            }

}

        Rectangle {
            id: rpmLeft
            width: 80
            height: Math.min(motorLValue, 500)
            anchors.right: rectangle.right
            anchors.bottom: rectangle.bottom
            anchors.margins: -30
            anchors.rightMargin: 170
            anchors.bottomMargin: 150
            color:"#E6E6E6"
            radius: 20
            bottomLeftRadius: 2
            Behavior on height{
                NumberAnimation{
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }



            Text {
                id: motorLRPM
                text: boat.rootMap && boat.rootMap.nav ? boat.rootMap.nav.MotorL : "0"
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.centerIn: parent
                color: "#333333"
                font.pixelSize: 20
                font.family: "Orbitron"
            }
        }

        Text {
            id: speedText
            text: boat.rootMap && boat.rootMap.nav ? boat.rootMap.nav.speed : "0"
            anchors.right: rectangle.right
            anchors.top: parent.top
            anchors.margins: -30
            anchors.rightMargin: 90
            anchors.topMargin: 50
            color: "#efe7e5"
            font.pixelSize: 94
            font.family: "Orbitron"

            Text {
                id: speedTextUnit
                text: "Knots"
                anchors.right: parent.right
                anchors.margins: -30
                anchors.rightMargin: -80
                color: "#efe7e5"
                font.pixelSize: 24
                font.family: "Orbitron"
            }

        }


        MultiPointTouchArea {
            anchors.fill: rectangle
            minimumTouchPoints: 1
            maximumTouchPoints: 1

            onReleased: function(touchPoints) {
                if (!touchPoints || touchPoints.length === 0)
                    return

                var dx = touchPoints[0].x - touchPoints[0].startX
                var dy = touchPoints[0].y - touchPoints[0].startY

                // --- Swipe horizontal ---
                if (Math.abs(dx) > 80) {
                    if (dx < 0) { // swipe gauche
                        map.width = 1250
                        rectangle.width = 420
                        rectangle.reduced = true
                        console.log("Swipe gauche")
                    } else { // swipe droite
                        map.width = 850
                        rectangle.width = 820
                        rectangle.reduced = false
                        console.log("Swipe droite")
                    }
                }

                // --- Swipe vertical ---
                if (Math.abs(dy) > 80) {
                    if (dy < 0 && rectangle.page < rectangle.maxpage) { // swipe haut
                        rectangle.page += 1
                        console.log("Page:", rectangle.page)
                    }
                    else if (dy > 0 && rectangle.page > 1) { // swipe bas
                        rectangle.page -= 1
                        console.log("Page:", rectangle.page)
                    }
                }
            }
        }
        }



}

