# 🎯 MNC Weapon UI

A customizable weapon UI system for FiveM QBCore servers that displays the current weapon and ammo count with multiple style options and persistent player preferences.

## ✨ Features

- 🔄 **Real-time weapon tracking** - Automatically detects when players switch weapons
- 🎯 **Ammo display** - Shows current ammunition count for equipped weapons
- 🎨 **5 Different UI styles** - Players can choose from 5 unique visual styles
- 💾 **Persistent preferences** - Player style choices are saved to the database
- 📦 **Inventory compatibility** - Works with both ox_inventory and qb-inventory
- 📍 **Configurable positioning** - Customize UI position and size
- ✨ **Smooth animations** - Fade-in/out effects for better user experience
- ⌨️ **Command system** - Easy style switching via in-game commands

## 👀 Preview

The UI displays in the top-left corner by default and shows:
- 🔫 Weapon name
- 🎯 Current ammo count  
- 🖼️ Weapon image (from inventory system)
- 🎨 Customizable styling based on player preference

## 📋 Requirements

- 🏗️ **QBCore Framework**
- 🗄️ **MySQL Database**
- 📚 **ox_lib** (for notifications)
- 📦 **ox_inventory** OR **qb-inventory** (for weapon images)

## 🚀 Installation

1. 📥 **Download** the resource and place it in your `resources` folder

2. 🗄️ **Database Setup** - Run this SQL query to create the required table:
```sql
CREATE TABLE IF NOT EXISTS `mnc_weapon_ui_styles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `style` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

3. ⚙️ **Add to server.cfg**:
```
ensure mnc-weaponui
```

4. 🔄 **Restart your server**

## ⚙️ Configuration

Edit `config.lua` to customize the resource:

```lua
Config = {}

-- Default UI style (1-5)
Config.DefaultStyle = 1 

-- UI Position & Size
Config.UI = {
    x = "2vw",      -- Left offset from screen edge
    y = "2vh",      -- Top offset from screen edge  
    width = "200px", -- UI width
    height = "40px"  -- UI height
}

-- Command to switch UI style
Config.StyleCommand = "weaponui"

-- Inventory auto-detection (don't change these)
Config.UseOxInventory = GetResourceState('ox_inventory') == 'started'
Config.UseQbInventory = GetResourceState('qb-inventory') == 'started'
```

## 📖 Usage

### 👤 For Players

**🎨 Change UI Style:**
```
/weaponui [1-5]
```
- `/weaponui 1` - Style 1 (default)
- `/weaponui 2` - Style 2
- `/weaponui 3` - Style 3
- `/weaponui 4` - Style 4
- `/weaponui 5` - Style 5

The UI will automatically appear when you equip a weapon and disappear when you holster it.

### 👨‍💼 For Server Owners

**🎨 Customize Styles:**
- Edit the CSS files (`style1.css`, `style2.css`, etc.) to modify the appearance
- Adjust positioning in `config.lua`
- Modify the default style for new players

**📍 Positioning:**
- Use viewport units (vw/vh) for responsive positioning
- Use pixels (px) for fixed positioning
- Examples:
  - `x = "2vw"` - 2% from left edge
  - `x = "50px"` - 50 pixels from left edge

## 🖼️ Style Previews

### 🎨 Style 1
<img width="1920" height="1080" alt="FiveM® by Cfx re 20_08_2025 11_20_16" src="https://github.com/user-attachments/assets/d9022dfe-0349-48b2-a277-2a3c98250c40" />

### 🎨 Style 2
<img width="1920" height="1080" alt="FiveM® by Cfx re 20_08_2025 11_20_45" src="https://github.com/user-attachments/assets/d591cd77-1191-45c2-88ab-7db76ee2ec51" />

### 🎨 Style 3
<img width="1920" height="1080" alt="FiveM® by Cfx re 20_08_2025 11_20_57" src="https://github.com/user-attachments/assets/666abb25-a1aa-4595-bcf3-4e340ac5be78" />

### 🎨 Style 4
<img width="1920" height="1080" alt="FiveM® by Cfx re 20_08_2025 11_21_05" src="https://github.com/user-attachments/assets/b65653ce-6437-4204-9d09-e4ebc519730d" />

### 🎨 Style 5
<img width="1920" height="1080" alt="FiveM® by Cfx re 20_08_2025 11_21_11" src="https://github.com/user-attachments/assets/cb18c438-71b1-4ba2-8bf3-cfaba9553643" />

## 🛠️ Customization

### ➕ Adding New Styles

1. 📄 Create a new CSS file (e.g., `style6.css`) in the `html` folder
2. 🔄 Update the style selection logic in both client and server code
3. ⚙️ Modify the command validation to accept the new style number

### 🖼️ Changing Weapon Images

The resource automatically detects and uses images from:
- 📦 **ox_inventory**: `nui://ox_inventory/web/images/[weapon].png`
- 📦 **qb-inventory**: `nui://qb-inventory/html/images/[weapon].png`

### ✨ Modifying Animations

Edit the CSS files to change:
- ⏱️ Fade-in duration
- 🔄 Transition effects  
- 🖱️ Hover states
- 🎨 Color schemes

## 🔧 Troubleshooting

**❌ UI not showing:**
- 🔍 Check console for errors
- 📚 Ensure ox_lib is installed
- 🗄️ Verify database table was created correctly
- ✅ Check if inventory resource is started

**🖼️ Images not loading:**
- ✅ Verify inventory resource is running
- 🔍 Check weapon name matches image filename
- 📁 Ensure image files exist in inventory resource

**🗄️ Database errors:**
- 🔌 Check MySQL connection
- 📋 Verify table structure matches requirements
- 🖥️ Check server console for SQL errors

## 🆘 Support

For support, issues, or feature requests:
- 🔍 Check the console for error messages
- ✅ Verify all requirements are met
- 🧪 Test with default configuration first

## 👏 Credits

- 👨‍💻 **Author**: Stan Leigh
- 🏗️ **Framework**: QBCore/QBOX
- 📦 **Compatible with**: ox_inventory, qb-inventory
- 💬 **Support**: **https://discord.gg/aTBsSZe5C6**
  
---

**📦 Version**: 1.1.3  
**📅 Last Updated**: 26/08/2025

