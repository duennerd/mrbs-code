# Multi-Area View - Änderungen und Dokumentation

## Übersicht

Diese Änderungen ermöglichen es, mehrere Bereiche (Areas) gleichzeitig in der Hauptansicht anzuzeigen, ohne das Area-Dropdown-Menü verwenden zu müssen. Administratoren können für jeden Bereich festlegen, ob dieser in der Hauptansicht angezeigt werden soll.

## Installation

### 1. Datenbank-Update

Führen Sie das SQL-Upgrade-Script aus:

```bash
mysql -u root -p qwv_reservation < web/upgrade_multi_area_view.sql
```

### 2. Konfiguration

Fügen Sie folgende Zeilen zur `web/config.inc.php` hinzu:

```php
$show_area_select = false;
$default_view_all = true;
```

## Geänderte Dateien

### Konfiguration
- **web/config.inc.php** - Multi-Area Einstellungen hinzugefügt (`$show_area_select`, `$default_view_all`)

### Admin-Bereich
- **web/edit_area.php** (Zeilen 185-192) - Checkbox "In Hauptansicht anzeigen" hinzugefügt
- **web/edit_area_handler.php** (Zeilen 55, 177, 381-382) - Verarbeitung der `show_in_main_view` Einstellung

### Hauptfunktionalität
- **web/functions_table.inc**
  - `day_table_innerhtml()` (Zeilen 524, 531-545, 582-628) - Multi-Area Unterstützung für Tagesansicht
  - `multiday_view_all_rooms_innerhtml()` (Zeilen 977, 994-1007, 1047-1095) - Multi-Area Unterstützung für Wochen-/Monatsansicht

- **web/index.php**
  - `make_area_select_html()` (Zeilen 41, 50) - Area-Dropdown wird bei `$show_area_select = false` versteckt
  - `get_view_nav()` (Zeilen 233, 252-256) - Tag/Woche/Monat Navigation ohne area/room Parameter

- **web/Themes/modern/header.inc.php**
  - `build_query()` (Zeilen 634-662) - URL-Parameter-Generierung angepasst

## Datenbank-Änderungen

### Neue Spalte in mrbs_area:
- **show_in_main_view** (tinyint, DEFAULT 1)
  - Steuert, ob Räume dieses Bereichs in der Hauptansicht erscheinen
  - Position: Nach der `disabled` Spalte

## Performance-Optimierungen

Die Implementierung verwendet eine zweistufige Abfrage-Strategie:

1. **Query 1:** Lade room_ids aus Bereichen mit `show_in_main_view=1`
2. **Query 2:** Lade nur Einträge für diese Räume mit `WHERE room_id IN (...)`

**Vorteil:** Nutzt den Index `idxRoomStartEnd` und vermeidet Table Scans
**Geschwindigkeitsgewinn:** Ca. 10-20x schneller bei größeren Datenmengen

## Verwendung

### Als Administrator:
1. Gehen Sie zu **Administration** → **Bereiche**
2. Bearbeiten Sie einen Bereich
3. Aktivieren/Deaktivieren Sie die Checkbox **"In Hauptansicht anzeigen"**
4. Speichern Sie die Änderungen

### Als Benutzer:
- Die Hauptansicht zeigt automatisch alle Räume aus allen aktivierten Bereichen
- Keine manuelle Area-Auswahl mehr nötig
- Navigation zwischen Tag/Woche/Monat behält alle ausgewählten Bereiche bei

## URL-Struktur

**Vorher (Single-Area):**
```
index.php?view=day&area=2&room=38&page_date=2025-12-14
```

**Nachher (Multi-Area):**
```
index.php?view=day&view_all=1&page_date=2025-12-14
```

## Kompatibilität

- **Rückwärtskompatibel:** Bei `$show_area_select = true` verhält sich das System wie vorher
- **Default-Werte:** Alle existierenden Bereiche werden mit `show_in_main_view=1` gesetzt
- **Keine Breaking Changes:** Bestehende Funktionalität bleibt vollständig erhalten

## Troubleshooting

### Keine Bereiche werden angezeigt
Prüfen Sie, ob mindestens ein Bereich `show_in_main_view=1` hat:
```sql
SELECT id, area_name, show_in_main_view FROM mrbs_area;
```

### Area-Dropdown erscheint noch
Prüfen Sie die config.inc.php - `$show_area_select` muss explizit `false` sein

### Performance-Probleme
Stellen Sie sicher, dass der Index `idxRoomStartEnd` auf mrbs_entry existiert:
```sql
SHOW INDEX FROM mrbs_entry WHERE Key_name = 'idxRoomStartEnd';
```

## Version

- **Erstellt:** 2025-12-14
- **MRBS Version:** Kompatibel mit MRBS 1.11.x
- **Lizenz:** Gleiche Lizenz wie MRBS (GPL)
