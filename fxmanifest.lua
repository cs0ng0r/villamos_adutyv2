fx_version 'adamant'

game 'gta5'

description 'admin duty by 6osvillamos - ESX & QB-Core Compatible'

version '1.3.0'

ui_page 'html/index.html'

lua54 "yes"

shared_scripts {
	'@ox_lib/init.lua',
	'bridge/bridge.lua',
	'config/shared.lua',

}

server_scripts {
	'config/server.lua',
	'server.lua'
}

client_scripts {
	'client.lua'
}

files {
	"icons/*.png",
	"html/**",
	"locales/*.json"
}

dependencies {
	'ox_lib'
}
