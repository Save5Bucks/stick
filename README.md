# 🚗 Manual Transmission Script for FiveM

**Version:** 1.0.0  
**Author:** _Save5Bucks_  
**Game:** Grand Theft Auto V (FiveM)

---

## 📜 Overview

This resource provides a **manual transmission system** for vehicles in FiveM, offering players more control over their vehicle's performance. With real-time gear and RPM updates displayed via a UI, players can experience a more immersive driving experience.

---

## 🚀 Installation

1. **Download** or **clone** this repository into your `resources` folder.

2. **Ensure the resource** is included in your `server.cfg`:

   ```plaintext
   ensure stick
   ```

3. **Configure** your transmission settings in `config.lua`. Adjust the transmission mode and flags according to your preference.

4. **Start your server** and enjoy manual transmission in your vehicles!

---

## 🛠️ Configuration

### `config.lua`

This file contains the settings for the manual transmission system, allowing you to customize how the script interacts with the vehicle.

```lua
Config.ManualTransmissionFlag = 0x400
Config.AutomaticTransmissionFlag = 0x200
```

You can define flags and tweak other parameters to fit your server's needs.

---

## 🎮 Usage

Once your server is running, players can manually shift gears using the following keys:

command:
```plaintext
/stick
```

- **Upshift**: Moves the vehicle to the next gear.
- **Downshift**: Lowers the vehicle to the previous gear.

The script dynamically adjusts to the vehicle's max gears, ensuring a smooth transition through all gears.

---

## 🔧 Features

- **Manual Gear Shifting**: Provides a realistic driving experience by allowing players to manually control their vehicle’s gears.
- **Dynamic Gear Detection**: Automatically detects the number of gears in the vehicle.
- **Real-Time Gear & RPM Display**: Displays the current gear and RPM on the UI in real-time.
- **Automatic & Manual Modes**: Allows players to switch between manual and automatic transmissions.

---

## 🌟 Future Enhancements

- Additional customization options for gear control.
- Enhanced UI to make it more user-friendly.
- Support for specialized vehicle types.

---

## 📝 Notes

- Ensure that your server is properly configured to run this resource.
- Customizing transmission flags may require some testing to optimize vehicle performance.

---

## 📧 Support

For support or questions, feel free to contact me at [flinn6171 - Discord] or visit our community forums.

---

### 🚀 Take full control of your vehicle's transmission with this advanced manual transmission script!

---

_Drive safe, shift smarter!_
