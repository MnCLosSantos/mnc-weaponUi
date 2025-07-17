-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local CurrentWeaponData, CanShoot, MultiplierAmount, currentWeapon = {}, true, 0, nil

-- Handlers

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    QBCore.Functions.TriggerCallback('qb-weapons:server:GetConfig', function(RepairPoints)
        for k, data in pairs(RepairPoints) do
            Config.WeaponRepairPoints[k].IsRepairing = data.IsRepairing
            Config.WeaponRepairPoints[k].RepairingData = data.RepairingData
        end
    end)
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    for k in pairs(Config.WeaponRepairPoints) do
        Config.WeaponRepairPoints[k].IsRepairing = false
        Config.WeaponRepairPoints[k].RepairingData = {}
    end
end)

-- Functions

local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function GetEffectiveClipSize(weapon, weaponData)
    local baseClipSize = QBCore.Shared.Weapons[weapon].clipSize or 30
    local attachments = weaponData.info and weaponData.info.attachments or {}
    local clipSize = baseClipSize
    print("Client: GetEffectiveClipSize for", QBCore.Shared.Weapons[weapon].name, "Base Clip Size:", baseClipSize, "Attachments:", json.encode(attachments))
    
    -- Check if WeaponAttachments is defined
    if not WeaponAttachments then
        print("Client: Warning - WeaponAttachments not defined, returning base clip size")
        return clipSize
    end
    
    for _, attachment in pairs(attachments) do
        if WeaponAttachments.clip_attachment and WeaponAttachments.clip_attachment[QBCore.Shared.Weapons[weapon].name] == attachment.component then
            clipSize = math.floor(baseClipSize * 1.5) -- Extended magazine: 1.5x
            print("Client: Applied clip_attachment, New Clip Size:", clipSize)
        elseif WeaponAttachments.drum_attachment and WeaponAttachments.drum_attachment[QBCore.Shared.Weapons[weapon].name] == attachment.component then
            clipSize = math.floor(baseClipSize * 2.0) -- Drum magazine: 2x
            print("Client: Applied drum_attachment, New Clip Size:", clipSize)
        end
    end
    print("Client: Final Clip Size for", QBCore.Shared.Weapons[weapon].name, ":", clipSize)
    return clipSize
end

-- Events

RegisterNetEvent('qb-weapons:client:SyncRepairShops', function(NewData, key)
    Config.WeaponRepairPoints[key].IsRepairing = NewData.IsRepairing
    Config.WeaponRepairPoints[key].RepairingData = NewData.RepairingData
end)

RegisterNetEvent('qb-weapons:client:EquipTint', function(weapon, tint)
    local player = PlayerPedId()
    SetPedWeaponTintIndex(player, weapon, tint)
end)

RegisterNetEvent('qb-weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
        print("Client: Updated CurrentWeaponData:", json.encode(CurrentWeaponData))
    else
        CurrentWeaponData = {}
        print("Client: Cleared CurrentWeaponData")
    end
    CanShoot = bool
end)

RegisterNetEvent('qb-weapons:client:SetWeaponQuality', function(amount)
    if CurrentWeaponData and next(CurrentWeaponData) then
        TriggerServerEvent('qb-weapons:server:SetWeaponQuality', CurrentWeaponData, amount)
    end
end)

RegisterNetEvent('qb-weapons:client:AddAmmo', function(ammoType, amount, itemData)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    if not CurrentWeaponData then
        QBCore.Functions.Notify(Lang:t('error.no_weapon'), 'error')
        return
    end

    if QBCore.Shared.Weapons[weapon]['name'] == 'weapon_unarmed' then
        QBCore.Functions.Notify(Lang:t('error.no_weapon_in_hand'), 'error')
        return
    end

    if QBCore.Shared.Weapons[weapon]['ammotype'] ~= ammoType:upper() then
        QBCore.Functions.Notify(Lang:t('error.wrong_ammo'), 'error')
        return
    end

    local total = GetAmmoInPedWeapon(ped, weapon)
    local clipSize = GetEffectiveClipSize(weapon, CurrentWeaponData)

    if total >= clipSize then
        QBCore.Functions.Notify(Lang:t('error.max_ammo'), 'error')
        return
    end

    QBCore.Functions.Progressbar('taking_bullets', Lang:t('info.loading_bullets'), Config.ReloadTime, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        weapon = GetSelectedPedWeapon(ped) -- Get weapon at time of completion

        if QBCore.Shared.Weapons[weapon]?.ammotype ~= ammoType then
            return QBCore.Functions.Notify(Lang:t('error.wrong_ammo'), 'error')
        end

        local newAmmo = math.min(total + amount, clipSize)
        AddAmmoToPed(ped, weapon, newAmmo - total)
        TaskReloadWeapon(ped, false)
        TriggerServerEvent('qb-weapons:server:UpdateWeaponAmmo', CurrentWeaponData, newAmmo)
        TriggerServerEvent('qb-weapons:server:removeWeaponAmmoItems', itemData, 1)
        TriggerEvent('qb-inventory:client:ItemBox', QBCore.Shared.Items[itemData.name], 'remove')
        TriggerEvent('QBCore:Notify', Lang:t('success.reloaded'), 'success')
        print("Client: Reloaded weapon via AddAmmo, New Ammo:", newAmmo, "Clip Size:", clipSize)
    end, function()
        QBCore.Functions.Notify(Lang:t('error.canceled'), 'error')
    end)
end)

