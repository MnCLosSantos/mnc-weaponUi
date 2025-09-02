Config = {}

-- Default UI style (1–5)
Config.DefaultStyle = 1 

-- UI Position & Size
Config.UI = {
    x = "2vw",  -- Left offset
    y = "2vh",  -- Top offset
    width = "200px",
    height = "40px"
}

-- Command to switch UI style
Config.StyleCommand = "weaponui"

-- For the funky guys
Config.UseQuasarInventory = false -- Set to true if using Quasar inventory

-- Framework auto-detect
Config.UseOxInventory = GetResourceState('ox_inventory') == 'started'
Config.UseQbInventory = GetResourceState('qb-inventory') == 'started'

