import QtQuick
import QtQuick.Controls
import QtCharts
import Boat 1.0

Rectangle {
    id: panel
    property string varName: ""
    property alias variable: panel.varName
    property int historyPoints: 200
    property int xDuration: 5  // durée en minutes par défaut
    property Boat boat
    property string unit: "RPM"
    property real yMin: 0
    property real yMax: 8000
    property string label: varName
    property double lastValue: 0
    property bool hasData: false

    width: 400
    height: 200
    color: "#4e4949"
    radius: 10

    Timer {
        id: graphTimer
        interval: 1000
        running: parent.hasData
        repeat: true
        onTriggered: appendValue(Date.now(), lastValue)
    }

    // --- Label variable en haut à gauche ---
    Text {
        text: panel.label
        color: "#efe7e5"
        font.pixelSize: 12
        font.family: "Orbitron"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 8
        z: 10
    }

    // --- Valeur courante en haut à droite ---
    Text {
        id: currentValueText
        text: "-- " + panel.unit
        color: "#efe7e5"
        font.pixelSize: 14
        font.family: "Orbitron"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        z: 10
    }

    ChartView {
        id: chart
        anchors.fill: parent
        antialiasing: true
        backgroundColor: "transparent"
        plotAreaColor: "transparent"
        legend.visible: false
        margins.top: 30
        margins.bottom: 5
        margins.left: 5
        margins.right: 5

        // Axe X — timestamps en hh:mm:ss
        DateTimeAxis {
            id: xAxis
            format: "hh:mm:ss"
            tickCount: 5
            labelsFont.pixelSize: 9
            labelsColor: "#8F8F8F"
            gridLineColor: "#8F8F8F"
            color: "#8F8F8F"
        }

        // Axe Y — valeur avec unité
        ValueAxis {
            id: yAxis
            min: panel.yMin
            max: panel.yMax
            tickCount: 5
            labelsFont.pixelSize: 9
            labelsColor: "#8F8F8F"
            gridLineColor: "#8F8F8F"
            color: "#8F8F8F"
            labelFormat: "%d " + panel.unit
        }

        LineSeries {
            id: series
            axisX: xAxis
            axisY: yAxis
            color: "#efe7e5"
            width: 2
            useOpenGL: true
        }
    }

    // --- Fonction ajout point ---
    function appendValue(timestamp, value) {
        var t = timestamp instanceof Date ? timestamp.getTime() : timestamp
        series.append(t, value)
        currentValueText.text = value.toFixed(0) + " " + panel.unit

        if (series.count > historyPoints)
            series.remove(0)

        // xDuration en minutes → convertir en ms
        var now = new Date(t)
        xAxis.max = now
        xAxis.min = new Date(t - xDuration * 60 * 1000)
    }

    Component.onCompleted: {
        // --- Guards ---
        if (!boat) {
            console.warn("[GraphBoat] boat est NULL !")
            return
        }
        if (!varName || varName.length === 0) {
            console.warn("[GraphBoat] varName est vide !")
            return
        }
        console.log("[GraphBoat] Init pour variable:", varName)

        // --- Initialiser les axes X ---
        var now = new Date()
        xAxis.max = now
        xAxis.min = new Date(now.getTime() - xDuration * 60 * 1000)

        // --- 1. Charger historique SQLite ---
        var history = boat.getHistory(varName, historyPoints)
        console.log("[GraphBoat] Historique:", history.length, "points pour", varName)
        for (var h = 0; h < history.length; h++) {
            appendValue(history[h].time, history[h].value)
        }

        // --- 2. Écouter les mises à jour live ---
        console.log("[GraphBoat] Connexion signal valueUpdated pour:", varName)
        boat.valueUpdated.connect(function(key, val) {
            if (key === varName) {
                lastValue = val
                hasData = true
            }
        })
    }
}
