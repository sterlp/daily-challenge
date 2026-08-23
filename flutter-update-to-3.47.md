# Flutter Update auf 3.47.x — Migration Guide

Erprobt anhand dieses Projekts (Zeit-Tracker). Wiederverwendbar für die weiteren Projekte.
Quellen: <https://docs.flutter.dev/release/release-notes> ·
Breaking Changes: <https://docs.flutter.dev/release/breaking-changes>

## Ziel-Versionen

| Komponente | Version |
|---|---|
| Flutter | 3.47.1 stable (`flutter upgrade`) |
| Dart SDK | 3.13.1 → pubspec: `sdk: '>=3.13.0 <4.0.0'` |
| Gradle | 9.4.1 (Mindestversion für AGP 9.2) |
| Android Gradle Plugin (AGP) | 9.2.0 |
| Kotlin Gradle Plugin | 2.4.0 |
| Java / JVM Target | **21** |

## Ablauf

```bash
flutter upgrade                      # SDK aktualisieren
flutter pub upgrade --major-versions # Dependencies inkl. Major-Bumps
```

### android/gradle/wrapper/gradle-wrapper.properties

```
distributionUrl=https\://services.gradle.org/distributions/gradle-9.4.1-all.zip
```

### android/settings.gradle (plugins block)

```groovy
id "com.android.application" version "9.2.0" apply false
id "org.jetbrains.kotlin.android" version "2.4.0" apply false
```

### android/app/build.gradle

- **Wichtig:** `org.jetbrains.kotlin.android` (bzw. `kotlin-android`) **nicht** mehr im
  `plugins`-Block der App stehen haben! Flutter applied KGP im Legacy-Modus
  (`android.builtInKotlin=false`) automatisch selbst — mit explizitem Apply gibt es
  bei jedem Build die Migrations-Warnung. Die Version kommt aus `settings.gradle` (`apply false`).
- AGP-9-Syntax: `minSdk = flutter.minSdkVersion`, `targetSdk = flutter.targetSdkVersion`,
  `compileSdk flutter.compileSdkVersion`, `ndkVersion = flutter.ndkVersion`.
- Java 21:

```groovy
compileOptions {
    sourceCompatibility JavaVersion.VERSION_21
    targetCompatibility JavaVersion.VERSION_21
}
// statt kotlinOptions { jvmTarget = '17' }:
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21
    }
}
```

### android/gradle.properties

```properties
org.gradle.jvmargs=-Xmx4G
android.useAndroidX=true
android.enableJetifier=true
# Opt out of AGP built-in Kotlin: AGP bundles Kotlin 2.2.10, Flutter requires >= 2.2.20
android.builtInKotlin=false
android.newDsl=false
```

- **Built-in Kotlin geht NICHT:** AGP 9.0–9.2 bündeln Built-in-Kotlin nur in Version
  **2.2.10**, Flutter braucht aber **≥ 2.2.20** → Build schlägt fehl
  ("Your project's Kotlin version (2.2.10) is lower than Flutter's minimum supported version of 2.2.20").
  Deshalb: KGP-Version 2.4.0 in `settings.gradle` deklarieren (`apply false`) + Opt-out-Flags setzen.
- **Warnung vermeiden:** KGP nur in `settings.gradle` deklarieren, nicht in `app/build.gradle`
  apply-en — Flutter applied es dann selbst, ohne die "migrate to Built-in Kotlin"-Warnung zu loggen.
- Falls die Flags fehlen, fügt der Flutter-Migrator sie beim nächsten Build automatisch ein.
- `-Xmx1536M` reicht für Gradle 9.4 + AGP 9.2 nicht mehr → auf 4G angehoben (OOM sonst).
  Guide: <https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers>

## Breaking Changes (Flutter/Dart 3.39–3.47)

1. **`IconData` ist jetzt `final`** (ab 3.44) — Pakete, die `IconData` erweitern, kompilieren nicht mehr.
   - `material_design_icons_flutter` wird nicht mehr gepflegt → Ersatz:
     `flutter_material_design_icons: ^3.1.0` (gleiches `MdiIcons`-API, nur Import-Pfad ändern).
   - Guide: <https://docs.flutter.dev/release/breaking-changes/icondata-class-marked-final>
2. **`final`-Parameter sind ein Compile-Fehler** in Dart 3.13 (Sprachversion folgt der unteren SDK-Grenze!)
   — alle `void f(final int x)` entfernen. Auch in lokalen Pfad-Modulen die SDK-Grenze anheben.
3. **Deprecations ohne Codebedarf geprüft** (kommen später als Fehler):
   `describeEnum` (entfernt in 3.47!), `onReorder`, `TextInputConnection.setStyle`,
   `cacheExtent`, `containsSemantics`, `findChildIndexCallback`, DropdownButton-`value`.

Nicht betroffen, aber Verhalten kann sich ändern: Material-3-Token-Update,
`FontWeight` bei Variable Fonts, Semantics-Header, OpenGL ES Texture-Orientierung.

## Typische Dependency-Major-Bumps (falls im Projekt vorhanden)

| Paket | Alt → Neu | Fix |
|---|---|---|
| csv | 6 → 8 | `ListToCsvConverter(...).convert(x)` → `Csv(fieldDelimiter: ';').encode(x)`; Decoder analog `Csv(...).decode(s)`; `csv_settings_autodetection.dart` ist weg (EOL-Erkennung eingebaut); Parameter-Typ `List<List<dynamic>>` verwenden |
| file_picker | 10 → 12 | statisches API: `FilePicker.pickFile(...)` statt `FilePicker.platform.pickFiles(...)`; `pickFile()` liefert direkt `PlatformFile?` |
| share_plus | 12 → 13 | i. d. R. keine Änderung nötig (`SharePlus.instance.share(...)`) |

## Verifikation

```bash
dart fix --apply   # Lints automatisch beheben (vor allem prefer_const_*)
dart format .      # Formatierung (inkl. modules/)
flutter analyze    # keine errors/warnings/infos mehr
flutter test       # alle grün
flutter build apk --debug
```

Hinweise:
- `dart fix` behebt nicht alles — Reste (unnötiges `async`, `print`, tote Variablen,
  falsche `@override`) manuell anfassen.
- Test-Logging (`print(...)`) darf bleiben: `// ignore: avoid_print` über die Zeile.

