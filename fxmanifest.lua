fx_version 'cerulean'
game 'gta5'
author 'Mystic Store'
version '1.9.3'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*'
}

client_scripts {
    'client/*'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css',
}
