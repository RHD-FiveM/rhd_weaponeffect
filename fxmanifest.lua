fx_version 'cerulean'
game 'gta5'

name "rhd_weaponeffect"
description "Fivem Weapon Effect (damage, recoil, shake)"
author "RHD Team"
version "1.0.0"

lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
	'client/*.lua'
}

files {
    'config/client.lua'
}