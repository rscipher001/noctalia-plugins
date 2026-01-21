/**
 * Common utilities for the niri color picker plugin
 * Provides shared functions for color picking, parsing, and history management
 */

/**
 * Parse niri's color output and extract the hex value
 * @param {string} output - Raw output from 'niri msg pick-color' command
 * @returns {string|null} - Hex color string (e.g., "#282828") or null if parsing fails
 *
 * Expected output format from niri:
 * Picked color: rgb(R, G, B)
 * Hex: #XXXXXX
 */
function parseNiriColorOutput(output) {
    try {
        // Extract hex value directly from "Hex: #XXXXXX" line
        var hexMatch = output.match(/Hex:\s*(#[0-9A-Fa-f]{6})/)

        if (hexMatch && hexMatch[1]) {
            return hexMatch[1].toUpperCase()
        }
    } catch (e) {
        console.error("ColorPicker parse error:", e)
    }
    return null
}

/**
 * Add a color to the history array
 * @param {Array} history - Current color history array
 * @param {string} hexColor - Hex color to add (e.g., "#282828")
 * @param {number} maxSize - Maximum size of history (default: 36 for 6x6 grid)
 * @returns {Array} - Updated history array with the new color at the front
 *
 * Behavior:
 * - Removes duplicate if it exists
 * - Adds color to the front of the array
 * - Limits array to maxSize items
 */
function addToColorHistory(history, hexColor, maxSize) {
    maxSize = maxSize || 36  // Default to 6x6 grid

    // Ensure history is an array
    if (!Array.isArray(history)) {
        history = []
    }

    // Remove duplicate if exists
    history = history.filter(function(c) { return c !== hexColor })

    // Add to front
    history.unshift(hexColor)

    // Limit to maxSize
    if (history.length > maxSize) {
        history = history.slice(0, maxSize)
    }

    return history
}

/**
 * Move a color from any position to the front of the history
 * @param {Array} history - Current color history array
 * @param {string} hexColor - Hex color to move to front
 * @returns {Array} - Updated history array with the color at the front
 *
 * This is useful when a user selects a color from the history panel
 * to make it the most recently used color
 */
function moveColorToFront(history, hexColor) {
    // Ensure history is an array
    if (!Array.isArray(history)) {
        history = []
    }

    // Remove from current position
    history = history.filter(function(c) { return c !== hexColor })

    // Add to front
    history.unshift(hexColor)

    return history
}

/**
 * Copy text to clipboard using wl-copy
 * @param {Process} clipboardProcess - QML Process object to use for clipboard operation
 * @param {string} text - Text to copy to clipboard
 *
 * This function requires a QML Process object to be passed in because
 * JavaScript cannot directly create QML objects
 */
function copyToClipboard(clipboardProcess, text) {
    if (!clipboardProcess) {
        console.error("ColorPicker: clipboardProcess is null")
        return false
    }

    clipboardProcess.command = ["wl-copy", text]
    clipboardProcess.running = true
    return true
}

/**
 * Save color to plugin settings and history
 * @param {object} pluginApi - Plugin API object
 * @param {string} hexColor - Hex color to save
 * @param {number} maxHistorySize - Maximum history size (default: 36)
 * @returns {boolean} - True if saved successfully, false otherwise
 *
 * This function adds the color to the color history array
 */
function saveColorToSettings(pluginApi, hexColor, maxHistorySize) {
    if (!pluginApi || !pluginApi.pluginSettings) {
        console.error("ColorPicker: pluginApi or pluginSettings is null")
        return false
    }

    maxHistorySize = maxHistorySize || 36

    // Get current history
    var history = pluginApi.pluginSettings.colorHistory || []

    // Add to history
    history = addToColorHistory(history, hexColor, maxHistorySize)

    // Update settings
    pluginApi.pluginSettings.colorHistory = history
    pluginApi.saveSettings()

    return true
}

/**
 * Clear all color history
 * @param {object} pluginApi - Plugin API object
 * @returns {boolean} - True if cleared successfully, false otherwise
 */
function clearColorHistory(pluginApi) {
    if (!pluginApi || !pluginApi.pluginSettings) {
        console.error("ColorPicker: pluginApi or pluginSettings is null")
        return false
    }

    pluginApi.pluginSettings.colorHistory = []
    pluginApi.saveSettings()

    return true
}
