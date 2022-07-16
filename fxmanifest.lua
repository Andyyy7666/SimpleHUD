-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

version "2.1.0"
description "SimpleHUD is a simple but good hud perfect for new servers."
author "Andyyy#7666"
lua54 "yes"

fx_version "cerulean"
game "gta5"

shared_script "config.lua"
client_script "client.lua"
server_scripts {
    "config_server.lua",
    "server.lua"
}

exports {
    "getAOP"
}
