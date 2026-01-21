import QtQuick
import Quickshell.Io
import qs.Services.UI

Item {
  property var pluginApi: null

  readonly property string gridSize:
    pluginApi?.pluginSettings?.gridSize||
    pluginApi?.manifest?.metadata?.defaultSettings?.gridSize||
    "6"

  /// Color picker service handles the process lifecycle
  ColorPickerService {
    id: colorPickerService
    pluginApi: parent.pluginApi
    maxHistorySize: parent.gridSize
  }

  /**
   * Start the color picker process
   * This can be called from IPC handlers or other QML code
   */
  function pickColor() {
    colorPickerService.pickColor()
  }

  IpcHandler {
    target: "plugin:niri-color-picker"

    /**
     * IPC command to trigger color picking
     * Usage: qs ipc call plugin:niri-color-picker pickColor
     */
    function pickColorCommand() {
      colorPickerService.pickColor()
    }

    /**
     * IPC command to toggle the color history panel
     * Usage: qs ipc call plugin:niri-color-picker togglePanel
     */
    function togglePanel() {
      pluginApi.openPanel(screen)
    }
  }
}
