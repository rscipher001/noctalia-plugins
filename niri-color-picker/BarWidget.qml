import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.Compositor

// Bar widget for picking colors using niri's built-in color picker
// When clicked, runs `niri msg pick-color`, parses the output, and copies hex to clipboard
NIconButton {
    //---- ICON WIDGET BOILERPLATE START ----//
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    icon: "color-picker"
    baseSize: Style.capsuleHeight
    applyUiScale: false
    customRadius: Style.radiusL
    colorBg: Style.capsuleColor
    colorFg: Color.mOnSurface
    colorBorder: "transparent"
    colorBorderHover: "transparent"
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth
    tooltipText: pluginApi.tr("widget.tooltip")
    tooltipDirection: BarService.getTooltipDirection(screen?.name)               
    //---- ICON WIDGET BOILERPLATE END ----//

    readonly property var mainInstance: pluginApi?.mainInstance

    // Read grid size from the settings
    readonly property string gridSize:
      pluginApi?.pluginSettings?.gridSize||
      pluginApi?.manifest?.metadata?.defaultSettings?.gridSize||
      "6"

    // Hide widget if not on Niri compositor
    visible: CompositorService.isNiri

    Component.onCompleted: {
        if (!CompositorService.isNiri) {
            Logger.w("Niri Color Picker", "Widget disabled - requires Niri compositor")
        }
    }

    /// Color picker service handles the process lifecycle
    ColorPickerService {
        id: colorPickerService
        pluginApi: root.pluginApi
        maxHistorySize: root.gridSize * root.gridSize
    }

    onClicked: function(mouse) {
        colorPickerService.pickColor()
    }

    onRightClicked: {
        if (pluginApi) {
            pluginApi.openPanel(root.screen)
            Logger.i("Niri Color Picker", "Opening color history panel")
        }
    }
}
