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
-- 2.1 CONFIGURACIÓN POR RESOLUCIÓN
-- =============================================================================================
-- Ajusta automáticamente el HUD según la resolución de pantalla del jugador
-- Puedes personalizar cada resolución individualmente o usar 'default' para todas

Config.UseResolutionScaling = true -- Activar/Desactivar ajuste automático por resolución

-- Configuraciones predefinidas por resolución
Config.ResolutionSettings = {
    -- 1920x1080 (Full HD - Más común)
    ['1920x1080'] = {
        playerHud = {
            scale = 1.0,       -- Escala del HUD del jugador
            left = '10px',     -- Posición desde la izquierda
            bottom = '5px',    -- Posición desde abajo
            iconSize = '36px', -- Tamaño de los iconos
            gap = '14px'       -- Espacio entre elementos
        },
        vehicleHud = {
            scale = 0.8,    -- Escala del HUD del vehículo
            right = '25px', -- Posición desde la derecha
            bottom = '25px' -- Posición desde abajo
        },
        compass = {
            scale = 0.5, -- Escala del compás
            top = '25px' -- Posición desde arriba
        },
        minimap = {
            width = '300px',  -- Ancho del marco del minimapa
            height = '220px', -- Alto del marco del minimapa
            left = '10px',    -- Posición desde la izquierda
            bottom = '67px'   -- Posición desde abajo
        }
    },

    -- 2560x1440 (2K/QHD)
    ['2560x1440'] = {
        playerHud = {
            scale = 1.15,
            left = '15px',
            bottom = '8px',
            iconSize = '40px',
            gap = '16px'
        },
        vehicleHud = {
            scale = 0.9,
            right = '30px',
            bottom = '30px'
        },
        compass = {
            scale = 0.6,
            top = '30px'
        },
        minimap = {
            width = '340px',
            height = '250px',
            left = '15px',
            bottom = '80px'
        }
    },

    -- 3840x2160 (4K/UHD)
    ['3840x2160'] = {
        playerHud = {
            scale = 1.5,
            left = '20px',
            bottom = '10px',
            iconSize = '48px',
            gap = '20px'
        },
        vehicleHud = {
            scale = 1.2,
            right = '40px',
            bottom = '40px'
        },
        compass = {
            scale = 0.8,
            top = '40px'
        },
        minimap = {
            width = '450px',
            height = '330px',
            left = '20px',
            bottom = '100px'
        }
    },

    -- 3440x1440 (Ultrawide 21:9)
    ['3440x1440'] = {
        playerHud = {
            scale = 1.1,
            left = '15px',
            bottom = '8px',
            iconSize = '38px',
            gap = '15px'
        },
        vehicleHud = {
            scale = 0.85,
            right = '30px',
            bottom = '30px'
        },
        compass = {
            scale = 0.55,
            top = '30px'
        },
        minimap = {
            width = '330px',
            height = '240px',
            left = '15px',
            bottom = '75px'
        }
    },

    -- 1366x768 (Laptops comunes)
    ['1366x768'] = {
        playerHud = {
            scale = 0.85,
            left = '8px',
            bottom = '4px',
            iconSize = '32px',
            gap = '12px'
        },
        vehicleHud = {
            scale = 0.7,
            right = '20px',
            bottom = '20px'
        },
        compass = {
            scale = 0.45,
            top = '20px'
        },
        minimap = {
            width = '270px',
            height = '200px',
            left = '8px',
            bottom = '60px'
        }
    },

    -- 2560x1080 (Ultrawide 21:9 - Resolución más baja)
    ['2560x1080'] = {
        playerHud = {
            scale = 1.0,
            left = '20px',
            bottom = '5px',
            iconSize = '36px',
            gap = '14px'
        },
        vehicleHud = {
            scale = 0.8,
            right = '35px',
            bottom = '25px'
        },
        compass = {
            scale = 0.5,
            top = '25px'
        },
        minimap = {
            width = '310px',
            height = '225px',
            left = '20px',
            bottom = '67px'
        }
    },

    -- 1920x1200 (16:10 - WUXGA)
    ['1920x1200'] = {
        playerHud = {
            scale = 1.0,
            left = '10px',
            bottom = '8px',
            iconSize = '36px',
            gap = '14px'
        },
        vehicleHud = {
            scale = 0.8,
            right = '25px',
            bottom = '28px'
        },
        compass = {
            scale = 0.5,
            top = '28px'
        },
        minimap = {
            width = '300px',
            height = '220px',
            left = '10px',
            bottom = '72px'
        }
    },

    -- 2560x1600 (16:10 - WQXGA)
    ['2560x1600'] = {
        playerHud = {
            scale = 1.15,
            left = '15px',
            bottom = '10px',
            iconSize = '40px',
            gap = '16px'
        },
        vehicleHud = {
            scale = 0.9,
            right = '30px',
            bottom = '35px'
        },
        compass = {
            scale = 0.6,
            top = '35px'
        },
        minimap = {
            width = '340px',
            height = '250px',
            left = '15px',
            bottom = '85px'
        }
    },

    -- 5120x1440 (32:9 - Super Ultrawide)
    ['5120x1440'] = {
        playerHud = {
            scale = 1.15,
            left = '60px', -- Muy alejado del borde en pantallas super anchas
            bottom = '8px',
            iconSize = '40px',
            gap = '16px'
        },
        vehicleHud = {
            scale = 0.9,
            right = '60px', -- Muy alejado del borde derecho
            bottom = '30px'
        },
        compass = {
            scale = 0.6,
            top = '30px'
        },
        minimap = {
            width = '340px',
            height = '250px',
            left = '60px', -- Muy alejado del borde
            bottom = '80px'
        }
    },

    -- 1280x1024 (5:4 - Monitores antiguos)
    ['1280x1024'] = {
        playerHud = {
            scale = 0.75,
            left = '8px',
            bottom = '5px',
            iconSize = '30px',
            gap = '10px'
        },
        vehicleHud = {
            scale = 0.65,
            right = '18px',
            bottom = '20px'
        },
        compass = {
            scale = 0.4,
            top = '20px'
        },
        minimap = {
            width = '260px',
            height = '195px',
            left = '8px',
            bottom = '58px'
        }
    },

    -- Configuración por defecto (se usa si no coincide ninguna resolución)
    ['default'] = {
        playerHud = {
            scale = 1.0,
            left = '10px',
            bottom = '5px',
            iconSize = '36px',
            gap = '14px'
        },
        vehicleHud = {
            scale = 0.8,
            right = '25px',
            bottom = '25px'
        },
        compass = {
            scale = 0.5,
            top = '25px'
        },
        minimap = {
            width = '300px',
            height = '220px',
            left = '10px',
            bottom = '67px'
        }
    }
}

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
