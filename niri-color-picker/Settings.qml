import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

// Settings UI Component for Hello World Plugin
ColumnLayout {
  id: root

  // Plugin API (injected by the settings dialog system)
  property var pluginApi: null

  // Local state - track changes before saving
  property string gridSize: pluginApi?.pluginSettings?.gridSize ||
    pluginApi?.manifest?.metadata?.defaultSettings?.gridSize ||
    "6";

  spacing: Style.marginM

  Component.onCompleted: {
    Logger.i("Niri Color Picker", "Settings UI loaded");
  }

  function saveSettings() {
    pluginApi.pluginSettings.gridSize = root.gridSize
    pluginApi.saveSettings();
    Logger.i("Niri Color Picker", "Settings saved");
  }

  NTextInput {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.gridSize")
    description: pluginApi?.tr("settings.gridSizeDescription")
    placeholderText: "6"
    text: root.gridSize
    onTextChanged: root.gridSize = text
  }
}
