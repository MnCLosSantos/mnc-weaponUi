local QBCore = exports['qb-core']:GetCoreObject()
local currentWeapon, currentAmmo = nil, 0
local currentStyle = Config.DefaultStyle
local playerLoaded = false
local styleLoaded = false

-- Initialize when player is loaded
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerLoaded = true
    LoadPlayerStyle()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    playerLoaded = false
    styleLoaded = false
end)

-- Load player's saved style
function LoadPlayerStyle()
    QBCore.Functions.TriggerCallback('mnc-weaponui:getStyle', function(style)
        currentStyle = style
        styleLoaded = true
        print("[mnc-weaponui] Loaded style:", style) -- Debug print
        if currentWeapon then
            SendWeaponData()
        end
    end)
end

-- Main weapon tracking thread
CreateThread(function()
    -- Wait a bit for resource to fully initialize
    Wait(2000)
    
    -- If player is already loaded when resource starts, load their style
    if not playerLoaded then
        local PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.citizenid then
            playerLoaded = true
            LoadPlayerStyle()
        end
    end
    
    while true do
        Wait(250)
        if playerLoaded and styleLoaded then
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)

            if weapon ~= `WEAPON_UNARMED` then
                if weapon ~= currentWeapon then
                    currentWeapon = weapon
                    currentAmmo = GetAmmoInPedWeapon(ped, weapon)
                    SendWeaponData()
                else
                    local ammo = GetAmmoInPedWeapon(ped, weapon)
                    if ammo ~= currentAmmo then
                        currentAmmo = ammo
                        SendWeaponData()
                    end
                end
            else
                if currentWeapon ~= nil then
                    currentWeapon, currentAmmo = nil, 0
                    SendNUIMessage({ action = "hide" })
                end
            end
        end
    end
end)

-- Send data to UI
function SendWeaponData()
    if not currentWeapon or not playerLoaded or not styleLoaded then 
        print("[mnc-weaponui] SendWeaponData blocked - weapon:", currentWeapon, "playerLoaded:", playerLoaded, "styleLoaded:", styleLoaded)
        return 
    end
    
    local hash = currentWeapon
    local weaponInfo = QBCore.Shared.Weapons[hash]
    local weaponName = weaponInfo and weaponInfo.label or "Unknown"
    local image = GetWeaponImage(hash)

    local data = {
        action = "show",
        weapon = weaponName,
        ammo = currentAmmo,
        image = image,
        style = currentStyle,
        ui = Config.UI
    }
    
    print("[mnc-weaponui] Sending NUI data:", json.encode(data)) -- Debug print
    SendNUIMessage(data)
end

-- Get weapon image from qb, ox, or quasar inventory
function GetWeaponImage(hash)
    local weaponInfo = QBCore.Shared.Weapons[hash]
    if not weaponInfo then return "" end
    local weaponName = weaponInfo.name:lower()

    if Config.UseOxInventory then
        return "nui://ox_inventory/web/images/" .. weaponName .. ".png"
    elseif Config.UseQbInventory then
        return "nui://qb-inventory/html/images/" .. weaponName .. ".png"
    elseif Config.UseQuasarInventory then
        return "nui://qs-inventory/html/images/" .. weaponName .. ".png"
    else
        return ""
    end
end

-- Switch styles with database saving
RegisterCommand(Config.StyleCommand, function(_, args)
    if not playerLoaded then
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            title = 'Weapons',
            description = 'Please wait for player data to load'
        })
        return
    end

    local style = tonumber(args[1])
    if style and style >= 1 and style <= 5 then
        currentStyle = style
        
        -- Save to database
        TriggerServerEvent('mnc-weaponui:saveStyle', style)
        
        -- Update UI if weapon is active
        if currentWeapon then
            SendWeaponData()
        end
        
        -- Success notification
        TriggerEvent('ox_lib:notify', {
            type = 'success',
            title = 'Weapons',
            description = 'Weapon UI style set to ' .. style .. ' and saved!'
        })
    else
        -- Error notification
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            title = 'Weapons',
            description = 'Invalid style! Use: /' .. Config.StyleCommand .. ' [1-5]'
        })
    end
end)
