# Island Mobile

Juego de supervivencia y exploración 3D isométrica para Android, desarrollado con **Godot 4**.

## Visión del proyecto

Island Mobile es una experiencia de mundo abierto en una isla que el jugador transforma gradualmente: comienza sobreviviendo con recursos básicos y progresa hasta construir un asentamiento desarrollado y ampliar las zonas habitables.

## Pilares jugables

- **Supervivencia:** salud, hambre, sed, energía, descanso, clima y peligros naturales.
- **Exploración:** isla abierta con playas, bosques, montañas, cuevas, ruinas y zonas con recursos propios.
- **Recolección:** madera, hojas, brotes, piedra, minerales, fibras, alimentos y otros materiales.
- **Agricultura:** preparar parcelas, sembrar, regar, fertilizar, cultivar y cosechar; plantar árboles y recuperar la vegetación.
- **Construcción:** refugios, casas, almacenes, caminos, cercas, puentes y muelles.
- **Fabricación:** herramientas, armas, equipamiento, estaciones de trabajo y objetos útiles.
- **Progresión y expansión:** habilidades, desbloqueo de terrenos y mejora gradual de la isla.
- **Vida silvestre:** animales, pesca y, en etapas posteriores, domesticación y crianza.
- **Persistencia:** guardar el mundo y conservar árboles talados, cultivos, construcciones, inventario y cambios realizados.

## Estado del prototipo

La rama `main` ya contiene un primer esqueleto de proyecto Godot 4:

- Configuración de proyecto y escena principal.
- Isla provisional generada mediante primitivas 3D (agua, terreno, costa, árboles y rocas).
- Personaje 3D con cámara ortográfica isométrica.
- Movimiento de prueba con teclado y joystick táctil.
- Hoja de ruta técnica y criterios de aceptación.

**Importante:** esta es una base inicial de prototipo. Los archivos aún deben abrirse y ejecutarse en Godot para validar la escena y los controles; todavía no se ha generado un APK.

## Cómo abrir el proyecto

1. Descarga o clona este repositorio.
2. Abre la carpeta del proyecto desde Godot 4.3 o una versión 4.x compatible.
3. Ejecuta la escena principal (`scenes/main.tscn`).
4. En escritorio, usa WASD. En pantalla táctil, usa el joystick de la esquina inferior izquierda.

## Hoja de ruta

Consulta [docs/ROADMAP.md](docs/ROADMAP.md) para ver las fases, tareas pendientes y criterios de aceptación.

## Criterios de trabajo

- Mantener el proyecto independiente de **Medieval Fantasy**.
- No declarar una función terminada hasta que esté implementada y probada.
- No declarar una APK generada sin un artefacto verificable.
- Priorizar rendimiento, controles cómodos y legibilidad en pantallas Android.
- Documentar decisiones técnicas y cambios importantes.
