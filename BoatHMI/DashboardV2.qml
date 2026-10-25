import QtQuick 6.10

// ============================================================
//  DASHBOARD V2 — écran alternatif "glassmorphism marin"
//  Toggle: touche D dans main.qml (retour aussi via le X)
//  Données: mêmes clés rootMap que l'écran classique
// ============================================================
Rectangle {
    id: panel

    property var boat
    signal exitRequested()

    readonly property color accent:   "#22D3EE"
    readonly property color accentHi: "#7DEBFF"
    readonly property color bg:       "#0B0F14"
    readonly property color card:     "#111A23"
    readonly property color edge:     "#1E3440"
    readonly property color ok:       "#34D399"
    readonly property color warn:     "#EB4D4D"
    readonly property color textMain: "#EAF6FA"
    readonly property color textDim:  "#6B8290"

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    width: 640
    color: bg
    opacity: 0.95
    radius: 24

    // --- Données (mêmes clés que l'écran classique) ---
    property real speed: boat && boat.rootMap && boat.rootMap.nav ? boat.rootMap.nav.speed : 0
    property real rpmR:   boat && boat.rootMap && boat.rootMap.nav ? boat.rootMap.nav.MotorR : 0
    property real rpmL:   boat && boat.rootMap && boat.rootMap.nav ? boat.rootMap.nav.MotorL : 0
    property real battR:  boat && boat.rootMap && boat.rootMap.BMS ? boat.rootMap.BMS.RightBattLevel : 0
    property real battL:  boat && boat.rootMap && boat.rootMap.BMS ? boat.rootMap.BMS.LeftBattLevel : 0
    property real solar:  boat && boat.rootMap && boat.rootMap.energy ? boat.rootMap.energy.solarprod : 0

    // ================== HEADER ==================
    Rectangle {
        id: btnExit
        x: 28; y: 26
        width: 46; height: 46
        radius: 23
        color: "#16222C"
        border.color: panel.accent; border.width: 1
        Text {
            anchors.centerIn: parent
            text: "X"
            color: panel.textMain
            font.pixelSize: 20
            font.bold: true
        }
        MouseArea { anchors.fill: parent; onClicked: panel.exitRequested() }
    }

    Text {
        id: headerTitle
        x: 92; y: 38
        text: "DASHBOARD V2"
        color: panel.textDim
        font.pixelSize: 18
        font.family: "Orbitron"
        font.letterSpacing: 4
    }

    Text {
        id: clockV2
        anchors.right: parent.right
        anchors.rightMargin: 32
        y: 30
        text: Qt.formatTime(new Date(), "hh:mm")
        color: panel.textMain
        font.pixelSize: 28
        font.family: "Orbitron"
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: clockV2.text = Qt.formatTime(new Date(), "hh:mm")
    }

    // ================== VITESSE ==================
    Rectangle {
        id: speedCard
        x: 32; y: 96
        width: panel.width - 64
        height: 190
        color: panel.card
        radius: 20
        border.color: panel.edge; border.width: 1

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -12
            text: panel.speed.toFixed(1)
            color: panel.accentHi
            font.pixelSize: 108
            font.family: "Orbitron"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            text: "KNOTS"
            color: panel.textDim
            font.pixelSize: 20
            font.family: "Orbitron"
            font.letterSpacing: 8
        }
    }

    // ================== MOTEURS ==================
    Rectangle {
        id: rpmCard
        x: 32; y: 302
        width: panel.width - 64
        height: 336
        color: panel.card
        radius: 20
        border.color: panel.edge; border.width: 1

        Text {
            x: 28; y: 20
            text: "MOTOR RPM"
            color: panel.textDim
            font.pixelSize: 14
            font.family: "Orbitron"
            font.letterSpacing: 3
        }

        // ----- Jauge BORD (gauche) -----
        Item {
            id: gaugeL
            x: rpmCard.width / 2 - 170
            y: 66
            width: 120
            height: 220

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                text: Math.round(panel.rpmL)
                color: panel.rpmL > 4000 ? panel.warn : panel.textMain
                font.pixelSize: 26
                font.family: "Orbitron"
            }
            Rectangle {
                y: 40
                width: 120; height: 130
                radius: 12
                color: "#0E141B"
                border.color: panel.edge
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    height: Math.min(panel.rpmL / 8000 * 118, 118)
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0; color: panel.rpmL > 4000 ? "#FF6B6B" : panel.accentHi }
                        GradientStop { position: 1; color: panel.rpmL > 4000 ? "#B91C1C" : "#0E7490" }
                    }
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }
            }
            Text {
                y: 182
                anchors.horizontalCenter: parent.horizontalCenter
                text: "PORT"
                color: panel.textDim
                font.pixelSize: 14
                font.family: "Orbitron"
                font.letterSpacing: 2
            }
        }

        // ----- Jauge TRIBORD (droite) -----
        Item {
            id: gaugeR
            x: rpmCard.width / 2 + 50
            y: 66
            width: 120
            height: 220

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                text: Math.round(panel.rpmR)
                color: panel.rpmR > 4000 ? panel.warn : panel.textMain
                font.pixelSize: 26
                font.family: "Orbitron"
            }
            Rectangle {
                y: 40
                width: 120; height: 130
                radius: 12
                color: "#0E141B"
                border.color: panel.edge
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    height: Math.min(panel.rpmR / 8000 * 118, 118)
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0; color: panel.rpmR > 4000 ? "#FF6B6B" : panel.accentHi }
                        GradientStop { position: 1; color: panel.rpmR > 4000 ? "#B91C1C" : "#0E7490" }
                    }
                    Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }
                }
            }
            Text {
                y: 182
                anchors.horizontalCenter: parent.horizontalCenter
                text: "STARBOARD"
                color: panel.textDim
                font.pixelSize: 14
                font.family: "Orbitron"
                font.letterSpacing: 2
            }
        }
    }

    // ================== ÉNERGIE ==================
    Rectangle {
        id: energyCard
        x: 32; y: 658
        width: panel.width - 64
        height: 126
        color: panel.card
        radius: 20
        border.color: panel.edge; border.width: 1

        Column {
            x: 28; y: 22
            spacing: 16

            Row {
                spacing: 10
                Text { text: "PORT"; color: panel.textDim; font.pixelSize: 12; font.family: "Orbitron"; anchors.verticalCenter: barL.verticalCenter }
                Rectangle {
                    id: barL
                    width: 200; height: 12; radius: 6; color: "#0E141B"
                    Rectangle {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                        width: Math.min(panel.battL / 100 * 200, 200)
                        radius: 6; color: panel.ok
                        Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
                    }
                }
                Text { text: Math.round(panel.battL) + "%"; color: panel.textMain; font.pixelSize: 14; font.family: "Orbitron"; anchors.verticalCenter: barL.verticalCenter }
            }

            Row {
                spacing: 10
                Text { text: "STBD"; color: panel.textDim; font.pixelSize: 12; font.family: "Orbitron"; anchors.verticalCenter: barR.verticalCenter }
                Rectangle {
                    id: barR
                    width: 200; height: 12; radius: 6; color: "#0E141B"
                    Rectangle {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                        width: Math.min(panel.battR / 100 * 200, 200)
                        radius: 6; color: panel.ok
                        Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
                    }
                }
                Text { text: Math.round(panel.battR) + "%"; color: panel.textMain; font.pixelSize: 14; font.family: "Orbitron"; anchors.verticalCenter: barR.verticalCenter }
            }
        }

        // --- Solaire ---
        Item {
            anchors.right: parent.right
            anchors.rightMargin: 32
            anchors.verticalCenter: parent.verticalCenter
            width: 170

            Row {
                spacing: 14
                Rectangle {
                    width: 12; height: 12; radius: 6
                    color: "#FBBF24"
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 1100 }
                        NumberAnimation { to: 1.0; duration: 1100 }
                    }
                }
                Column {
                    Text { text: "SOLAR"; color: panel.textDim; font.pixelSize: 12; font.family: "Orbitron"; font.letterSpacing: 2 }
                    Text { text: Math.round(panel.solar) + " W"; color: panel.accentHi; font.pixelSize: 22; font.family: "Orbitron" }
                }
            }
        }
    }
}
