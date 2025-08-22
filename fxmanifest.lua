fx_version 'cerulean'
game 'gta5'

name 'mnc-weaponUi'
author 'Stan Leigh'
description 'Weapon UI for QBCore and OX Inventory with persistent styles'
version '1.1.0'

shared_scripts {
    'config.lua',
    --'shared_ammo.lua'
}

client_scripts {
    'client.lua',
    --'client_weapon_actions.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    --'server_weapon_actions.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/*.css',
    'html/app.js'
}

dependencies {
    'oxmysql',
    'qb-core'

}
