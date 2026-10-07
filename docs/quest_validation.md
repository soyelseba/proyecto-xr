# Validación manual · Quest 3

Las comprobaciones de PC pasaron en Godot 4.7.2. Esta lista queda pendiente de ejecutar con el APK en Quest 3; registra fecha, versión, frecuencia y resultados al probar.

| Prueba | Resultado esperado |
| --- | --- |
| Inicio | Imagen estéreo correcta; altura y escala métricas; cada mando controla su mano |
| Movimiento físico | Caminar, inclinarse y agacharse actualiza cabeza y cápsula sin sobrescribir tracking |
| Giro | Stick derecho gira una vez por pulsación; requiere volver al centro; gira alrededor de la cabeza |
| Teletransporte | Mantener A dibuja arco; soltar confirma solo verde; paredes, mesas, bordes y espacios ocupados son rechazados |
| Tracking perdido | Perder un mando libera su objeto y no confirma un teletransporte pendiente |
| Movimiento continuo | Desactivado al iniciar; botón activa / desactiva stick izquierdo; respeta paredes y rampa |
| Confort | Viñeta aparece al caminar; breve fundido al viajar; entrar con cabeza en sólido oscurece hasta salir |
| Modo sentado | Botón añade offset configurable; teletransporte coloca la cabeza sobre el destino |
| Agarre cercano | Grip toma el objeto próximo; mantener no lo suelta; soltar recupera física |
| Agarre remoto | Rayo bloqueado por paredes; objeto se acerca físicamente a la mano |
| Dos manos | Cada mano toma un objeto distinto; no se puede robar el que ya está retenido |
| Lanzamiento | El objeto conserva velocidad al soltar; entra en el cesto y registra progreso |
| Objeto en viaje | El objeto retenido acompaña el teletransporte; no adquiere velocidad de lanzamiento artificial |
| Linterna | Grip toma; gatillo enciende / apaga; haz sigue al objeto |
| UI del mundo | Gatillo pulsa cada botón una vez; rayos, texto y color muestran el objetivo |
| Palanca | Grip y movimiento lateral cambian valor entre 0 y 1; indicador responde |
| Encaje | Acepta llave verde al soltar; rechaza cubos; extracción restaura física y cierra puerta |
| Puerta | Llave o botón abre / cierra; collider acompaña la animación |
| Háptica | Pulso discreto al enfocar, tomar, soltar, usar y viajar |
| Menú del sistema | Simulación pausa y audio se silencia; cerrar menú reanuda sin agarre retenido |
| Retirar visor | Detiene interacción; recuperación de foco restaura estado previo |
| Recentrado | Cancela interacción y teletransporte pendientes; tracking sigue coherente |
| Límite físico | Si runtime expone polígono, aviso aparece junto al borde; comprobar también el límite del sistema |
| Reinicio | Jugador y objetos vuelven; encaje vacío, puerta cerrada, palanca centrada, movimiento optativo apagado |
| Sesión prolongada | Medir FPS y tiempo de CPU / GPU a 90 Hz durante al menos 10 minutos, incluyendo linterna y varios objetos |

Exportación: verificar plantillas 4.7.2, SDK/JDK, ARM64, OpenXR y un identificador Android propio. Guardar el resultado de instalación y lanzamiento del APK; las pruebas headless no certifican estos pasos.
