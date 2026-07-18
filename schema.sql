-- =============================================================================
-- ExploraChiapas — Schema SQL completo
-- Compatible con PostgreSQL 14+
-- =============================================================================

-- ─── Tipos de usuario ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_types (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(50)   NOT NULL UNIQUE,
    description TEXT,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

INSERT INTO user_types (name, description) VALUES
  ('turista_nacional',   'Turista proveniente de México'),
  ('turista_extranjero', 'Turista internacional'),
  ('habitante_local',    'Residente de Chiapas')
ON CONFLICT (name) DO NOTHING;

-- ─── Usuarios ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id                   UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name                 VARCHAR(100)  NOT NULL,
    email                VARCHAR(255)  NOT NULL UNIQUE,
    password_hash        VARCHAR(255),              -- NULL si usa OAuth
    phone                VARCHAR(20),
    user_type_id         UUID          REFERENCES user_types(id),

    -- OAuth / Google
    provider             VARCHAR(20)   DEFAULT 'local',  -- 'local' | 'google'
    provider_id          VARCHAR(255),
    google_id            VARCHAR(255)  UNIQUE,
    email_verified       BOOLEAN       NOT NULL DEFAULT false,

    -- Onboarding
    onboarding_completed BOOLEAN       NOT NULL DEFAULT false,

    -- Foto de perfil
    avatar_url           TEXT,

    -- Timestamps
    created_at           TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ   NOT NULL DEFAULT now(),
    deleted_at           TIMESTAMPTZ                         -- soft delete
);

CREATE INDEX IF NOT EXISTS idx_users_email    ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);

-- ─── Preferencias de usuario ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_preferences (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID          NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    idioma      VARCHAR(10)   NOT NULL DEFAULT 'es',
    unidades    VARCHAR(10)   NOT NULL DEFAULT 'km',
    tema        VARCHAR(10)   NOT NULL DEFAULT 'claro',
    moneda      VARCHAR(10)   NOT NULL DEFAULT 'MXN',
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

-- ─── Intereses de usuario ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_interests (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    categoria   VARCHAR(50)   NOT NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (user_id, categoria)
);

CREATE INDEX IF NOT EXISTS idx_user_interests_user ON user_interests(user_id);

-- ─── Destinos ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS destinations (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    name             VARCHAR(200)  NOT NULL,
    description      TEXT,
    municipio        VARCHAR(100),
    estado           VARCHAR(50)   NOT NULL DEFAULT 'Chiapas',
    latitude         DECIMAL(10,7),
    longitude        DECIMAL(10,7),
    tipo             VARCHAR(30)   NOT NULL,         -- 'destino' | 'restaurante'
    categoria        VARCHAR(50),
    costo_estimado   DECIMAL(10,2),
    tiempo_horas     DECIMAL(4,1),
    nivel_afluencia  INTEGER       CHECK (nivel_afluencia BETWEEN 1 AND 10),
    image_url        TEXT,
    active           BOOLEAN       NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_destinations_municipio ON destinations(municipio);
CREATE INDEX IF NOT EXISTS idx_destinations_tipo      ON destinations(tipo);

-- ─── Eventos ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    destination_id UUID          REFERENCES destinations(id) ON DELETE SET NULL,
    title          VARCHAR(200)  NOT NULL,
    description    TEXT,
    event_date     DATE          NOT NULL,
    start_time     TIME,
    end_time       TIME,
    image_url      TEXT,
    price          DECIMAL(10,2),
    active         BOOLEAN       NOT NULL DEFAULT true,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);

-- ─── Favoritos ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS favorites (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID          NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (user_id, destination_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);

-- ─── Reseñas ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reviews (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID          NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    rating         INTEGER       NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment        TEXT,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_destination ON reviews(destination_id);

-- ─── Historial de chat ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_history (
    id          UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mensaje     TEXT          NOT NULL,
    respuesta   TEXT,
    parametros  JSONB,                          -- parametros extraídos por NLP
    itinerario  JSONB,                          -- recomendacion devuelta por ML
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_user ON chat_history(user_id);

-- ─── Privacidad de usuario ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_privacy (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id               UUID        NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    compartir_ubicacion   BOOLEAN     NOT NULL DEFAULT false,
    compartir_historial   BOOLEAN     NOT NULL DEFAULT false,
    mostrar_perfil_publico BOOLEAN    NOT NULL DEFAULT true,
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── Trigger: updated_at automático ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_destinations_updated_at
  BEFORE UPDATE ON destinations
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_reviews_updated_at
  BEFORE UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── Migración para usuarios existentes ──────────────────────────────────────
-- Crear preferencias por defecto para usuarios que ya existen
INSERT INTO user_preferences (user_id)
SELECT id FROM users
WHERE id NOT IN (SELECT user_id FROM user_preferences)
ON CONFLICT DO NOTHING;

-- Crear privacidad por defecto para usuarios que ya existen
INSERT INTO user_privacy (user_id)
SELECT id FROM users
WHERE id NOT IN (SELECT user_id FROM user_privacy)
ON CONFLICT DO NOTHING;
