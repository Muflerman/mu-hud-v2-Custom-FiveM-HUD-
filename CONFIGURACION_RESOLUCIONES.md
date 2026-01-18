# 📐 Configuración de Resoluciones - MU HUD

## 📋 Descripción

Este sistema permite ajustar automáticamente el HUD según la resolución de pantalla del jugador. Cada resolución puede tener configuraciones personalizadas para garantizar que el HUD se vea perfecto en cualquier monitor.

## 🎮 Resoluciones Soportadas

El HUD incluye configuraciones predefinidas para las siguientes resoluciones:

### Resoluciones 16:9 (Estándar)
- **1920x1080** (Full HD) - La más común
- **2560x1440** (2K/QHD)
- **3840x2160** (4K/UHD)
- **1366x768** (Laptops comunes)

### Resoluciones 21:9 (Ultrawide)
- **3440x1440** (Ultrawide QHD)
- **2560x1080** (Ultrawide Full HD)

### Resoluciones 16:10
- **1920x1200** (WUXGA)
- **2560x1600** (WQXGA)

### Resoluciones Especiales
- **5120x1440** (32:9 Super Ultrawide)
- **1280x1024** (5:4 - Monitores antiguos)
- **default** - Se usa si no coincide ninguna resolución específica

## 📺 Resolución de Aspecto (Aspect Ratio)

### ¿Qué es la Resolución de Aspecto?

La **resolución de aspecto** es la relación entre el ancho y el alto de tu pantalla. Es diferente de la resolución en píxeles. Por ejemplo:

- **16:9** - Estándar moderno (1920x1080, 2560x1440, 3840x2160)
- **21:9** - Ultrawide (3440x1440, 2560x1080)
- **16:10** - Algunos monitores y laptops (1920x1200, 2560x1600)
- **4:3** - Monitores antiguos (1024x768, 1280x1024)
- **32:9** - Super Ultrawide (5120x1440)

### Cómo Afecta al HUD

El sistema de MU-HUD detecta automáticamente tu resolución y aplica la configuración correspondiente. Sin embargo, para pantallas con aspect ratios inusuales, es posible que necesites ajustes personalizados:

#### Pantallas Ultrawide (21:9 o 32:9)
- El HUD del jugador puede quedar muy alejado del centro
- El minimapa puede verse desproporcionado
- **Solución**: Ajusta los valores `left` y `right` para acercar elementos al centro

#### Pantallas 4:3 o 5:4
- Los elementos pueden verse apretados verticalmente
- **Solución**: Reduce el `scale` y ajusta `bottom` para dar más espacio

#### Pantallas 16:10
- Muy similar a 16:9, generalmente no requiere ajustes especiales
- **Solución**: Usa la configuración de 16:9 más cercana a tu resolución

### Ejemplo: Configurar para 32:9 Super Ultrawide

Si tienes una pantalla 5120x1440 (32:9), puedes agregar esta configuración:

```lua
['5120x1440'] = {
    playerHud = {
        scale = 1.15,
        left = '50px',      -- Más alejado del borde en pantallas muy anchas
        bottom = '8px',
        iconSize = '40px',
        gap = '16px'
    },
    vehicleHud = {
        scale = 0.9,
        right = '50px',     -- Más alejado del borde derecho
        bottom = '30px'
    },
    compass = {
        scale = 0.6,
        top = '30px'
    },
    minimap = {
        width = '340px',
        height = '250px',
        left = '50px',      -- Más alejado del borde
        bottom = '80px'
    }
},
```

### Calcular tu Aspect Ratio

Para saber tu aspect ratio:
1. Divide el ancho entre el alto de tu resolución
2. Ejemplos:
   - 1920 ÷ 1080 = 1.78 → **16:9**
   - 3440 ÷ 1440 = 2.39 → **21:9**
   - 5120 ÷ 1440 = 3.56 → **32:9**
   - 1920 ÷ 1200 = 1.6 → **16:10**

## ⚙️ Configuración

### Activar/Desactivar el Sistema

En `config.lua`, línea 24:

```lua
Config.UseResolutionScaling = true -- true = activado, false = desactivado
```

### Personalizar una Resolución

Cada resolución tiene 4 secciones configurables:

#### 1. **Player HUD** (HUD del Jugador)
```lua
playerHud = {
    scale = 1.0,        -- Escala general (1.0 = 100%, 1.5 = 150%, 0.8 = 80%)
    left = '10px',      -- Distancia desde el borde izquierdo
    bottom = '5px',     -- Distancia desde el borde inferior
    iconSize = '36px',  -- Tamaño de los iconos de salud, hambre, etc.
    gap = '14px'        -- Espacio entre los iconos
}
```

#### 2. **Vehicle HUD** (HUD del Vehículo)
```lua
vehicleHud = {
    scale = 0.8,        -- Escala general del HUD del vehículo
    right = '25px',     -- Distancia desde el borde derecho
    bottom = '25px'     -- Distancia desde el borde inferior
}
```

#### 3. **Compass** (Brújula y Calles)
```lua
compass = {
    scale = 0.5,        -- Escala de la brújula
    top = '25px'        -- Distancia desde el borde superior
}
```

#### 4. **Minimap** (Marco del Minimapa)
```lua
minimap = {
    width = '300px',    -- Ancho del marco
    height = '220px',   -- Alto del marco
    left = '10px',      -- Distancia desde el borde izquierdo
    bottom = '67px'     -- Distancia desde el borde inferior
}
```

