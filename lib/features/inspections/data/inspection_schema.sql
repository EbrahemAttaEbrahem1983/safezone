CREATE TABLE IF NOT EXISTS inspections (id TEXT PRIMARY KEY, unit_id TEXT NOT NULL, date INTEGER NOT NULL, inspector TEXT NOT NULL, status TEXT NOT NULL, notes TEXT, updated_at INTEGER NOT NULL, updated_by TEXT NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0);
CREATE TABLE IF NOT EXISTS findings (id TEXT PRIMARY KEY, inspection_id TEXT NOT NULL, title TEXT NOT NULL, description TEXT, severity TEXT NOT NULL, resolved INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL, updated_by TEXT NOT NULL, is_deleted INTEGER NOT NULL DEFAULT 0);
CREATE INDEX IF NOT EXISTS idx_inspections_unit ON inspections(unit_id);
CREATE INDEX IF NOT EXISTS idx_findings_inspection ON findings(inspection_id);
