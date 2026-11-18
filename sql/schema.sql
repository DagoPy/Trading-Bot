-- Esquema SQLite del proyecto integrador (activos, precios, features_ml, descargas)
-- Ejecutar con una conexión que tenga PRAGMA foreign_keys = ON.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS activos (
    ticker TEXT PRIMARY KEY, nombre TEXT NOT NULL,
    tipo TEXT, sector TEXT, mercado TEXT, moneda TEXT,
    zona_horaria TEXT
);

CREATE TABLE IF NOT EXISTS precios (
    ticker TEXT NOT NULL, intervalo TEXT NOT NULL,
    fecha TEXT NOT NULL, fecha_sesion TEXT,
    open REAL NOT NULL, high REAL NOT NULL,
    low REAL NOT NULL, close REAL NOT NULL,
    adj_close REAL, volume INTEGER NOT NULL CHECK(volume >= 0),
    PRIMARY KEY (ticker, intervalo, fecha),
    FOREIGN KEY (ticker) REFERENCES activos(ticker),
    CHECK(low <= high), CHECK(close > 0)
);

CREATE TABLE IF NOT EXISTS features_ml (
    ticker TEXT NOT NULL, intervalo TEXT NOT NULL,
    fecha TEXT NOT NULL, feature_version TEXT NOT NULL,
    return_ REAL, log_return REAL, sma10 REAL, sma20 REAL,
    volatility20 REAL, volume_change REAL,
    lag1 REAL, lag2 REAL, lag3 REAL,
    target_reg REAL, target_cls INTEGER,
    target_fecha TEXT, horizonte INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (ticker, intervalo, fecha, feature_version),
    FOREIGN KEY (ticker, intervalo, fecha)
        REFERENCES precios(ticker, intervalo, fecha),
    CHECK(target_cls IN (0,1) OR target_cls IS NULL)
);

CREATE TABLE IF NOT EXISTS descargas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticker TEXT NOT NULL, intervalo TEXT NOT NULL,
    period_solicitado TEXT, start_solicitado TEXT,
    end_solicitado TEXT, ejecutado_utc TEXT NOT NULL,
    filas_recibidas INTEGER NOT NULL DEFAULT 0,
    filas_validas INTEGER NOT NULL DEFAULT 0,
    fecha_min TEXT, fecha_max TEXT,
    estado TEXT NOT NULL CHECK(estado IN ('ok','vacio','error')),
    mensaje TEXT, version_yfinance TEXT,
    auto_adjust INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY(ticker) REFERENCES activos(ticker)
);

CREATE INDEX IF NOT EXISTS idx_precios_fecha
    ON precios(intervalo, fecha);
CREATE INDEX IF NOT EXISTS idx_features_fecha
    ON features_ml(intervalo, fecha);
