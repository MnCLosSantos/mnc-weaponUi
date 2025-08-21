-- Client-side logic for reloading and unloading weapons
local QBCore = exports['qb-core']:GetCoreObject()

-- Helper function to play animation
local function PlayAnimation(animDict, animName, duration)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -8.0, duration, 49, 0, false, false, false)
    Citizen.Wait(duration)
    ClearPedTasks(PlayerPedId())
    RemoveAnimDict(animDict)
end

-- Reload weapon with one clip
RegisterKeyMapping('reload_weapon', 'Reload current weapon', 'keyboard', 'R')
RegisterCommand('reload_weapon', function()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if weapon == `WEAPON_UNARMED` then return end

    local weaponHash = weapon
    local weaponInfo = QBCore.Shared.Weapons[weaponHash]
    if not weaponInfo then return end

    local ammoType = SharedAmmoMapping[weaponInfo.ammotype] or weaponInfo.ammotype:lower()
    local clipSize = weaponInfo.clipsize or 30
    local currentAmmo = GetAmmoInPedWeapon(ped, weaponHash)

    -- Check if player has the ammo item and how much they have
    QBCore.Functions.TriggerCallback('mnc-weaponUi:server:checkAmmo', function(hasAmmo, ammoCount)
        if hasAmmo then
            if currentAmmo >= clipSize then
                TriggerEvent('ox_lib:notify', {
                    type = 'error',
                    title = 'Weapons',
                    description = 'Weapon is already fully loaded!'
                })
                return
            end

            -- Calculate how much ammo is needed to fill the clip
            local ammoNeeded = clipSize - currentAmmo
            -- Use the available ammo if player doesn't have enough
            local ammoToAdd = math.min(ammoCount, ammoNeeded)
            local newAmmo = currentAmmo + ammoToAdd

            -- Play reload animation
            TaskReloadWeapon(ped)
            Citizen.Wait(1000) -- Wait for animation to complete (adjust duration as needed)

            -- Add ammo to weapon
            SetPedAmmo(ped, weaponHash, newAmmo)
            TriggerServerEvent('mnc-weaponUi:server:removeAmmoItem', ammoType, ammoToAdd)
            TriggerEvent('ox_lib:notify', {
                type = 'success',
                title = 'Weapons',
                description = 'Weapon reloaded with ' .. ammoToAdd .. ' rounds!'
            })

            -- Update UI
            SendWeaponData()
        else
            TriggerEvent('ox_lib:notify', {
                type = 'error',
                title = 'Weapons',
                description = 'You don\'t have any ' .. ammoType .. '!'
            })
        end
    end, ammoType)
end, false)

-- Unload weapon and return ammo to inventory
RegisterKeyMapping('unload_weapon', 'Unload current weapon', 'keyboard', 'P')
RegisterCommand('unload_weapon', function()
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if weapon == `WEAPON_UNARMED` then return end

    local weaponHash = weapon
    local weaponInfo = QBCore.Shared.Weapons[weaponHash]
    if not weaponInfo then return end

    local ammoType = SharedAmmoMapping[weaponInfo.ammotype] or weaponInfo.ammotype:lower()
    local currentAmmo = GetAmmoInPedWeapon(ped, weaponHash)

    if currentAmmo <= 0 then
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            title = 'Weapons',
            description = 'No ammo to unload!'
        })
        return
    end

    -- Play reload animation
    TaskReloadWeapon(ped)
    Citizen.Wait(1000) -- Wait for animation to complete (adjust duration as needed)

    -- Remove ammo from weapon and give to player
    SetPedAmmo(ped, weaponHash, 0)
    TriggerServerEvent('mnc-weaponUi:server:addAmmoItem', ammoType, currentAmmo)
    TriggerEvent('ox_lib:notify', {
        type = 'success',
        title = 'Weapons',
        description = 'Unloaded ' .. currentAmmo .. ' rounds of ' .. ammoType
    })

    -- Update UI
    SendWeaponData()
end, false)