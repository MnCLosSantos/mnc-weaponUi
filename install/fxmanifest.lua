fx_version 'cerulean'
game 'gta5'

name 'mnc-weaponUi'
author 'carrot'
description 'Weapon UI for QBCore and OX Inventory'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/*.css',
    'html/app.js'
}