RegisterNetEvent('qb-weapons:client:UseWeapon', function(weaponData, shootbool)
    local ped = PlayerPedId()
    local weaponName = tostring(weaponData.name)
    local weaponHash = joaat(weaponData.name)
    if currentWeapon == weaponName then
        TriggerEvent('qb-weapons:client:DrawWeapon', nil)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        RemoveAllPedWeapons(ped, true)
        TriggerEvent('qb-weapons:client:SetCurrentWeapon', nil, shootbool)
        currentWeapon = nil
    elseif weaponName == 'weapon_stickybomb' or weaponName == 'weapon_pipebomb' or weaponName == 'weapon_smokegrenade' or weaponName == 'weapon_flare' or weaponName == 'weapon_proxmine' or weaponName == 'weapon_ball' or weaponName == 'weapon_molotov' or weaponName == 'weapon_grenade' or weaponName == 'weapon_bzgas' then
        TriggerEvent('qb-weapons:client:DrawWeapon', weaponName)
        GiveWeaponToPed(ped, weaponHash, 1, false, false)
        SetPedAmmo(ped, weaponHash, 1)
        SetCurrentPedWeapon(ped, weaponHash, true)
        TriggerEvent('qb-weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    elseif weaponName == 'weapon_snowball' then
        TriggerEvent('qb-weapons:client:DrawWeapon', weaponName)
        GiveWeaponToPed(ped, weaponHash, 10, false, false)
        SetPedAmmo(ped, weaponHash, 10)
        SetCurrentPedWeapon(ped, weaponHash, true)
        TriggerServerEvent('qb-inventory:server:snowball', 'remove')
        TriggerEvent('qb-weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    else
        TriggerEvent('qb-weapons:client:DrawWeapon', weaponName)
        TriggerEvent('qb-weapons:client:SetCurrentWeapon', weaponData, shootbool)
        local ammo = tonumber(weaponData.info.ammo) or 0

        if weaponName == 'weapon_petrolcan' or weaponName == 'weapon_fireextinguisher' then
            ammo = 4000
        end

        local clipSize = GetEffectiveClipSize(weaponHash, weaponData)
        if ammo > clipSize then
            ammo = clipSize
            TriggerServerEvent('qb-weapons:server:UpdateWeaponAmmo', weaponData, ammo)
            print("Client: Adjusted ammo to clip size:", clipSize, "for", weaponName)
        end

        GiveWeaponToPed(ped, weaponHash, ammo, false, false)
        SetPedAmmo(ped, weaponHash, ammo)
        SetCurrentPedWeapon(ped, weaponHash, true)

        if weaponData.info.attachments then
            for _, attachment in pairs(weaponData.info.attachments) do
                GiveWeaponComponentToPed(ped, weaponHash, joaat(attachment.component))
            end
        end

        if weaponData.info.tint then
            SetPedWeaponTintIndex(ped, weaponHash, weaponData.info.tint)
        end

        currentWeapon = weaponName
    end
end)

RegisterNetEvent('qb-weapons:client:CheckWeapon', function(weaponName)
    if currentWeapon ~= weaponName:lower() then return end
    local ped = PlayerPedId()
    TriggerEvent('qb-weapons:ResetHolster')
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    RemoveAllPedWeapons(ped, true)
    currentWeapon = nil
end)

-- Threads

CreateThread(function()
    SetWeaponsNoAutoswap(true)
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedArmed(ped, 7) == 1 and (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
            local weapon = GetSelectedPedWeapon(ped)
            local ammo = GetAmmoInPedWeapon(ped, weapon)
            TriggerServerEvent('qb-weapons:server:UpdateWeaponAmmo', CurrentWeaponData, tonumber(ammo))
            if MultiplierAmount > 0 then
                TriggerServerEvent('qb-weapons:server:UpdateWeaponQuality', CurrentWeaponData, MultiplierAmount)
                MultiplierAmount = 0
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if CurrentWeaponData and next(CurrentWeaponData) then
                if IsPedShooting(ped) or IsControlJustPressed(0, 24) then
                    local weapon = GetSelectedPedWeapon(ped)
                    if CanShoot then
                        if weapon and weapon ~= 0 and QBCore.Shared.Weapons[weapon] then
                            QBCore.Functions.TriggerCallback('prison:server:checkThrowable', function(result)
                                if result or GetAmmoInPedWeapon(ped, weapon) <= 0 then return end
                                MultiplierAmount += 1
                            end, weapon)
                            Wait(200)
                        end
                    else
                        if weapon ~= `WEAPON_UNARMED` then
                            TriggerEvent('qb-weapons:client:CheckWeapon', QBCore.Shared.Weapons[weapon]['name'])
                            QBCore.Functions.Notify(Lang:t('error.weapon_broken') or 'Weapon is broken', 'error')
                            MultiplierAmount = 0
                        end
                    end
                end
                -- Check for 'R' key press to reload
                if IsControlJustPressed(0, 45) then -- 45 is the keycode for 'R'
                    local weapon = GetSelectedPedWeapon(ped)
                    if weapon and weapon ~= `WEAPON_UNARMED` and QBCore.Shared.Weapons[weapon] then
                        local ammoType = QBCore.Shared.Weapons[weapon].ammotype
                        if not ammoType then
                            QBCore.Functions.Notify('Weapon has no valid ammo type', 'error')
                            print("Client: No valid ammo type for weapon:", QBCore.Shared.Weapons[weapon].name)
                            return
                        end
                        local currentAmmo = GetAmmoInPedWeapon(ped, weapon)
                        local clipSize = GetEffectiveClipSize(weapon, CurrentWeaponData)
                        print("Client: Weapon:", QBCore.Shared.Weapons[weapon].name, "Ammo Type:", ammoType, "Current Ammo:", currentAmmo, "Clip Size:", clipSize)
                        if currentAmmo < clipSize then
                            -- Find the corresponding ammo item name
                            local itemName = nil
                            for ammoItem, properties in pairs(Config.AmmoTypes) do
                                if properties.ammoType == ammoType then
                                    itemName = ammoItem
                                    break
                                end
                            end
                            if not itemName then
                                print("Client: No ammo item found for ammo type:", ammoType)
                                QBCore.Functions.Notify('No ammo item configured for this weapon', 'error')
                                return
                            end
                            -- Calculate ammo needed and items required
                            local configAmount = Config.AmmoTypes[itemName].amount or 1
                            local ammoNeeded = clipSize - currentAmmo
                            local itemsNeeded = math.ceil(ammoNeeded / configAmount)
                            print("Client: Item Name:", itemName, "Config Amount:", configAmount, "Ammo Needed:", ammoNeeded, "Items Needed:", itemsNeeded)
                            QBCore.Functions.TriggerCallback('qb-weapons:server:HasEnoughAmmoItems', function(hasEnough, itemData, itemCount)
                                print("Client: Has Enough Items:", hasEnough, "Item Data:", itemData and (itemData.name .. " Slot: " .. itemData.slot .. " Count: " .. itemCount) or "nil", "Item Count:", itemCount)
                                if itemCount > 0 then
                                    -- Calculate ammo to add and items to use
                                    local itemsToUse = math.min(itemCount, itemsNeeded)
                                    local ammoToAdd = math.min(itemsToUse * configAmount, ammoNeeded)
                                    print("Client: Items Available:", itemCount, "Items To Use:", itemsToUse, "Ammo To Add:", ammoToAdd, "Clip Size Cap:", clipSize)
                                    QBCore.Functions.Progressbar('reloading_weapon', 'Reloading...', Config.ReloadTime, false, true, {
                                        disableMovement = false,
                                        disableCarMovement = false,
                                        disableMouse = false,
                                        disableCombat = true
                                    }, {}, {}, {}, function()
                                        weapon = GetSelectedPedWeapon(ped)
                                        if QBCore.Shared.Weapons[weapon]?.ammotype == ammoType then
                                            local newAmmo = currentAmmo + ammoToAdd
                                            SetPedAmmo(ped, weapon, newAmmo)
                                            TaskReloadWeapon(ped, false)
                                            TriggerServerEvent('qb-weapons:server:UpdateWeaponAmmo', CurrentWeaponData, newAmmo)
                                            TriggerServerEvent('qb-weapons:server:removeWeaponAmmoItems', itemData, itemsToUse)
                                            TriggerEvent('qb-inventory:client:ItemBox', QBCore.Shared.Items[itemData.name], 'remove', itemsToUse)
                                            QBCore.Functions.Notify('Weapon reloaded with ' .. ammoToAdd .. ' rounds', 'success')
                                            print("Client: Reloaded weapon, added:", ammoToAdd, "New Ammo:", newAmmo, "Items Used:", itemsToUse, "Clip Size:", clipSize)
                                        else
                                            QBCore.Functions.Notify('Wrong weapon selected', 'error')
                                            print("Client: Wrong weapon selected during reload")
                                        end
                                    end, function()
                                        QBCore.Functions.Notify('Reload canceled', 'error')
                                        print("Client: Reload canceled")
                                    end)
                                else
                                    QBCore.Functions.Notify('No ammo for this weapon', 'error')
                                    print("Client: No ammo items found for:", itemName)
                                end
                            end, itemName, itemsNeeded)
                        elseif currentAmmo >= clipSize then
                            QBCore.Functions.Notify('Weapon already fully loaded', 'error')
                            print("Client: Weapon already fully loaded, Current Ammo:", currentAmmo, "Clip Size:", clipSize)
                        end
                    end
                end
                -- Check for 'P' key press to unload
                if IsControlJustPressed(0, 199) then -- 199 is the keycode for 'P'
                    local weapon = GetSelectedPedWeapon(ped)
                    if weapon and weapon ~= `WEAPON_UNARMED` and QBCore.Shared.Weapons[weapon] then
                        TriggerServerEvent('qb-weapons:server:UnloadWeapon', CurrentWeaponData)
                        print("Client: Unload weapon triggered for:", CurrentWeaponData.name)
                    end
                end
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local inRange = false
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            for k, data in pairs(Config.WeaponRepairPoints) do
                local distance = #(pos - data.coords)
                if distance < 10 then
                    inRange = true
                    if distance < 1 then
                        if data.IsRepairing then
                            if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.repairshop_not_usable') or 'Repair shop not usable')
                            else
                                if not data.RepairingData.Ready then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.weapon_will_repair') or 'Weapon will be repaired')
                                else
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.take_weapon_back') or 'Take weapon back')
                                end
                            end
                        else
                            if CurrentWeaponData and next(CurrentWeaponData) then
                                if not data.RepairingData.Ready then
                                    local WeaponData = QBCore.Shared.Weapons[GetHashKey(CurrentWeaponData.name)]
                                    local WeaponClass = (QBCore.Shared.SplitStr(WeaponData.ammotype, '_')[2]):lower()
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.repair_weapon_price', { value = Config.WeaponRepairCosts[WeaponClass] }) or ('Repair weapon: $' .. Config.WeaponRepairCosts[WeaponClass]))
                                    if IsControlJustPressed(0, 38) then
                                        QBCore.Functions.TriggerCallback('qb-weapons:server:RepairWeapon', function(HasMoney)
                                            if HasMoney then
                                                CurrentWeaponData = {}
                                            end
                                        end, k, CurrentWeaponData)
                                    end
                                else
                                    if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                                        DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.repairshop_not_usable') or 'Repair shop not usable')
                                    else
                                        DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.take_weapon_back') or 'Take weapon back')
                                        if IsControlJustPressed(0, 38) then
                                            TriggerServerEvent('qb-weapons:server:TakeBackWeapon', k, data)
                                        end
                                    end
                                end
                            else
                                if data.RepairingData.CitizenId == nil then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('error.no_weapon_in_hand') or 'No weapon in hand')
                                elseif data.RepairingData.CitizenId == PlayerData.citizenid then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.take_weapon_back') or 'Take weapon back')
                                    if IsControlJustPressed(0, 38) then
                                        TriggerServerEvent('qb-weapons:server:TakeBackWeapon', k, data)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not inRange then
                Wait(1000)
            end
        end
        Wait(0)
    end
end)