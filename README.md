# 🎯 MNC Weapon UI
![wallpapersden com_k-grand-theft-auto-v-scenery_2048x1152](https://github.com/user-attachments/assets/a5da7a39-d329-4a97-ae82-6d10dd430517)

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
<img width="320" height="133" alt="1" src="https://github.com/user-attachments/assets/aee4fc69-bb4a-47b4-b879-4b4bbf29286a" />

### 🎨 Style 2
<img width="320" height="133" alt="2" src="https://github.com/user-attachments/assets/73cd9e73-8acb-44b1-bd33-31e152817d04" />

### 🎨 Style 3
<img width="320" height="133" alt="3" src="https://github.com/user-attachments/assets/5f512dc7-d434-46f7-a2d7-b942ff2cecbb" />

### 🎨 Style 4
<img width="320" height="133" alt="4" src="https://github.com/user-attachments/assets/464bbc43-32cc-49cb-96cf-15b9582fdf87" />

### 🎨 Style 5
<img width="320" height="133" alt="5" src="https://github.com/user-attachments/assets/8484f470-935e-4856-9175-d8161410f8e5" />


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

