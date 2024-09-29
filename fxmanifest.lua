fx_version 'cerulean'
game 'gta5'

author 'Save5Bucks'
description 'Manual Transmission Script using QB-Core'
version '1.0.2'

-- Client scripts
client_scripts {
    'config.lua',
    'client.lua'
}

-- Server scripts (if needed in the future)
server_scripts {
    'server.lua'
}

-- NUI Files (HTML, CSS, JS)
ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}

-- Dependencies
dependencies {
    'qb-core'
}
