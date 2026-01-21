import QtQuick
import Quickshell.Io
import qs.Services.UI
import qs.Commons
import "ColorPickerUtils.js" as ColorPickerUtils

Item {
  id: colorPickerService

  /// Required property - plugin API for saving settings
  property var pluginApi: null

  /// Maximum number of colors to keep in history (default: 36 for 6x6 grid)
  property int maxHistorySize: 36

  /// Internal state - accumulates stdout output from the color picker process
  property string stdoutBuffer: ""

  /**
   * Process to run niri msg pick-color command
   * This launches niri's built-in color picker and captures the selected color
   */
  Process {
    id: colorPickerProcess
    command: ["niri", "msg", "pick-color"]

    // Capture stdout line by line
    stdout: SplitParser {
      onRead: function(data) {
        colorPickerService.stdoutBuffer += data + "\n"
        Logger.i("ColorPicker: Received stdout line:", data)
      }
    }

    // Handle process completion and parse the output
    onExited: function(exitCode, exitStatus) {
      // Check if process failed or was cancelled
      if (exitCode !== 0) {
        Logger.i("ColorPicker: niri pick-color failed with exit code:", exitCode)
        ToastService.showError(colorPickerService.pluginApi?.tr("colorPicker.cancelled"))
        colorPickerService.stdoutBuffer = ""
        return
      }

      // Get the accumulated output
      var output = colorPickerService.stdoutBuffer
      colorPickerService.stdoutBuffer = ""

      // Parse the output to extract hex color
      var hexColor = ColorPickerUtils.parseNiriColorOutput(output)

      if (hexColor) {
        // Save to plugin settings and add to history
        ColorPickerUtils.saveColorToSettings(
          colorPickerService.pluginApi,
          hexColor,
          colorPickerService.maxHistorySize
        )

        // Copy to clipboard
        ColorPickerUtils.copyToClipboard(clipboardProcess, hexColor)

        // Show success notification
        ToastService.showNotice(colorPickerService.pluginApi?.tr("colorPicker.copied", { color: hexColor }))
      } else {
        // Parsing failed
        ToastService.showError(colorPickerService.pluginApi?.tr("colorPicker.parseFailed"))
      }
    }
  }

  Process {
    id: clipboardProcess
  }

  function pickColor() {
    stdoutBuffer = ""  // Clear buffer before starting
    colorPickerProcess.running = true
  }
}
