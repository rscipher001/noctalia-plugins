import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.Compositor
import "ColorPickerUtils.js" as ColorPickerUtils

// Panel Component showing color history in a 6x6 grid
Item {
  id: root

  // Plugin API (injected by PluginPanelSlot)
  property var pluginApi: null

  // Screen property (injected by PluginPanelSlot)
  property var screen: null

  // Grid configuration - fixed grid (400 colors)
  property int colorCellSize: 40 * Style.uiScaleRatio

  readonly property string gridSize:
    pluginApi?.pluginSettings?.gridSize||
    pluginApi?.manifest?.metadata?.defaultSettings?.gridSize||
    "6"
  property int cellSpacing: 10 * Style.uiScaleRatio

  property real contentPreferredWidth: (colorCellSize * gridSize) + (cellSpacing * (gridSize - 1)) + (Style.marginL * 2)
  property real contentPreferredHeight: contentPreferredWidth + 80 * Style.uiScaleRatio

  readonly property bool allowAttach: true

  // Color history from settings
  property var colorHistory: pluginApi?.pluginSettings?.colorHistory ?? []

  anchors.fill: parent

  Component.onCompleted: {
    if (pluginApi) {
      Logger.i("Niri Color Picker", "Panel initialized, history count:", colorHistory.length);
      if (!CompositorService.isNiri) {
        Logger.w("Niri Color Picker", "Panel opened on non-Niri compositor - color picking will not work");
      }
    }
  }

  // Process to copy color to clipboard
  Process {
    id: clipboardProcess
  }


  ColumnLayout {
    anchors {
      fill: parent
      margins: Style.marginL
    }
    spacing: Style.marginM

    // Header
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NLabel {
        Layout.fillWidth: true
        label: pluginApi?.tr("panel.title")
        description: pluginApi?.trp("panel.colorCount", colorHistory.length, "1 color saved", "{count} colors saved")
      }

      // Clear history button
      NIconButton {
        icon: "trash"
        baseSize: Style.baseWidgetSize
        colorBg: Style.capsuleColor
        colorFg: Color.mOnSurface
        colorBorder: "transparent"
        colorBorderHover: "transparent"
        tooltipText: pluginApi?.tr("panel.clearAll")

        onClicked: {
          if (root.pluginApi) {
            ColorPickerUtils.clearColorHistory(root.pluginApi)
            Logger.i("Niri Color Picker", "Color history cleared from panel")
          }
        }
      }
    }

    // Color grid
    Grid {
      id: colorGrid
      Layout.fillWidth: true
      Layout.fillHeight: true
      columns: root.gridSize
      spacing: root.cellSpacing

      Repeater {
        model: root.gridSize * root.gridSize

        Rectangle {
          id: colorCell
          width: root.colorCellSize
          height: root.colorCellSize
          radius: Style.radiusS

          property string cellColor: index < root.colorHistory.length ? root.colorHistory[index] : ""
          property bool hasColor: cellColor !== ""

          color: hasColor ? cellColor : Color.mSurfaceVariant
          border.width: 1
          border.color: hasColor ? Qt.darker(cellColor, 1.2) : Color.mOutline

          // Hover effect
          Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "white"
            opacity: cellMouseArea.containsMouse && colorCell.hasColor ? 0.2 : 0
          }

          // Empty state icon
          NIcon {
            anchors.centerIn: parent
            icon: "color-swatch"
            color: Color.mOutline
            pointSize: Style.fontSizeXS * Style.uiScaleRatio
            visible: !colorCell.hasColor
            opacity: 0.4
          }

          MouseArea {
            id: cellMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: colorCell.hasColor ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
              if (colorCell.hasColor) {
                var selectedColor = colorCell.cellColor

                // Copy color to clipboard
                ColorPickerUtils.copyToClipboard(clipboardProcess, selectedColor)
                Logger.i("Niri Color Picker", "Copied color from history:", selectedColor)

                // Move selected Niri Color Pickerto first position (unless already first)
                if (root.pluginApi && index > 0) {
                  var history = root.pluginApi.pluginSettings.colorHistory || []
                  history = ColorPickerUtils.moveColorToFront(history, selectedColor)
                  root.pluginApi.pluginSettings.colorHistory = history
                  root.pluginApi.saveSettings()
                }

                // Close the panel after selecting a color
                if (root.pluginApi) {
                  root.pluginApi.closePanel(root.screen)
                }
              }
            }
          }
        }
      }
    }
  }
}
