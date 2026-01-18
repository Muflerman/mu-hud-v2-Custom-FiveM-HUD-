Config = Config or {}

-- =============================================================================================
-- 1. CONFIGURACIÓN DEL NÚCLEO (CORE)
-- =============================================================================================
Config.Core = 'qbx-core'     -- Framework utilizado (qb-core / qbx-core)
Config.updateDelay = 150     -- Tiempo entre actualizaciones del HUD en ms (150ms = ~0.15s)
Config.speedMultiplier = 2.6 -- Multiplicador de velocidad (2.6 para KM/H, 2.23694 para MPH)
Config.UseMPH = false        -- Cambiar a true para mostrar MPH (requiere ajustes en style.css para el texto unitario)

-- =============================================================================================
-- 2. AJUSTES DEL HUD Y ELEMENTOS VISUALES
-- =============================================================================================
Config.HideVehicleName = true -- Ocultar el nombre nativo del vehículo al entrar
Config.Keybinds = false       -- Activar/Desactivar combinaciones de teclas personalizadas
Config.CinematicMode = false  -- Estado por defecto del modo cinemático

-- =============================================================================================
-- 3. SISTEMA DE ESTRÉS
-- =============================================================================================
Config.DisableStress = false       -- Cambiar a false para activar el sistema de estrés
Config.StressChance = 0.1          -- Probabilidad (0.0 a 1.0) de ganar estrés al realizar acciones (ej. disparar)
Config.MinimumStress = 50          -- Nivel de estrés necesario para empezar a ver efectos visuales
Config.MinimumSpeed = 150          -- Velocidad mínima para empezar a ganar estrés con cinturón
Config.MinimumSpeedUnbuckled = 130 -- Velocidad mínima para empezar a ganar estrés SIN cinturón

-- =============================================================================================
-- 4. WHITELISTS / LISTAS DE EXCEPCIÓN
-- =============================================================================================

-- Armas que NO muestran el icono de "arma armada" en el HUD
Config.WhitelistedWeaponArmed = {
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true,
    [`weapon_dagger`] = true,
    [`weapon_bat`] = true,
    [`weapon_bottle`] = true,
    [`weapon_crowbar`] = true,
    [`weapon_flashlight`] = true,
    [`weapon_golfclub`] = true,
    [`weapon_hammer`] = true,
    [`weapon_hatchet`] = true,
    [`weapon_knuckle`] = true,
    [`weapon_knife`] = true,
    [`weapon_machete`] = true,
    [`weapon_switchblade`] = true,
    [`weapon_nightstick`] = true,
    [`weapon_wrench`] = true,
    [`weapon_battleaxe`] = true,
    [`weapon_poolcue`] = true,
    [`weapon_briefcase`] = true,
    [`weapon_briefcase_02`] = true,
    [`weapon_garbagebag`] = true,
    [`weapon_handcuffs`] = true,
    [`weapon_bread`] = true,
    [`weapon_stone_hatchet`] = true,
    [`weapon_grenade`] = true,
    [`weapon_bzgas`] = true,
    [`weapon_molotov`] = true,
    [`weapon_stickybomb`] = true,
    [`weapon_proxmine`] = true,
    [`weapon_snowball`] = true,
    [`weapon_pipebomb`] = true,
    [`weapon_ball`] = true,
    [`weapon_smokegrenade`] = true,
    [`weapon_flare`] = true,
}

-- Armas que NO generan estrés al disparar
Config.WhitelistedWeaponStress = {
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true,
}

-- Clases de vehículos que generan estrés por velocidad (true = genera estrés)
Config.VehClassStress = {
    ['0'] = true,   -- Compacts
    ['1'] = true,   -- Sedans
    ['2'] = true,   -- SUVs
    ['3'] = true,   -- Coupes
    ['4'] = true,   -- Muscle
    ['5'] = true,   -- Sports Classics
    ['6'] = true,   -- Sports
    ['7'] = true,   -- Super
    ['8'] = true,   -- Motorcycles
    ['9'] = true,   -- Off Road
    ['10'] = true,  -- Industrial
    ['11'] = true,  -- Utility
    ['12'] = true,  -- Vans
    ['13'] = false, -- Cycles
    ['14'] = false, -- Boats
    ['15'] = false, -- Helicopters
    ['16'] = false, -- Planes
    ['18'] = false, -- Emergency
    ['19'] = false, -- Military
    ['20'] = false, -- Commercial
    ['21'] = false, -- Trains
}

-- Modelos específicos de vehículos que NO generan estrés
Config.WhitelistedVehicles = {
    -- [ `elegy` ] = true,
}

-- Trabajos que están exentos de ganar estrés
Config.WhitelistedJobs = {
    -- ['police'] = true,
    -- ['ambulance'] = true,
}

-- =============================================================================================
-- 5. EFECTOS E INTENSIDAD DE ESTRÉS
-- =============================================================================================
Config.Intensity = {
    ['blur'] = {
        [1] = { min = 50, max = 60, intensity = 1500 },
        [2] = { min = 60, max = 70, intensity = 2000 },
        [3] = { min = 70, max = 80, intensity = 2500 },
        [4] = { min = 80, max = 90, intensity = 2700 },
        [5] = { min = 90, max = 100, intensity = 3000 },
    }
}

Config.EffectInterval = {
    [1] = { min = 50, max = 60, timeout = math.random(50000, 60000) },
    [2] = { min = 60, max = 70, timeout = math.random(40000, 50000) },
    [3] = { min = 70, max = 80, timeout = math.random(30000, 40000) },
    [4] = { min = 80, max = 90, timeout = math.random(20000, 30000) },
    [5] = { min = 90, max = 100, timeout = math.random(15000, 20000) },
}
