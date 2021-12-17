fx_version 'adamant' --poor mans adamantium lol...
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
shared_script {"shared/useful/functions.lua"}

client_scripts {
	"config/config.lua",
	"client/**/*.lua"
}

files {
    'html/*',
}

ui_page 'html/index.html'
