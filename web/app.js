$(document).ready(function () {
  /* =========================================================
     CONFIGURACIÓN DE RESOLUCIÓN
     ========================================================= */
  let resolutionSettings = null;

  // Función para aplicar configuraciones de resolución
  function applyResolutionSettings(settings) {
    if (!settings) return;

    // Player HUD
    if (settings.playerHud) {
      const ph = settings.playerHud;
      if (ph.scale) document.documentElement.style.setProperty('--player-scale', ph.scale);
      if (ph.left) document.documentElement.style.setProperty('--player-hud-left', ph.left);
      if (ph.bottom) document.documentElement.style.setProperty('--player-hud-bottom', ph.bottom);
      if (ph.iconSize) document.documentElement.style.setProperty('--icon-size', ph.iconSize);
      if (ph.gap) document.documentElement.style.setProperty('--player-hud-gap', ph.gap);
    }

    // Vehicle HUD
    if (settings.vehicleHud) {
      const vh = settings.vehicleHud;
      if (vh.scale) document.documentElement.style.setProperty('--veh-scale', vh.scale);
      if (vh.right) document.documentElement.style.setProperty('--veh-hud-right', vh.right);
      if (vh.bottom) document.documentElement.style.setProperty('--veh-hud-bottom', vh.bottom);
    }

    // Compass
    if (settings.compass) {
      const c = settings.compass;
      if (c.scale) document.documentElement.style.setProperty('--compass-scale', c.scale);
      if (c.top) {
        const compassContainer = document.getElementById('compass-street-container');
        if (compassContainer) compassContainer.style.top = c.top;
      }
    }

    // Minimap
    if (settings.minimap) {
      const m = settings.minimap;
      if (m.width) document.documentElement.style.setProperty('--mm-frame-width', m.width);
      if (m.height) document.documentElement.style.setProperty('--mm-frame-height', m.height);
      const minimapFrame = document.getElementById('minimap-frame');
      if (minimapFrame) {
        if (m.left) minimapFrame.style.left = m.left;
        if (m.bottom) minimapFrame.style.bottom = m.bottom;
        if (m.width) minimapFrame.style.width = m.width;
        if (m.height) minimapFrame.style.height = m.height;
      }
    }
  }

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

      case 'applyResolutionSettings':
        resolutionSettings = data.settings;
        applyResolutionSettings(resolutionSettings);
        break;
    }
  });

  /* =========================================================
     PANEL DE CONTROLES DEL HUD
     ========================================================= */

  // Estado inicial de los controles (cargar desde localStorage)
  let minimapFrameVisible = localStorage.getItem('minimapFrameVisible') !== 'false';
  let compassVisible = localStorage.getItem('compassVisible') !== 'false';

  // Aplicar estado inicial
  function applyControlStates() {
    if (!minimapFrameVisible) {
      $('#minimap-frame').hide();
      $('#toggle-minimap-frame').removeClass('active').attr('data-active', 'false');
      $('#toggle-minimap-frame i').removeClass('bi-eye-fill').addClass('bi-eye-slash-fill');
    }
    if (!compassVisible) {
      $('#compass-street-container').hide();
      $('#toggle-compass').removeClass('active').attr('data-active', 'false');
      $('#toggle-compass i').removeClass('bi-eye-fill').addClass('bi-eye-slash-fill');
    }
  }

  applyControlStates();

  // Toggle del menú de controles
  $('#toggle-controls').on('click', function () {
    $('#controls-menu').toggleClass('hidden');
  });

  // Toggle del marco del minimapa
  $('#toggle-minimap-frame').on('click', function () {
    const btn = $(this);
    const isActive = btn.attr('data-active') === 'true';

    if (isActive) {
      // Ocultar
      $('#minimap-frame').fadeOut(300);
      btn.removeClass('active').attr('data-active', 'false');
      btn.find('i').removeClass('bi-eye-fill').addClass('bi-eye-slash-fill');
      minimapFrameVisible = false;
      localStorage.setItem('minimapFrameVisible', 'false');
    } else {
      // Mostrar
      $('#minimap-frame').fadeIn(300);
      btn.addClass('active').attr('data-active', 'true');
      btn.find('i').removeClass('bi-eye-slash-fill').addClass('bi-eye-fill');
      minimapFrameVisible = true;
      localStorage.setItem('minimapFrameVisible', 'true');
    }
  });

  // Toggle de la brújula
  $('#toggle-compass').on('click', function () {
    const btn = $(this);
    const isActive = btn.attr('data-active') === 'true';

    if (isActive) {
      // Ocultar
      $('#compass-street-container').fadeOut(300);
      btn.removeClass('active').attr('data-active', 'false');
      btn.find('i').removeClass('bi-eye-fill').addClass('bi-eye-slash-fill');
      compassVisible = false;
      localStorage.setItem('compassVisible', 'false');
    } else {
      // Mostrar
      $('#compass-street-container').fadeIn(300);
      btn.addClass('active').attr('data-active', 'true');
      btn.find('i').removeClass('bi-eye-slash-fill').addClass('bi-eye-fill');
      compassVisible = true;
      localStorage.setItem('compassVisible', 'true');
    }
  });

  // Cerrar el menú al hacer clic fuera
  $(document).on('click', function (e) {
    if (!$(e.target).closest('#hud-controls-panel').length) {
      $('#controls-menu').addClass('hidden');
    }
  });

  function json(obj) { return JSON.stringify(obj); }
});

