# mu-hud

HUD premium para FiveM basado en Qbox/QBCore con un diseño limpio, moderno y altamente optimizado.

## ✨ Características

- 🧩 **Player HUD Dinámico**: Los iconos (salud, armadura, hambre, sed, estrés) solo aparecen cuando se necesitan.
- 🎙️ **Icono de Micrófono Permanente**: Siempre visible con animación de pulso al hablar.
- 🚗 **Vehicle HUD Completo**:
  - Velocímetro con cambio de color según velocidad.
  - Indicador de marcha (Gear).
  - Nivel de combustible y salud del motor con alertas visuales.
  - Calle y dirección cardinal (Brújula).
  - Altímetro automático para aeronaves.
- 🛡️ **Sistema de Cinturón de Seguridad**:
  - Alerta de parpadeo visual si no está abrochado.
  - Sonidos al poner/quitar el cinturón.
  - Sistema de eyección en caso de choque fuerte sin cinturón.
- 🧠 **Sistema de Estrés**:
  - Ganancia por disparos o alta velocidad.
  - Efectos visuales de desenfoque y temblor de cámara según el nivel.
- 📍 **Minimapa Cuadrado**: Personalización de escala y posición en tiempo real.
- ⚙️ **Menú de Configuración Completo** (ox_lib):
  - Control de visibilidad de todos los elementos del HUD.
  - Mostrar/Ocultar el marco del minimapa.
  - Mostrar/Ocultar la brújula y calles.
  - Ajustes de escalas, posiciones y colores del GPS.
  - Todas las configuraciones se guardan automáticamente.



## 🚀 Optimización

El recurso ha sido optimizado para mantener un **0.00ms - 0.01ms** en reposo (Resmon).
- Los hilos se detienen cuando el jugador está en menús o desconectado.
- Actualizaciones de NUI inteligentes (solo envían datos si hay cambios).
- Bucles combinados para reducir el uso de CPU.

## ⌨️ Comandos

- `/hudmenu`: Abre el menú de configuración (Escalas, Colores, Posiciones).
- `/togglebelt` (Tecla 'B'): Pone o quita el cinturón de seguridad.
- `/hudres`: Muestra tu resolución actual y si tiene configuración personalizada.
- `/hudreload`: Recarga las configuraciones de resolución sin reiniciar el recurso.

## 📐 Configuración por Resolución

El HUD incluye un sistema de configuración automática según la resolución de pantalla del jugador. Esto garantiza que el HUD se vea perfecto en cualquier monitor, desde laptops hasta monitores 4K.

### Resoluciones Soportadas
- **1920x1080** (Full HD)
- **2560x1440** (2K/QHD)
- **3840x2160** (4K/UHD)
- **3440x1440** (Ultrawide 21:9)
- **1366x768** (Laptops)
- **default** (Para cualquier otra resolución)

### Personalización
Puedes personalizar cada resolución editando `config.lua`. Cada resolución puede tener configuraciones únicas para:
- Escala del HUD del jugador y del vehículo
- Posiciones de todos los elementos
- Tamaño de iconos
- Dimensiones del minimapa

Para más detalles, consulta **[CONFIGURACION_RESOLUCIONES.md](CONFIGURACION_RESOLUCIONES.md)**.

## 🎛️ Panel de Controles del HUD

El HUD incluye un panel de controles visual en la interfaz que permite personalizar la visibilidad de elementos sin necesidad de comandos o editar archivos.

### Cómo Usar

1. **Abrir el Panel**: Haz clic en el icono de engranaje (⚙️) en la esquina superior derecha de la pantalla.
2. **Controles Disponibles**:
   - **Marco Minimapa**: Muestra u oculta el marco decorativo del minimapa.
   - **Brújula**: Muestra u oculta la brújula y los nombres de las calles.
3. **Indicadores Visuales**:
   - 🟢 **Verde con ojo abierto** = Elemento visible
   - 🔴 **Rojo con ojo tachado** = Elemento oculto
4. **Persistencia**: Tus preferencias se guardan automáticamente y se mantienen entre sesiones.

### Características

- ✅ Interfaz visual moderna y elegante
- ✅ Animaciones suaves al mostrar/ocultar elementos
- ✅ Guardado automático de preferencias (localStorage)
- ✅ Diseño responsive que se adapta a diferentes resoluciones
- ✅ Cierre automático al hacer clic fuera del menú


## 🛠️ Requisitos

- `qb-core` o `qbx-core`
- `ox_lib` (para el menú de configuración y notificaciones)

## 📦 Instalación

1. Descarga el recurso.
2. Añade `ensure mu-hud` a tu `server.cfg`.
3. Configura las opciones en `config.lua` a tu gusto.

