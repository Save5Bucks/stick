# 🚗 Manual Transmission Script for FiveM

This FiveM resource enables manual transmission for vehicles, providing realistic driving mechanics where players can manually shift gears and see real-time gear and RPM data on a UI. The script is compatible with the QB-Core framework.

## 🔧 Features:

- 🔄 **Manual Gear Shifting**: Players can shift gears up or down using defined keys.
- 📊 **Real-Time Gear and RPM Display**: The UI updates dynamically to reflect the current gear and RPM.
- 🛠 **Automatic & Manual Transmission Modes**: Toggle between automatic and manual modes on demand.
- 🚗 **Dynamic Gear Detection**: Adapts to the vehicle’s maximum gears by fetching handling data automatically.

---

## 📂 Script Structure:

### 1. **Client-Side** (`client.lua`)

Handles the core logic for manual transmission control:

- ⚙️ **fetchMaxGearsFromVehicle()**: Retrieves the maximum gear count from the vehicle's handling data.
- 🔧 **setManualTransmissionFlag()**: Enables manual transmission using vehicle flags.
- ⬆️ **Upshift()** & ⬇️ **DownShift()**: Functions that shift gears based on user input.
- 📡 **sendGearDataToUI()**: Sends the current gear and RPM to the UI for display.

### 2. **Server-Side** (`server.lua`)

- 📝 Performs version checks by comparing the local script version with the latest available version online.

### 3. **Configuration** (`config.lua`)

- 🛠 Holds essential settings such as transmission flags and handling behaviors.

### 4. **UI Assets** (`html` folder)

- 🎨 Contains the front-end elements, including the HTML, CSS, and JavaScript required for the gear and RPM display.

---

## 🎮 Commands & Keybinds:

- ⬆️ **Upshift**: Increases the current gear when the up arrow is pressed.
- ⬇️ **Downshift**: Decreases the gear when the down arrow is pressed.

---

## 📦 Installation:

1. 🗂 Copy the `stick` folder into your FiveM resource directory.
2. 📝 Add `ensure stick` to your `server.cfg`.
3. ⚙️ Configure settings in `config.lua` as per your server needs.

---

Elevate your driving experience by shifting gears manually and take control over vehicle performance with this robust transmission script!
