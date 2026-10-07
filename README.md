# Plantilla VR · Godot 4.7 / Quest 3

Base reutilizable de realidad virtual con OpenXR para Oculus / Meta Quest 3. Nace del campo de pruebas XR de INACAP Renca 2026. Las referencias de interacción son VRChat y Half-Life: Alyx; la plantilla aporta locomoción y manipulación para construir experiencias propias.

## Probar

Abre `project.godot` con Godot 4.7.2 y ejecuta con F5. La escena principal es `examples/interaction_lab/interaction_lab.tscn`. Si OpenXR está inicializado se utiliza el visor; en PC sin runtime se utiliza escritorio. En Android, un fallo de OpenXR cierra la aplicación con error.

Desde PowerShell, en la raíz:

```powershell
.\tools\vr.ps1 -Mode Desktop
# Alternativa para PC con soporte Vulkan limitado:
.\tools\vr.ps1 -Mode Desktop -Compatibility
# Visor conectado mediante su runtime OpenXR, por ejemplo Quest Link:
.\tools\vr.ps1 -Mode XR
# Verificación sin visor:
.\tools\vr.ps1 -Mode Verify
```

El helper acepta `-GodotPath` o `GODOT_PATH`. La instalación local está en una **carpeta** llamada `C:\Users\sebas\Downloads\Godot_v4.7.2-stable_win64.exe`; dentro están los ejecutables normal y `_console.exe`.

## Controles

| Acción | Quest / Touch | Escritorio |
| --- | --- | --- |
| Caminar | Stick izquierdo | WASD |
| Giro por pasos | Stick derecho horizontal | Q / E |
| Teletransportar | Mantener A, apuntar con mano derecha, soltar | Mantener T, apuntar con ratón, soltar |
| Tomar / mantener / soltar | Grip de cada mano | Mantener / soltar F (izquierda) o G (derecha) |
| Usar / pulsar | Gatillo de cada mano | Clic izquierdo (mano derecha), clic derecho (mano izquierda) |
| Mirar / agacharse | Movimiento físico del visor | Ratón para mirar |
| Liberar / capturar ratón | — | Esc |

Activa **Movimiento libre** en el panel para caminar con el stick o WASD. Por defecto se usa teletransporte y giro de 30°. El panel permite modo sentado, abrir / cerrar puerta y reiniciar. El modo sentado añade altura configurable al origen sin sobrescribir la pose del visor.

## Laboratorio de ejemplo

Estaciones identificadas y panel de progreso:

- Agarre de cubos con ambas manos, con propiedad exclusiva por objeto. El área de mano prioriza agarre cercano; el rayo permite agarre a distancia.
- Lanzamiento con velocidad de mano limitada y cesto receptor mediante Area3D.
- Linterna: tomar con Grip y encender / apagar con gatillo.
- Botones en el mundo mediante rayo o proximidad + gatillo.
- Palanca: Grip + arrastre, valor de 0 a 1. El gatillo alterna extremos como alternativa de escritorio.
- Encaje de la llave verde: soltarla en el aro bloquea el objeto y abre la puerta; retirarla cierra la puerta.
- Suelo, rampa y plataforma para locomoción. Arco y marcador de teletransporte: verde válido, rojo bloqueado.
- Reinicio de objetos, jugador, puerta, encaje y progreso sin recargar la escena.

## Organización

```text
features/vr/
  player/       jugador, configuración, entrada, movimiento y confort
  hands/        manos, detección, agarre y feedback
  locomotion/   teletransporte y validación de destino
  interaction/  objetos, botones, linterna, palanca, encaje y puerta
  session/      ciclo de vida OpenXR y límite físico
examples/interaction_lab/  sala y conexiones entre estaciones
tools/                    ejecución, generación y verificación
scenes/                   entradas de compatibilidad del proyecto original
```

Cada función guarda escenas, scripts y recursos juntos. Archivos: snake_case; nodos y clases: PascalCase; señales y propiedades: snake_case. Referencias internas con nombres únicos de escena y dependencias inyectadas mediante configure(). La demo conecta señales y llama métodos públicos; las piezas VR no dependen del laboratorio ni de un autoload.

```text
VRPlayer (CharacterBody3D)
  BodyShape
  XROrigin (XROrigin3D)
    Head (XRCamera3D) → ComfortMask / BoundaryWarning
    LeftHand / RightHand (VRHand)
      Grip (XRController3D) → HandVisual / HoldPoint / GrabArea
      Aim (XRController3D) → InteractionRay / Beam / Hint
  InputAdapter / Locomotion / Teleport
  XRSession / Boundary / HeadCollision
```

Los trackers de Godot son **left_hand / right_hand**, con poses **grip / aim**. El mapa OpenXR mantiene rutas /user/hand/left y /user/hand/right y acciones grip_pose / aim_pose; el runtime las traduce a nombres de pose de Godot. Acciones utilizadas: primary (sticks), grip, trigger, ax_button y haptic. Se eliminan grab, move y turn antiguos porque no tenían bindings.

