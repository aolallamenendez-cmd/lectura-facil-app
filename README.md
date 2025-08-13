# Lectura Fácil App — Proyecto listo para GitHub Actions

Este repo incluye:
- Código Flutter (lib/) para **cámara/galería → OCR → adaptación UNE → TTS**.
- Workflow de **GitHub Actions** que construye un **APK** en la nube y lo sube como *artifact*.
- Si falta la carpeta `android/`, el workflow ejecuta `flutter create . --platforms=android` y **añade permisos** al Manifest.

## Cómo usar (principiantes)
1. Sube esta carpeta a un repo en **GitHub**.
2. Ve a la pestaña **Actions** → verás el workflow **Flutter APK**.
3. Pulsa **Run workflow** y espera a que termine.
4. Descarga el **artifact** `app-release.apk` y pásalo a tu Android.

## Probar en local (opcional)
```
flutter pub get
flutter run
```
Para APK:
```
flutter build apk --release
```
