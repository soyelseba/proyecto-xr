# Guía del proyecto para agentes

## Contexto del proyecto

Se está desarrollando un proyecto de realidad virtual (VR) con Godot 4.7 para Oculus Quest 3.

## Skills del proyecto

Las skills locales se encuentran en `.agents/skills/`, dentro de la raíz del proyecto. En este equipo, la ruta completa es `C:\Users\sebas\Documents\proyecto-xr\.agents\skills`.

- La skill disponible es `godot-master`. Su punto de entrada es `.agents/skills/godot-master/SKILL.md`.
- Antes de realizar tareas de desarrollo en Godot, leer ese `SKILL.md` y consultar los recursos que indique según la tarea.
- Para encontrar otras skills del proyecto, revisar las subcarpetas de `.agents/skills/` y sus archivos `SKILL.md`. Resolver las rutas relativas de cada skill desde su propia carpeta.

## Ubicación de Godot

El ejecutable de Godot indicado para este equipo está en:

```text
C:\Users\sebas\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe
```

Usar esta ruta explícita al ejecutar Godot; no asumir que está disponible en el `PATH`. Para abrir el proyecto desde PowerShell:

```powershell
& "C:\Users\sebas\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --editor --path "C:\Users\sebas\Documents\proyecto-xr"
```

## Estándares de la plantilla VR

- Escena de ejemplo y principal: `examples/interaction_lab/interaction_lab.tscn`.
- Componentes reutilizables: `features/vr/`; organizar por función, con escena, script y recursos juntos. No volver a concentrar lógica en `scripts/` o en la demo.
- Archivos y propiedades en `snake_case`; nodos y clases en `PascalCase`; GDScript tipado y señales para notificar eventos. Usar nombres únicos de escena o dependencias inyectadas.
- Jugador: `features/vr/player/vr_player.tscn`. Configuración: `features/vr/player/default_vr_settings.tres`, duplicada por instancia.
- OpenXR: trackers Godot `left_hand` / `right_hand`, poses `grip` / `aim`; acciones `primary`, `grip`, `trigger`, `ax_button`, `haptic` del mapa existente. No usar InputMap de escritorio para leer mandos XR.
- Mantener teletransporte y giro por pasos; movimiento continuo optativo. Procesar movimiento y agarre en física; conservar pausa, tracking y límite físico del runtime.
- Suelo apto para teletransporte: grupo `vr_teleportable`, con colisión y espacio libre para la cápsula. Capas y contratos de interacción documentados en `README.md`.
- Validar con `.\tools\vr.ps1 -Mode Verify`; probar desktop con `.\tools\vr.ps1 -Mode Desktop`. Completar `docs/quest_validation.md` en hardware antes de afirmar compatibilidad y rendimiento reales.
- `tools/build_template.gd` es una herramienta offline. `-Mode Rebuild` sobrescribe escenas y defaults; no ejecutarlo sobre diseños modificados salvo que la tarea pida regenerarlos.
