$(document).ready(function () {
  /* =========================================================
     UTILIDADES
     ========================================================= */
  const clamp100 = (v) => Math.max(0, Math.min(100, Math.floor(v || 0)));

  /* =========================================================
     HUD DEL JUGADOR
     ========================================================= */
  function updatePlayerHUD(data) {
    const getValue = (val) => {
      let v = (typeof val === 'object' && val !== null) ? (val.percent ?? val.value ?? 0) : (val ?? 0);
      if (v > 0 && v <= 1) v *= 100;
      return clamp100(v);
    };

    const h = getValue(data.health);
    const a = getValue(data.armor);
    const hu = getValue(data.hunger);
    const th = getValue(data.thirst);
    const s = getValue(data.stress || data.stressLevel);

    // Salud: Visible si < 100%
    if (h < 100) $('#health-container').removeClass('hidden');
    else $('#health-container').addClass('hidden');
    $('#health').css('--fill', h + '%');

    // Armadura: Visible si > 0%
    if (a > 0) $('#armor-container').removeClass('hidden');
    else $('#armor-container').addClass('hidden');
    $('#armor').css('--fill', a + '%');

    // Hambre: Visible si < 100%
    if (hu < 100) $('#hunger-container').removeClass('hidden');
    else $('#hunger-container').addClass('hidden');
    $('#hunger').css('--fill', hu + '%');
    if (hu < 20) $('#hunger-container').addClass('warning');
    else $('#hunger-container').removeClass('warning');

    // Sed: Visible si < 100%
    if (th < 100) $('#thirst-container').removeClass('hidden');
    else $('#thirst-container').addClass('hidden');
    $('#thirst').css('--fill', th + '%');
    if (th < 20) $('#thirst-container').addClass('warning');
    else $('#thirst-container').removeClass('warning');

    // Estrés: Visible si > 0%
    if (s > 0) $('#stress-container').removeClass('hidden');
    else $('#stress-container').addClass('hidden');
    $('#stress').css('--fill', s + '%');
    if (s > 70) $('#stress-container').addClass('warning');
    else $('#stress-container').removeClass('warning');

    // Micrófono: Siempre visible
    $('#mute-container').removeClass('hidden');
    if (data.talking) $('#mute-container').addClass('talking');
    else $('#mute-container').removeClass('talking');

    /*
    // Stamina vs Oxygen
    if (data.isDiving) {
      $('#player-bottom-bar').addClass('diving');
      $('#player-bottom-fill').css('width', getValue(data.oxygen) + '%');
    } else {
      $('#player-bottom-bar').removeClass('diving');
      const staminaPct = getValue(data.stamina || 100);
      $('#player-bottom-fill').css('width', staminaPct + '%');
    }
    */

    // Brújula a pie
    if (data.direction) updateCompass(data.direction);
  }

  function updateCompass(direction) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const currentDir = direction.toString().toUpperCase();
    const dirIndex = directions.indexOf(currentDir);

    if (dirIndex !== -1) {
      const leftDir = directions[(dirIndex - 1 + directions.length) % directions.length];
      const rightDir = directions[(dirIndex + 1) % directions.length];

      $('#compass-main').text(currentDir);
      $('#compass-left').text(leftDir);
      $('#compass-right').text(rightDir);
    }
  }

  /* =========================================================
     VEHICLE HUD
     ========================================================= */
  function getThrottlePercent(data, spd) {
    const keys = ['throttle', 'accel', 'rpm', 'accelAxis'];
    for (const k of keys) {
      if (data[k] != null) {
        let v = +data[k];
        if (v <= 1) v *= 100;
        return clamp100(v);
      }
    }
    return 0;
  }

  function updateVehicleHUD(data) {
    // Velocidad con sincronización perfecta (3 dígitos siempre)
    const spd = Math.floor(data.speed || 0);
    const speedElement = $('#speed-val');

    // Generamos el string de 3 dígitos (ej: 019)
    let spdStr = spd.toString().padStart(3, '0');
    let html = '';
    let isLeading = true;

    for (let i = 0; i < spdStr.length; i++) {
      // El último dígito nunca es "ghost" (para mostrar un '0' si la velocidad es 0)
      if (isLeading && spdStr[i] === '0' && i < spdStr.length - 1) {
        html += `<span class="ghost-digit">0</span>`;
      } else {
        isLeading = false;
        html += `<span>${spdStr[i]}</span>`;
      }
    }
    speedElement.html(html);

    // Cambio de color dinámico
    if (spd < 100) {
      speedElement.css('color', '#ffffff');
      speedElement.css('text-shadow', '0 0 15px rgba(255, 255, 255, 0.15)');
    } else if (spd < 130) {
      speedElement.css('color', '#fffb00');
      speedElement.css('text-shadow', '0 0 15px rgba(255, 251, 0, 0.4)');
    } else {
      speedElement.css('color', '#ff3d3d');
      speedElement.css('text-shadow', '0 0 15px rgba(255, 61, 61, 0.6)');
    }

    // Marcha
    let gear = data.gear || 'N';
    if (gear === 0) gear = 'R';
    $('#gear-val').text(gear);

    // Cinturón
    if (data.seatbeltOn) {
      $('#belt-item').addClass('active').removeClass('low belt-blink');
      $('#belt-text').text('ON');
    } else {
      $('#belt-item').addClass('low belt-blink').removeClass('active');
      $('#belt-text').text('OFF');
    }

    // Gasolina con estados de alerta
    const fuel = Math.floor(data.fuel || 0);
    $('#fuel-text').text(fuel + '%');
    $('#fuel-item').removeClass('active warning low');
    if (fuel <= 20) {
      $('#fuel-item').addClass('low'); // Rojo
    } else if (fuel <= 60) {
      $('#fuel-item').addClass('warning'); // Amarillo
    } else {
      $('#fuel-item').addClass('active'); // Verde
    }

    const originalEngine = data.engineHealth;
    const engine = Math.floor(originalEngine);
    $('#engine-text').text(engine + '%');
    $('#engine-item').removeClass('active warning low critical-blink');

    // Si originalEngine es 0 o menor, es crítico o apagado
    if (originalEngine <= 0) {
      $('#engine-item').addClass('low critical-blink');
      $('#engine-text').text('0%');
    } else if (engine < 20) {
      $('#engine-item').addClass('low critical-blink');
    } else if (engine < 40) {
      $('#engine-item').addClass('low');
    } else if (engine <= 80) {
      $('#engine-item').addClass('warning');
    } else {
      $('#engine-item').addClass('active');
    }

    // RPM
    const rpmVal = data.rpm || 0;
    const rpmPercent = rpmVal * 100;
    $('#rpm-fill').css('width', rpmPercent + '%');

    // Opacidad dinámica (menos rojo al ralentí)
    let rpmOpacity = 0.2 + (rpmVal * 0.8);
    if (rpmOpacity > 1.0) rpmOpacity = 1.0;
    $('#rpm-fill').parent().parent().css('--rpm-opacity', rpmOpacity); // Aplicar a la variable root o contenedor

    // Efecto de vibración si el motor está encendido (> 0.1 RPM)
    if (rpmVal > 0.1) {
      $('.rpm-container').addClass('vibrating');
    } else {
      $('.rpm-container').removeClass('vibrating');
    }

    // Brújula
    if (data.direction) updateCompass(data.direction);

    const s1 = (data.street1 || '').toString().trim();
    const s2 = (data.street2 || '').toString().trim();

    $('#street-1').text(s1 || '---');
    $('#street-2').text(s2 || '---');
  }

  function getValueFromData(val) {
    let v = (typeof val === 'object' && val !== null) ? (val.percent ?? val.value ?? 0) : (val ?? 0);
    if (v > 0 && v <= 1) v *= 100;
    return clamp100(v);
  }

  /* =========================================================
     NUI MESSAGES
     ========================================================= */
  let isMinimapHidden = false;
  let isCompassHidden = false;

  window.addEventListener('message', function (event) {
    const data = event.data;
    switch (data.action) {
      case 'showPlayerHUD':
        $('body').show();
        $('#player-hud-container').fadeIn('slow');
        break;

      case 'hidePlayerHUD':
        $('#player-hud-container').fadeOut('slow');
        $('body').removeClass('veh-active');
        // No ocultamos el body aquí para permitir que otros elementos sigan visibles
        break;

      case 'updatePlayerHUD': updatePlayerHUD(data); break;

      case 'showVehicleHUD':
        $('#vehicle-hud-container').fadeIn('slow');
        if (!isMinimapHidden) $('#minimap-frame').fadeIn('slow');
        if (!isCompassHidden) $('#compass-street-container').fadeIn('slow');
        $('body').addClass('veh-active');
        break;

      case 'hideVehicleHUD':
        $('#vehicle-hud-container').fadeOut('slow');
        $('#minimap-frame').fadeOut('slow');
        $('body').removeClass('veh-active');
        break;

      case 'updateVehicleHUD': updateVehicleHUD(data); break;

      case 'updateSeatbelt':
        if (data.seatbeltOn) {
          $('#belt-item').addClass('active').removeClass('low');
          $('#belt-text').text('ON');
        } else {
          $('#belt-item').addClass('low').removeClass('active');
          $('#belt-text').text('OFF');
        }
        break;

      // NUEVOS CONTROLES
      case 'updateHUDVisibility':
        if (data.element === 'minimap-frame') isMinimapHidden = !data.show;
        if (data.element === 'compass-street-container') isCompassHidden = !data.show;
        if (data.show) $(`#${data.element}`).fadeIn();
        else $(`#${data.element}`).fadeOut();
        break;

      case 'updateHUDScale':
        document.documentElement.style.setProperty(data.variable, data.value);
        break;

      case 'updateCinematicBars':
        if (data.show) {
          $('#cinematic-top, #cinematic-bottom').fadeIn();
        } else {
          $('#cinematic-top, #cinematic-bottom').fadeOut();
        }
        break;
    }
  });

  function json(obj) { return JSON.stringify(obj); }
});
