return {
    [`WEAPON_PISTOL`] = {
        damage = 0.1,
        recoil = 4.5,
        camShake = 0.1,
        onShooting = function ()
            if math.random() < 0.1 then
                LocalPlayer.state:set('stress', math.random(1, 3), true)
            end
        end
    }
}