## 📝 Ejemplo: Agregar una Nueva Resolución

Si quieres agregar soporte para una resolución personalizada (por ejemplo, 2560x1080):

```lua
-- En config.lua, dentro de Config.ResolutionSettings:

['2560x1080'] = {
    playerHud = {
        scale = 1.0,
        left = '10px',
        bottom = '5px',
        iconSize = '36px',
        gap = '14px'
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
        width = '320px',
        height = '235px',
        left = '10px',
        bottom = '70px'
    }
},
```

## 🔧 Consejos de Ajuste

### Para Pantallas Más Grandes (4K, etc.)
- **Aumenta** el `scale` para que los elementos sean más visibles
- **Aumenta** `iconSize` para iconos más grandes
- **Aumenta** las dimensiones del `minimap`

### Para Pantallas Más Pequeñas (Laptops, etc.)
- **Reduce** el `scale` para ahorrar espacio
- **Reduce** `iconSize` para iconos más compactos
- **Reduce** las dimensiones del `minimap`

### Para Pantallas Ultrawide
- Ajusta principalmente las posiciones `left` y `right`
- Mantén escalas similares a 1080p
- El compás puede necesitar un `scale` ligeramente mayor

## 🐛 Solución de Problemas

### El HUD se ve muy pequeño/grande
1. Verifica que `Config.UseResolutionScaling = true`
2. Ajusta el valor `scale` en la sección correspondiente
3. Reinicia el recurso: `/restart mu-hud`

### Mi resolución no está en la lista
El sistema usará automáticamente la configuración `default`. Puedes:
1. Agregar tu resolución específica siguiendo el ejemplo anterior
2. Modificar la configuración `default` para que se ajuste a tu pantalla

### Los cambios no se aplican
1. Asegúrate de guardar el archivo `config.lua`
2. Reinicia el recurso: `/restart mu-hud`
3. Verifica la consola F8 para ver qué resolución se detectó

## 📊 Cómo Saber tu Resolución

1. Abre la consola de FiveM (F8)
2. Busca el mensaje: `[MU-HUD] Resolución detectada: 1920x1080 - Aplicando configuraciones`
3. Usa esa resolución para personalizar tu configuración

## 💡 Notas Importantes

- Los cambios en `config.lua` requieren reiniciar el recurso
- Las posiciones se miden en píxeles (px)
- Los valores de escala son multiplicadores (1.0 = tamaño original)
- Puedes desactivar el sistema en cualquier momento cambiando `UseResolutionScaling` a `false`

## 🎨 Recomendaciones por Tipo de Pantalla

### Monitor Gaming (1080p - 144Hz)
```lua
scale = 1.0  -- Tamaño estándar, perfecto para gaming
```

### Monitor 2K (1440p)
```lua
scale = 1.15  -- Ligeramente más grande para mejor visibilidad
```

### Monitor 4K
```lua
scale = 1.5  -- Mucho más grande para compensar la alta densidad de píxeles
```

### Laptop (768p)
```lua
scale = 0.85  -- Más compacto para aprovechar el espacio limitado
```

### Ultrawide (21:9)
```lua
scale = 1.1  -- Similar a 1440p con ajustes de posición horizontal
```

## 📊 Tabla de Referencia Rápida por Aspect Ratio

| Aspect Ratio | Resoluciones Comunes | Ajustes Recomendados |
|--------------|---------------------|----------------------|
| **16:9** | 1920x1080, 2560x1440, 3840x2160 | Usa las configuraciones predefinidas |
| **21:9** | 3440x1440, 2560x1080 | `left: '15-30px'`, `right: '30-50px'` |
| **32:9** | 5120x1440 | `left: '50-80px'`, `right: '50-80px'` |
| **16:10** | 1920x1200, 2560x1600 | Similar a 16:9, ajusta `bottom: +5-10px'` |
| **4:3** | 1024x768, 1280x1024 | `scale: 0.7-0.8`, reduce `iconSize` |
| **5:4** | 1280x1024 | `scale: 0.75`, `bottom: '10-15px'` |

## 🔍 Comandos de Diagnóstico

### Ver tu Resolución Actual
```
F8 (Consola) → Busca: "[MU-HUD] Resolución detectada"
```

### Recargar Configuración
```
/restart mu-hud
```

### Verificar Aspect Ratio
Usa esta fórmula: **Ancho ÷ Alto**
- Resultado ~1.78 = 16:9
- Resultado ~2.39 = 21:9
- Resultado ~3.56 = 32:9
- Resultado ~1.60 = 16:10
- Resultado ~1.33 = 4:3

## 🎯 Guía Rápida de Solución de Problemas por Aspect Ratio

### Problema: HUD muy alejado en pantallas ultrawide
**Solución:**
```lua
playerHud = {
    left = '50px',  -- Aumenta este valor para alejar del borde
}
vehicleHud = {
    right = '50px', -- Aumenta este valor para alejar del borde
}
```

### Problema: Elementos apretados en pantallas 4:3
**Solución:**
```lua
playerHud = {
    scale = 0.7,      -- Reduce la escala
    iconSize = '28px', -- Iconos más pequeños
    gap = '10px'      -- Menos espacio entre elementos
}
```

### Problema: Minimapa desproporcionado
**Solución:**
```lua
minimap = {
    width = '280px',   -- Ajusta según tu aspect ratio
    height = '210px',  -- Mantén la proporción ~1.33:1
}
```

---

**Desarrollado para MU-HUD**  
*Sistema de configuración por resolución v1.0*

