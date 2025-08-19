# mnc-qb-weapons-replacement
<img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/416f5d50-1367-41fb-81e4-3c1b40314b95" />

QB-Weapons is a weapon management script for the QB-Core framework in FiveM. It handles weapon equipping, ammo management, reloading, unloading, attachment application, tints, and weapon repair functionality. The script ensures that weapon clip sizes are adjusted based on attachments (e.g., extended or drum magazines) and provides a robust system for managing weapon durability and inventory interactions.

## Features

## To change ui simple replcae contents of style.css with the contents of the one you like.
- Synth-Pulse Ui
<img width="346" height="231" alt="synth-pulse" src="https://github.com/user-attachments/assets/e3a61e18-d1ce-4367-9afb-e63f4813229c" />

- Cyan-Glow Ui
<img width="346" height="231" alt="cyan-glow" src="https://github.com/user-attachments/assets/ef8a7c76-35e5-48ac-960d-4bbbc266e009" />


- **Weapon Equipping**: Equip and unequip weapons with proper ammo and attachment handling.
- **Reload System**: Reload weapons using the 'R' key, respecting the weapon's effective clip size (including attachment modifiers like extended magazines).
- **Unload System**: Unload ammo from weapons using the 'P' key, returning ammo items to the player's inventory.
- **Attachment Support**: Apply and remove weapon attachments (e.g., extended magazines, drum magazines) using the original QB-Core method, with clip size adjustments for reloading.
- **Weapon Tints**: Apply tints to weapons, including MK2-specific tints.
- **Weapon Repair**: Repair weapons at designated repair points with configurable costs based on weapon class.
- **Ammo Management**: Manage ammo through inventory items, with support for different ammo types and amounts.
- **Durability System**: Tracks weapon durability, reducing quality with use and disabling broken weapons.
- **Throwable Weapons**: Handles special weapons like grenades and snowballs with specific ammo logic.
- **Debug Logging**: Extensive debug prints for troubleshooting clip size calculations, ammo updates, and attachment handling.

## Installation

1. **Clone or Download the Repository**:
   - Clone this repository or download the ZIP file and extract it into your FiveM server's `resources` directory making sure to rename "qb-weapons" and replace the original "qb-weapons" completely.

2. **Add to Server Configuration**:
   - Add `ensure qb-weapons` to your `server.cfg` file to ensure the script loads.

3. **Install Dependencies**:
   - Ensure the following dependencies are installed and configured:
     - `qb-core`
     - `qb-inventory`
     - `qb-phone` (for repair notifications)
   - Verify that these resources are running before `qb-weapons`.

4. **Configure the Script**:
   - Edit the `config.lua` file to set up:
     - `Config.WeaponRepairPoints`: Coordinates and settings for weapon repair locations.
     - `Config.WeaponRepairCosts`: Repair costs by weapon class (e.g., pistol, smg).

5. **Restart the Server**:
   - Restart your FiveM server or use `refresh` followed by `start qb-weapons` to load the script.

## Usage

- **Equipping Weapons**:
  - Weapons are equipped via the inventory system. When a weapon is selected, its ammo and attachments are applied, with clip size adjusted based on attachments (e.g., 1.5x for extended magazines, 2x for drum magazines).

- **Reloading**:
  - Press the 'R' key while holding a weapon to reload. The script checks the effective clip size (including attachment modifiers) and calculates the required ammo items from the player's inventory.
  - Example: For a pistol with a base clip size of 12 rounds and an extended magazine (1.5x), the clip size becomes 18 rounds. Reloading will fill up to this amount if sufficient ammo items are available.

- **Unloading**:
  - Press the 'P' key to unload ammo from the current weapon, returning ammo items to the inventory based on the configured ammo amount per item.

- **Applying Attachments**:
  - Use attachment items (e.g., `extended_clip`) from the inventory to apply them to the current weapon. The script checks compatibility and updates the weapon's clip size accordingly.

- **Applying Tints**:
  - Use tint items (e.g., `weapontint_0`, `weapontint_mk2_1`) to apply tints to weapons. MK2 tints are restricted to MK2 weapons.

- **Repairing Weapons**:
  - Visit a repair point (defined in `Config.WeaponRepairPoints`) to repair a weapon. Costs vary by weapon class, and the process takes 5-10 minutes, with a notification sent via `qb-phone` when complete.
