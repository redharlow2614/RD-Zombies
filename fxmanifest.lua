fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
shared_script {"shared/useful/functions.lua"}
server_scripts {
	-- "server/main.lua",
	-- "server/**/*.lua"
}

client_scripts {
	"client/spawners/zombiespawner.lua",
	"client/useful/util.lua"
}
