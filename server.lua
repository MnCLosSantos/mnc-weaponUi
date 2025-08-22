local QBCore = exports['qb-core']:GetCoreObject()

-- Get player's weapon UI style from database
QBCore.Functions.CreateCallback('mnc-weaponui:getStyle', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then 
        cb(Config.DefaultStyle)
        return 
    end

    -- Handle different QBCore versions
    local citizenid = nil
    if Player.PlayerData then
        citizenid = Player.PlayerData.citizenid
    elseif Player.citizenid then
        citizenid = Player.citizenid
    else
        print("[mnc-weaponui] Error: Could not get citizenid from player object")
        cb(Config.DefaultStyle)
        return
    end
    
    MySQL.Async.fetchScalar('SELECT style FROM mnc_weapon_ui_styles WHERE citizenid = ?', {citizenid}, function(result)
        if result then
            cb(result)
        else
            -- Insert default style for new player
            MySQL.Async.insert('INSERT INTO mnc_weapon_ui_styles (citizenid, style) VALUES (?, ?)', {
                citizenid, Config.DefaultStyle
            }, function(insertId)
                cb(Config.DefaultStyle)
            end)
        end
    end)
end)

-- Save player's weapon UI style to database
RegisterNetEvent('mnc-weaponui:saveStyle', function(style)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Handle different QBCore versions
    local citizenid = nil
    if Player.PlayerData then
        citizenid = Player.PlayerData.citizenid
    elseif Player.citizenid then
        citizenid = Player.citizenid
    else
        print("[mnc-weaponui] Error: Could not get citizenid from player object")
        return
    end
    
    MySQL.Async.execute('UPDATE mnc_weapon_ui_styles SET style = ? WHERE citizenid = ?', {
        style, citizenid
    }, function(affectedRows)
        if affectedRows == 0 then
            -- Insert if update didn't affect any rows (player not in database)
            MySQL.Async.insert('INSERT INTO mnc_weapon_ui_styles (citizenid, style) VALUES (?, ?)', {
                citizenid, style
            })
        end
    end)
end)