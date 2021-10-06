fx_version 'cerulean'

game 'gta5'

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
    'config.lua',
    'server.lua'
} 

ui_page '/html/index.html'

files {
    'html/index.html',
    'html/index.css',
    'html/vue.min.js',
    'html/app.js',
    'html/imgs/logopolice.png',
    'html/imgs/pda.png',
    'html/imgs/leftarrow.png',
    'html/imgs/mugshot.jpg',
    'html/fonts/BarlowCondensed-Medium.ttf'
}