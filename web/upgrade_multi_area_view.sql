-- ============================================================================
-- MRBS Multi-Area View Upgrade Script
-- ============================================================================
--
-- Dieses Script fügt die Funktionalität hinzu, mehrere Bereiche gleichzeitig
-- in der Hauptansicht anzuzeigen, ohne das Dropdown-Menü zu verwenden.
--
-- Änderungen:
-- 1. Fügt die Spalte 'show_in_main_view' zur mrbs_area Tabelle hinzu
-- 2. Setzt alle existierenden Bereiche auf 'show_in_main_view = 1' (standardmäßig angezeigt)
--
-- Verwendung:
-- mysql -u root -p qwv_reservation < upgrade_multi_area_view.sql
-- ============================================================================

-- Füge die neue Spalte 'show_in_main_view' zur mrbs_area Tabelle hinzu
-- Falls die Spalte bereits existiert, wird ein Fehler angezeigt, der ignoriert werden kann
ALTER TABLE mrbs_area
ADD COLUMN show_in_main_view tinyint(4) DEFAULT 1 NOT NULL
AFTER disabled;

-- Setze alle existierenden Bereiche auf 'show_in_main_view = 1'
-- (Dies ist nur eine Sicherheitsmaßnahme, da die Spalte bereits mit DEFAULT 1 erstellt wurde)
UPDATE mrbs_area
SET show_in_main_view = 1
WHERE show_in_main_view IS NULL OR show_in_main_view = 0;

-- Zeige die aktualisierten Bereiche an
SELECT id, area_name, disabled, show_in_main_view
FROM mrbs_area
ORDER BY sort_key, area_name;

-- ============================================================================
-- Ende des Upgrade Scripts
-- ============================================================================

-- Hinweis: Nach dem Ausführen dieses Scripts müssen Sie in der config.inc.php
-- folgende Einstellungen vornehmen:
--
-- $show_area_select = false;
-- $default_view_all = true;
--
-- Diese Einstellungen deaktivieren das Area-Dropdown und zeigen alle Bereiche
-- mit show_in_main_view=1 in der Hauptansicht an.