| Capa física | Bit | Uso |
| --- | --- | --- |
| World | 1 | Suelo, paredes, puertas y plataformas |
| Grabbable | 2 | Objetos físicos |
| Player | 4 | Cápsula del jugador |
| Interactable | 8 | Botones y palancas |
| Socket | 16 | Receptores |

Rayos: máscara 11 (World + Grabbable + Interactable); una pared bloquea el alcance. Jugador: máscara 9 (World + Interactable). Objetos: no colisionan con la cápsula del jugador para evitar que un objeto retenido lo empuje.

## Reutilizar en otro proyecto

1. Copia el proyecto sin .godot/, .git/ ni el build Android generado. Cambia nombre, icono e identificador Android antes de distribuir.
2. Conserva features/vr/, openxr_action_map.tres y la configuración OpenXR de project.godot.
3. Crea un mundo e instancia **features/vr/player/vr_player.tscn** a nivel del suelo. Añade suelo con colisión. No escales la raíz del jugador ni sus formas de colisión.
4. Marca cuerpos transitables con el grupo **vr_teleportable**. Paredes y mesas quedan fuera. El destino necesita espacio para la cápsula y soporte bajo toda su huella.
5. Instancia escenas de interaction/ y ajusta sus exports. Para otros modelos, adapta mesh y shape y conserva los nombres únicos utilizados por su script.
6. Cambia **player/default_vr_settings.tres** o asigna otro VRSettings a VRPlayer.defaults. Cada jugador duplica su configuración; los cambios de confort son locales.
7. Conecta VRButton.activated, VRLever.value_changed, VRSocket.inserted o VRGrabbable.used con tu lógica. La linterna muestra cómo extender un objeto usable.
8. Selecciona tu escena principal y elimina el laboratorio cuando ya no lo necesites.

Contrato de interacción: begin_grab(anchor) -> bool, end_grab(velocity), use(anchor) y get_prompt() -> String. Implementa los métodos necesarios en el cuerpo detectado. Objetos movibles: seguimiento físico en _integrate_forces(), sin cambiar de padre. Los controles fijos liberan el agarre al teletransportar; los objetos movibles retenidos acompañan al jugador.

scenes/xr_main.tscn y scenes/grabbable_cube.tscn conservan sus UID y delegan en escenas nuevas. Los scripts originales de agarre y arranque se sustituyen por componentes estandarizados.

## Confort y rendimiento

- Teletransporte y giro por pasos siempre disponibles. Movimiento continuo optativo con viñeta configurable; no se incluye giro continuo.
- Giro alrededor de la cabeza y compensación de desplazamiento físico al teletransportar. Agacharse adapta la cápsula; el tracking permanece bajo control del runtime.
- Si la cabeza entra en un sólido virtual, la vista se oscurece hasta que salga. El aviso de proximidad utiliza XRInterface.get_play_area() cuando está disponible. El límite físico no restringe los destinos del mundo virtual.
- Pérdida de foco / sesión pausa simulación, silencia audio y libera agarres; al volver se restaura el estado previo. Perder tracking invalida entradas y no confirma teletransporte pendiente.
- Mobile/Vulkan, una luz principal sin sombras y geometría sencilla. Se solicita 90 Hz cuando el runtime lo admite y los ticks de física se ajustan a la frecuencia informada. Los 90 FPS deben medirse en Quest 3.

El límite del runtime sigue siendo la referencia física; algunos runtimes no exponen su polígono y el aviso adicional no se muestra.

## Exportar a Quest 3

Preset **Meta Quest**: Android, Gradle, ARM64 y OpenXR. Identificador de ejemplo: org.godotengine.vrtemplate; cámbialo por el de tu producto.

Instala plantillas de exportación de la misma versión, JDK 17 y Android SDK; configura las rutas en Godot y regenera el build Android al cambiar de motor. android/ es generado e ignorado por Git. El plugin OpenXR Vendors añade opciones del fabricante; desde Godot 4.6 es opcional para muchos dispositivos, pero debe revisarse para publicación en tiendas.

Referencias oficiales: [configuración XR](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html), [sesión y foco](https://docs.godotengine.org/en/stable/tutorials/xr/a_better_xr_start_script.html), [deploy Android](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html) y [trackers y poses OpenXR](https://github.com/godotengine/godot/blob/master/modules/openxr/openxr_interface.cpp).

## Verificación y límites

**tools/verify_template.gd** usa el motor real: entrada desktop y trackers XR simulados, dirección de sticks, poses, colisiones, compensación de cabeza, destinos inválidos, agarre mantenido y exclusivo, límites de lanzamiento, encaje y extracción, linterna, foco, reinicio y ejecución aislada de escenas. Sale con código 1 si falla una condición. La sala también se renderizó en PC.

Antes de distribuir, completa [docs/quest_validation.md](docs/quest_validation.md). Las pruebas automáticas no comprueban tracking físico, háptica real, confort ni rendimiento del APK. Esta base usa mandos; seguimiento de manos, avatares multijugador, escalada, inventarios y armas son extensiones específicas del producto.

Las escenas están guardadas y listas para editar. **tools/vr.ps1 -Mode Rebuild sobrescribe cambios de diseño**: úsalo solo para reconstruir defaults a partir de tools/build_template.gd.
