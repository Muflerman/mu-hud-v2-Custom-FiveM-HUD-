-- ============================================================
--  functions.lua
--  Funciones auxiliares para el HUD
-- ============================================================

-- ======================
-- 1. REFERENCIA A QBCore
-- ======================
local QBCore = exports['qb-core']:GetCoreObject()

-- ======================
-- 2. FUNCIONES DE NECESIDADES
-- ======================

--- Carga las necesidades del jugador al iniciar sesión o cargar script
--  Obtiene los metadatos del jugador y actualiza el HUD con hambre, sed y stress
function loadPlayerNeeds()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata then
        TriggerEvent('hud:client:UpdateNeeds', PlayerData.metadata.hunger, PlayerData.metadata.thirst)
        -- Cargar stress inicial
        if PlayerData.metadata.stress then
            TriggerEvent('hud:client:UpdateStress', PlayerData.metadata.stress)
        end
    end
end

