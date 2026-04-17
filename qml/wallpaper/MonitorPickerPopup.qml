import Quickshell
import QtQuick
import ".."

Rectangle {
  id: monitorPicker
  visible: false
  anchors.fill: parent
  z: 200
  color: monitorPicker.colors ? Qt.rgba(monitorPicker.colors.surface.r, monitorPicker.colors.surface.g, monitorPicker.colors.surface.b, 0.97)
                               : Qt.rgba(0.08, 0.08, 0.12, 0.97)
  radius: 8

  property var colors
  property var _pendingItem: null
  property var _selectedOutputs: []

  signal accepted(var item, var outputs)
  signal cancelled()

  function open(item) {
    _pendingItem = item
    var screens = Quickshell.screens
    var initial = []
    for (var i = 0; i < screens.length; i++)
      initial.push({ name: screens[i].name, width: screens[i].width, height: screens[i].height, selected: true })
    _selectedOutputs = initial
    visible = true
  }

  function close() {
    visible = false
    _pendingItem = null
    _selectedOutputs = []
  }

  MouseArea { anchors.fill: parent; onClicked: function(mouse) { mouse.accepted = true } }

  Column {
    anchors.centerIn: parent
    spacing: 12
    width: parent.width * 0.7

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "\u{f0379}"
      font.family: Style.fontFamilyNerdIcons; font.pixelSize: 28
      color: monitorPicker.colors ? monitorPicker.colors.primary : "#7986cb"
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "SELECT MONITORS"
      font.family: Style.fontFamily; font.pixelSize: 14; font.weight: Font.Bold; font.letterSpacing: 1.5
      color: monitorPicker.colors ? monitorPicker.colors.surfaceText : "#fff"
    }

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: "Choose which monitors to apply the wallpaper to."
      font.family: Style.fontFamily; font.pixelSize: 11; font.letterSpacing: 0.2
      color: monitorPicker.colors ? Qt.rgba(monitorPicker.colors.surfaceText.r, monitorPicker.colors.surfaceText.g, monitorPicker.colors.surfaceText.b, 0.6)
                                  : Qt.rgba(1, 1, 1, 0.5)
      wrapMode: Text.WordWrap
      lineHeight: 1.3
    }

    Item { width: 1; height: 4 }

    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 6

      Repeater {
        model: monitorPicker._selectedOutputs.length

        Rectangle {
          width: 260; height: 32; radius: 6
          color: {
            var entry = monitorPicker._selectedOutputs[index]
            if (!entry) return Qt.rgba(0, 0, 0, 0.2)
            return entry.selected
              ? (monitorPicker.colors ? Qt.rgba(monitorPicker.colors.primary.r, monitorPicker.colors.primary.g, monitorPicker.colors.primary.b, 0.18) : Qt.rgba(0.3, 0.4, 0.7, 0.18))
              : Qt.rgba(0, 0, 0, 0.15)
          }
          border.width: 1
          border.color: {
            var entry = monitorPicker._selectedOutputs[index]
            if (!entry) return "transparent"
            return entry.selected
              ? (monitorPicker.colors ? Qt.rgba(monitorPicker.colors.primary.r, monitorPicker.colors.primary.g, monitorPicker.colors.primary.b, 0.4) : Qt.rgba(0.3, 0.4, 0.7, 0.4))
              : "transparent"
          }
          anchors.horizontalCenter: parent.horizontalCenter

          Item {
            anchors.fill: parent
            anchors.leftMargin: 10; anchors.rightMargin: 10

            Rectangle {
              id: monCheckbox
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              width: 16; height: 16; radius: 3
              color: {
                var entry = monitorPicker._selectedOutputs[index]
                if (!entry) return "transparent"
                return entry.selected
                  ? (monitorPicker.colors ? monitorPicker.colors.primary : "#7986cb")
                  : "transparent"
              }
              border.width: 1
              border.color: {
                var entry = monitorPicker._selectedOutputs[index]
                if (!entry) return Qt.rgba(1, 1, 1, 0.3)
                return entry.selected
                  ? (monitorPicker.colors ? monitorPicker.colors.primary : "#7986cb")
                  : Qt.rgba(1, 1, 1, 0.3)
              }

              Text {
                anchors.centerIn: parent
                text: "\u2713"
                font.pixelSize: 11; font.weight: Font.Bold
                color: "#fff"
                visible: {
                  var entry = monitorPicker._selectedOutputs[index]
                  return entry ? entry.selected : false
                }
              }
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: monCheckbox.right; anchors.leftMargin: 8
              text: {
                var entry = monitorPicker._selectedOutputs[index]
                return entry ? entry.name : ""
              }
              font.family: Style.fontFamily; font.pixelSize: 12; font.weight: Font.DemiBold
              color: monitorPicker.colors ? monitorPicker.colors.surfaceText : "#fff"
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.right: parent.right
              text: {
                var entry = monitorPicker._selectedOutputs[index]
                return entry ? entry.width + "×" + entry.height : ""
              }
              font.family: Style.fontFamily; font.pixelSize: 10
              color: monitorPicker.colors ? Qt.rgba(monitorPicker.colors.surfaceText.r, monitorPicker.colors.surfaceText.g, monitorPicker.colors.surfaceText.b, 0.5) : Qt.rgba(1, 1, 1, 0.4)
            }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              var arr = monitorPicker._selectedOutputs.slice()
              arr[index] = { name: arr[index].name, width: arr[index].width, height: arr[index].height, selected: !arr[index].selected }
              monitorPicker._selectedOutputs = arr
            }
          }
        }
      }
    }

    Item { width: 1; height: 2 }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 8

      FilterButton {
        colors: monitorPicker.colors
        label: "CANCEL"
        skew: 8; height: 26
        onClicked: { monitorPicker.cancelled(); monitorPicker.close() }
      }

      FilterButton {
        id: _acceptBtn
        property bool canAccept: {
          for (var i = 0; i < monitorPicker._selectedOutputs.length; i++)
            if (monitorPicker._selectedOutputs[i].selected) return true
          return false
        }
        colors: monitorPicker.colors
        label: "ACCEPT"
        skew: 8; height: 26
        hasActiveColor: true
        activeColor: canAccept ? (monitorPicker.colors ? monitorPicker.colors.primary : "#7986cb") : Qt.rgba(0.5, 0.5, 0.5, 0.3)
        isActive: canAccept
        activeOpacity: canAccept ? 1.0 : 0.4
        onClicked: {
          if (!canAccept) return
          var selected = []
          for (var i = 0; i < monitorPicker._selectedOutputs.length; i++) {
            if (monitorPicker._selectedOutputs[i].selected)
              selected.push(monitorPicker._selectedOutputs[i].name)
          }
          monitorPicker.accepted(monitorPicker._pendingItem, selected)
          monitorPicker.close()
        }
      }
    }
  }

  Keys.onEscapePressed: { monitorPicker.cancelled(); monitorPicker.close() }
}
