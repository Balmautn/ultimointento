# Claude Organizador

App personal en Flutter (calendario 2026, actividades, categorías, horarios y notas, con SQLite local).

## Cómo generar la app (APK de Android)

1. Subí todos los archivos a un repositorio de GitHub, manteniendo la estructura (`pubspec.yaml`, `lib/` y `.github/` en la raíz).
2. Entrá a **Actions → Build Android APK → Run workflow** (o se ejecuta solo al subir a `main`).
3. Cuando termina (unos 5-8 minutos), descargá el APK desde **Releases** (columna derecha del repo) o desde **Artifacts** en la ejecución.
4. Instalalo en el celular (hay que permitir "instalar apps desconocidas").

Windows, macOS e iOS (sin firma) están en workflows aparte que se lanzan solo a mano.

## Nota
Windows/macOS: `sqflite` no funciona en escritorio sin un adaptador extra; la compilación va a andar pero el guardado local requiere cambios.
