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
- ⚙️ **Menú de Configuración**: Cambia escalas, visibilidad y colores del GPS (requiere `ox_lib`).

## 🚀 Optimización

El recurso ha sido optimizado para mantener un **0.00ms - 0.01ms** en reposo (Resmon).
- Los hilos se detienen cuando el jugador está en menús o desconectado.
- Actualizaciones de NUI inteligentes (solo envían datos si hay cambios).
- Bucles combinados para reducir el uso de CPU.

## ⌨️ Comandos

- `/hudmenu`: Abre el menú de configuración (Escalas, Colores, Posiciones).
- `/togglebelt` (Tecla 'B'): Pone o quita el cinturón de seguridad.

## 🛠️ Requisitos

- `qb-core` o `qbx-core`
- `ox_lib` (para el menú de configuración y notificaciones)

## 📦 Instalación

1. Descarga el recurso.
2. Añade `ensure mu-hud` a tu `server.cfg`.
3. Configura las opciones en `config.lua` a tu gusto.


**Desarrollado con ❤️ para comunidades de Roleplay.**
![8a78d3ffdd14e8e3d912e8b3962f3a05](https://github.com/user-attachments/assets/5d420f41-4409-494c-960b-2e2b4575e3b2)

