local QBCore = exports['qb-core']:GetCoreObject()
local currentWeapon, currentAmmo = nil, 0
local currentStyle = Config.DefaultStyle

-- Main loop to track weapon
CreateThread(function()
    while true do
        Wait(250)
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
end)

-- Send data to UI
function SendWeaponData()
    if not currentWeapon then return end
    local hash = currentWeapon
    local weaponInfo = QBCore.Shared.Weapons[hash]
    local weaponName = weaponInfo and weaponInfo.label or "Unknown"
    local image = GetWeaponImage(hash)

    SendNUIMessage({
        action = "show",
        weapon = weaponName,
        ammo = currentAmmo,
        image = image,
        style = currentStyle,
        ui = Config.UI
    })
end

-- Get weapon image from qb or ox inventory
function GetWeaponImage(hash)
    local weaponInfo = QBCore.Shared.Weapons[hash]
    if not weaponInfo then return "" end
    local weaponName = weaponInfo.name:lower()

    if Config.UseOxInventory then
        return "nui://ox_inventory/web/images/" .. weaponName .. ".png"
    elseif Config.UseQbInventory then
        return "nui://qb-inventory/html/images/" .. weaponName .. ".png"
    else
        return ""
    end
end

-- Switch styles
RegisterCommand(Config.StyleCommand, function(_, args)
    local style = tonumber(args[1])
    if style and style >= 1 and style <= 5 then
        currentStyle = style
        if currentWeapon then
            SendWeaponData()
        end
        -- Notification via event
        TriggerEvent('ox_lib:notify', {
            type = 'success',
            title = 'Weapons',
            description = 'Weapon UI style set to ' .. style
        })
    else
        -- Notification via event
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            title = 'Weapons',
            description = 'No style selected try again like this - /weaponui 2'
        })
    end
end)
