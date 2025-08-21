-- Server-side logic for inventory management
local QBCore = exports['qb-core']:GetCoreObject()

-- Check if player has ammo and return the amount
QBCore.Functions.CreateCallback('mnc-weaponUi:server:checkAmmo', function(source, cb, ammoType)
    local Player = QBCore.Functions.GetPlayer(source)
    local hasAmmo = Player.Functions.GetItemByName(ammoType)
    if hasAmmo and hasAmmo.amount > 0 then
        cb(true, hasAmmo.amount)
    else
        cb(false, 0)
    end
end)

-- Remove ammo item from inventory
RegisterServerEvent('mnc-weaponUi:server:removeAmmoItem')
AddEventHandler('mnc-weaponUi:server:removeAmmoItem', function(ammoType, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(ammoType, amount)
end)

-- Add ammo item to inventory
RegisterServerEvent('mnc-weaponUi:server:addAmmoItem')
AddEventHandler('mnc-weaponUi:server:addAmmoItem', function(ammoType, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    Player.Functions.AddItem(ammoType, amount)
end)