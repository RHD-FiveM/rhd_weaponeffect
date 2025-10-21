---@diagnostic disable: missing-parameter, param-type-mismatch

local STATE = {
    isShooting = false,
    lastShot = 0,
    shotCooldown = 100
}

local EFFECT = {
    recoil = {
        enabled = true,
        pitchRange = { -1.0, 0.5 },
        headingRange = { -0.5, 0.5 }
    },
    cameraShake = {
        enabled = true,
        type = 'SMALL_EXPLOSION_SHAKE'
    },
    particles = {
        enabled = true,
        asset = 'core',
        effect = 'muz_pistol'
    }
}

local CACHE_CONFIG
local DEBUG = false

local weapons = require 'config.client'

---@param multiplier number
local function applyRecoil(multiplier)
    if not EFFECT.recoil.enabled then return end
    
    local pitch = GetGameplayCamRelativePitch()
    local heading = GetGameplayCamRelativeHeading()
    
    local pitchRange = EFFECT.recoil.pitchRange
    local headingRange = EFFECT.recoil.headingRange
    
    local recoilPitch = math.random(pitchRange[1] * 100, pitchRange[2] * 100) * multiplier * 0.01
    local recoilHeading = math.random(headingRange[1] * 100, headingRange[2] * 100) * multiplier * 0.01
    
    SetGameplayCamRelativePitch(pitch + recoilPitch, 1.0)
    SetGameplayCamRelativeHeading(heading + recoilHeading)
end

---@param intensity number
local function applyCameraShake(intensity)
    if not EFFECT.cameraShake.enabled then return end
    ShakeGameplayCam(EFFECT.cameraShake.type, intensity)
end

local function onWeaponShoot()
    local currentTime = GetGameTimer()
    
    if currentTime - STATE.lastShot < STATE.shotCooldown then return end
    STATE.lastShot = currentTime
    
    if not CACHE_CONFIG then return end
    
    if CACHE_CONFIG.recoil then
        applyRecoil(CACHE_CONFIG.recoil)
    end
    
    if CACHE_CONFIG.camShake then
        applyCameraShake(CACHE_CONFIG.camShake)
    end

    if CACHE_CONFIG.onShooting then
        CACHE_CONFIG.onShooting()
    end
    
    if DEBUG then
        lib.print.info(('Weapon effect applied for %s'):format(cache.weapon))
    end
end

---@param weapon number?
local function updateWeaponCache(weapon)
    if not weapon then
        CACHE_CONFIG = nil
        return
    end

    CACHE_CONFIG = weapons[weapon]

    if CACHE_CONFIG then
        if CACHE_CONFIG.damage then
            SetWeaponDamageModifier(weapon, CACHE_CONFIG.damage)
        end

        if DEBUG then
            lib.print.info(('Weapon cached: %s'):format(weapon))
        end
    end
end

lib.onCache('weapon', updateWeaponCache)

CreateThread(function()
    while true do
        local sleep = CACHE_CONFIG and 0 or 1000
        
        if CACHE_CONFIG then
            if IsPedShooting(cache.ped) then
                onWeaponShoot()
            end
        end
        
        Wait(sleep)
    end
end)

---@param weaponHash number
---@param effectConfig table
local function addWeaponEffect(weaponHash, effectConfig)
    weapons[weaponHash] = effectConfig
    
    if cache.weapon == weaponHash then
        updateWeaponCache(weaponHash)
    end
    
    if DEBUG then
        lib.print.info(('Weapon effect added: %s'):format(weaponHash))
    end
end

---@param weaponHash number
local function removeWeaponEffect(weaponHash)
    weapons[weaponHash] = nil
    
    if cache.weapon == weaponHash then
        updateWeaponCache(nil)
    end
    
    if DEBUG then
        lib.print.info(('Weapon effect removed: %s'):format(weaponHash))
    end
end

exports('addWeaponEffect', addWeaponEffect)
exports('removeWeaponEffect', removeWeaponEffect)

