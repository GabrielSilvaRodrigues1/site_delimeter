-- ============================================================================
-- SCHEMA MEETS + GAMIFICATION
-- PostgreSQL + pgcrypto
-- ============================================================================

-- ==========================================================
-- SUMMARY / ÍNDICE
-- ==========================================================
-- 0. BOOTSTRAP
--    - Extension pgcrypto
--    - Schema meets
--
-- 1. TABELAS BASE
--    1.1  Users
--    1.2  Deleted_Items (Auditoria)
--    1.3  Storages
--    1.4  Places
--    1.5  Posts
--    1.6  Meets
--    1.7  Participants
--    1.8  Connections
--    1.9  Reviews (Posts / Meets / Places)
--    1.10 Reports (Denúncias)
--    1.11 Chat (Comentários / Mensagens)
--
-- 1.12 GAMIFICAÇÃO
--      1.12.1 Vouchers (Prêmios)
--      1.12.2 Ranks (Patamares)
--      1.12.3 Gamification (Pontuação do usuário)
--      1.12.4 Notifications (Notificações automáticas)
--
-- 2. INDEXES
--    - Índices das tabelas de reviews
--    - Índices das connections
--    - Índices de gamificação
--
-- 3. FUNCTIONS (UTILITÁRIAS)
--    3.1  update_timestamp_fn() - Trigger function para updated_at
--
-- 4. TRIGGERS
--    - Triggers para auto-update de timestamps em todas as tabelas
--    - Triggers de gamificação automática
--    - Triggers de notificações automáticas
--
-- 5. FUNCTIONS (LEITURA)
--    5.1  USERS (4 funções)
--    5.2  STORAGES (3 funções)
--    5.3  PLACES (4 funções)
--    5.4  POSTS (4 funções)
--    5.5  MEETS (4 funções)
--    5.6  CONNECTIONS (5 funções)
--    5.7  RANKS (3 funções)
--    5.8  VOUCHERS (3 funções)
--    5.9  GAMIFICATION (4 funções)
--    5.10 NOTIFICATIONS (3 funções)
--
-- 6. PROCEDURES (ESCRITA)
--    6.1  USERS (3 procedures)
--    6.2  STORAGES (3 procedures)
--    6.3  PLACES (3 procedures)
--    6.4  POSTS (3 procedures)
--    6.5  MEETS (3 procedures)
--    6.6  PARTICIPANTS (3 procedures)
--    6.7  CONNECTIONS (5 procedures)
--    6.8  REVIEWS (9 procedures)
--    6.9  REPORTS (3 procedures)
--    6.10 CHAT (3 procedures)
--    6.11 RANKS (3 procedures)
--    6.12 VOUCHERS (3 procedures)
--    6.13 GAMIFICATION (4 procedures)
--    6.14 NOTIFICATIONS (5 procedures)
--    6.15 HELPER FUNCTIONS
--
-- 7. FUNCTIONS (RESTAURAÇÃO)
--    - restore_deleted_item()
--
-- ==========================================================

-- ==========================================================
-- 0. BOOTSTRAP
-- ==========================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS meets;
SET search_path TO meets, public;

-- ==========================================================
-- 1. TABELAS
-- ==========================================================

-- ----------------------------------------------------------
-- 1.1 USERS
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    nickname VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_user_status CHECK (status IN ('PUBLIC', 'PRIVATE', 'BLOCKED'))
);

-- ----------------------------------------------------------
-- 1.2 DELETED_ITEMS (AUDITORIA)
-- - deleted_by: id do usuário que executou (NULL => sistema)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS deleted_items (
    id SERIAL PRIMARY KEY,
    origin_table VARCHAR(50) NOT NULL,
    data JSONB NOT NULL,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_by INTEGER NULL,

    CONSTRAINT fk_deleted_item_user
        FOREIGN KEY (deleted_by) REFERENCES users(id)
);

-- ----------------------------------------------------------
-- 1.3 STORAGES
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS storages (
    id SERIAL PRIMARY KEY,
    src VARCHAR(255) NOT NULL,
    alt TEXT NOT NULL,
    id_user INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_storage_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- 1.4 PLACES
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS places (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    number INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL DEFAULT 'PUBLIC',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_place_type CHECK (type IN ('PUBLIC', 'PRIVATE', 'EXCLUSIVE')),

    CONSTRAINT fk_place_user
        FOREIGN KEY (id_user) REFERENCES users(id)
);

-- ----------------------------------------------------------
-- 1.5 POSTS
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    id_storage INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_post_storage
        FOREIGN KEY (id_storage) REFERENCES storages(id),

    CONSTRAINT fk_post_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- 1.6 MEETS
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS meets (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    meet_date TIMESTAMP NOT NULL,
    privacy VARCHAR(50) NOT NULL DEFAULT 'PUBLIC',
    id_place INTEGER NOT NULL,
    id_storage INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_meet_place
        FOREIGN KEY (id_place) REFERENCES places(id),

    CONSTRAINT fk_meet_storage
        FOREIGN KEY (id_storage) REFERENCES storages(id),

    CONSTRAINT fk_meet_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT chk_privacy CHECK (privacy IN ('PUBLIC', 'PRIVATE', 'FOLLOWERS_ONLY')),
    
    CONSTRAINT chk_meet_date CHECK (meet_date > CURRENT_TIMESTAMP)
);

-- ----------------------------------------------------------
-- 1.7 PARTICIPANTS
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS participants (
    id SERIAL PRIMARY KEY,
    id_meet INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_status_participant CHECK (status IN ('PENDING', 'PAID', 'CONFIRMED', 'CANCELED', 'OWNER')),

    CONSTRAINT fk_participant_meet 
        FOREIGN KEY (id_meet) REFERENCES meets(id) ON DELETE CASCADE,
    CONSTRAINT fk_participant_user 
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,
    
    UNIQUE(id_meet, id_user)
);

-- ----------------------------------------------------------
-- 1.8 CONNECTIONS
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS connections (
    id SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    id_user_target INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_connection_status
        CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'BLOCKED')),

    CONSTRAINT chk_connection_not_self
        CHECK (id_user <> id_user_target),

    CONSTRAINT fk_connection_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT fk_connection_user_target
        FOREIGN KEY (id_user_target) REFERENCES users(id) ON DELETE CASCADE,

    -- Garante 1 conexão por par de usuários (independente do status)
    UNIQUE (id_user, id_user_target)
);

-- ----------------------------------------------------------
-- 1.9 REVIEWS (POSTS / MEETS / PLACES)
-- ----------------------------------------------------------

-- 1.9.1 POSTS_REVIEWS
CREATE TABLE IF NOT EXISTS posts_reviews (
    id SERIAL PRIMARY KEY,
    id_post INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    rating SMALLINT NOT NULL,
    comment TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_posts_reviews_rating CHECK (rating BETWEEN 0 AND 5),

    CONSTRAINT fk_posts_reviews_post
        FOREIGN KEY (id_post) REFERENCES posts(id) ON DELETE CASCADE,

    CONSTRAINT fk_posts_reviews_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    UNIQUE (id_post, id_user)
);

-- 1.9.2 MEETS_REVIEWS
CREATE TABLE IF NOT EXISTS meets_reviews (
    id SERIAL PRIMARY KEY,
    id_meet INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    rating SMALLINT NOT NULL,
    comment TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_meets_reviews_rating CHECK (rating BETWEEN 0 AND 5),

    CONSTRAINT fk_meets_reviews_meet
        FOREIGN KEY (id_meet) REFERENCES meets(id) ON DELETE CASCADE,

    CONSTRAINT fk_meets_reviews_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    UNIQUE (id_meet, id_user)
);

-- 1.9.3 PLACES_REVIEWS
CREATE TABLE IF NOT EXISTS places_reviews (
    id SERIAL PRIMARY KEY,
    id_place INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    rating SMALLINT NOT NULL,
    comment TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_places_reviews_rating CHECK (rating BETWEEN 0 AND 5),

    CONSTRAINT fk_places_reviews_place
        FOREIGN KEY (id_place) REFERENCES places(id) ON DELETE CASCADE,

    CONSTRAINT fk_places_reviews_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    UNIQUE (id_place, id_user)
);

-- ----------------------------------------------------------
-- 1.10 REPORTS (Denúncias)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS reports (
    id SERIAL PRIMARY KEY,
    id_deleted_item INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    id_user INTEGER NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_report_status CHECK (status IN ('PENDING', 'REVIEWING', 'RESOLVED', 'REJECTED')),

    CONSTRAINT fk_report_deleted_item
        FOREIGN KEY (id_deleted_item) REFERENCES deleted_items(id) ON DELETE CASCADE,

    CONSTRAINT fk_report_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- 1.11 CHAT (Comentários / Mensagens)
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS chat (
    id SERIAL PRIMARY KEY,
    id_storage INTEGER NOT NULL,
    id_user INTEGER NOT NULL,
    id_chat INTEGER NULL,
    id_meet INTEGER NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_chat_storage
        FOREIGN KEY (id_storage) REFERENCES storages(id) ON DELETE CASCADE,

    CONSTRAINT fk_chat_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT fk_chat_parent_chat
        FOREIGN KEY (id_chat) REFERENCES chat(id) ON DELETE CASCADE,

    CONSTRAINT fk_chat_meet
        FOREIGN KEY (id_meet) REFERENCES meets(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- 1.12 GAMIFICAÇÃO
-- ----------------------------------------------------------

-- 1.12.1 VOUCHERS (Prêmios para ranks)
CREATE TABLE IF NOT EXISTS vouchers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    discount_percentage SMALLINT DEFAULT 0,
    expiry_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_voucher_value CHECK (value > 0),
    CONSTRAINT chk_discount_range CHECK (discount_percentage BETWEEN 0 AND 100)
);

-- 1.12.2 RANKS (Patamares de gamificação)
CREATE TABLE IF NOT EXISTS ranks (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    refresh_at VARCHAR(20) NOT NULL DEFAULT 'MONDAY',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    members_limit INT DEFAULT 15,
    id_voucher INT,

    CONSTRAINT chk_refresh_day CHECK (
        refresh_at IN (
            'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
            'FRIDAY', 'SATURDAY', 'SUNDAY'
        )
    ),

    CONSTRAINT fk_rank_voucher
        FOREIGN KEY (id_voucher) REFERENCES vouchers(id) ON DELETE SET NULL
);

-- 1.12.3 GAMIFICATION (Dados de pontuação do usuário)
CREATE TABLE IF NOT EXISTS gamification (
    id SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    score INTEGER DEFAULT 0,
    score_rank INTEGER DEFAULT 0,
    id_rank INTEGER,
    rank_refresh_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_gamification_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE,

    CONSTRAINT fk_gamification_rank
        FOREIGN KEY (id_rank) REFERENCES ranks(id) ON DELETE SET NULL,

    UNIQUE(id_user)
);

-- 1.12.4 NOTIFICATIONS (Notificações automáticas do sistema)
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    id_user INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_notification_type CHECK (
        type IN (
            'REVIEW',
            'MEET',
            'POST',
            'PARTICIPANTS',
            'CONNECTIONS',
            'GAMIFICATION',
            'RANK_CHANGE'
        )
    ),

    CONSTRAINT fk_notification_user
        FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE
);

-- ==========================================================
-- 2. INDEXES
-- ==========================================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Storages indexes
CREATE INDEX IF NOT EXISTS idx_storages_user ON storages(id_user);
CREATE INDEX IF NOT EXISTS idx_storages_created ON storages(created_at);

-- Places indexes
CREATE INDEX IF NOT EXISTS idx_places_user ON places(id_user);
CREATE INDEX IF NOT EXISTS idx_places_name ON places(name);
CREATE INDEX IF NOT EXISTS idx_places_type ON places(type);

-- Posts indexes
CREATE INDEX IF NOT EXISTS idx_posts_user ON posts(id_user);
CREATE INDEX IF NOT EXISTS idx_posts_storage ON posts(id_storage);
CREATE INDEX IF NOT EXISTS idx_posts_title ON posts(title);
CREATE INDEX IF NOT EXISTS idx_posts_created ON posts(created_at);

-- Meets indexes
CREATE INDEX IF NOT EXISTS idx_meets_user ON meets(id_user);
CREATE INDEX IF NOT EXISTS idx_meets_place ON meets(id_place);
CREATE INDEX IF NOT EXISTS idx_meets_storage ON meets(id_storage);
CREATE INDEX IF NOT EXISTS idx_meets_date ON meets(meet_date);
CREATE INDEX IF NOT EXISTS idx_meets_privacy ON meets(privacy);

-- Participants indexes
CREATE INDEX IF NOT EXISTS idx_participants_meet ON participants(id_meet);
CREATE INDEX IF NOT EXISTS idx_participants_user ON participants(id_user);
CREATE INDEX IF NOT EXISTS idx_participants_status ON participants(status);

-- Reviews indexes
CREATE INDEX IF NOT EXISTS idx_posts_reviews_post ON posts_reviews(id_post);
CREATE INDEX IF NOT EXISTS idx_posts_reviews_user ON posts_reviews(id_user);
CREATE INDEX IF NOT EXISTS idx_posts_reviews_rating ON posts_reviews(rating);

CREATE INDEX IF NOT EXISTS idx_meets_reviews_meet ON meets_reviews(id_meet);
CREATE INDEX IF NOT EXISTS idx_meets_reviews_user ON meets_reviews(id_user);
CREATE INDEX IF NOT EXISTS idx_meets_reviews_rating ON meets_reviews(rating);

CREATE INDEX IF NOT EXISTS idx_places_reviews_place ON places_reviews(id_place);
CREATE INDEX IF NOT EXISTS idx_places_reviews_user ON places_reviews(id_user);
CREATE INDEX IF NOT EXISTS idx_places_reviews_rating ON places_reviews(rating);

-- Connections indexes
CREATE INDEX IF NOT EXISTS idx_connections_user ON connections(id_user);
CREATE INDEX IF NOT EXISTS idx_connections_user_target ON connections(id_user_target);
CREATE INDEX IF NOT EXISTS idx_connections_status ON connections(status);

-- Reports indexes
CREATE INDEX IF NOT EXISTS idx_reports_deleted_item ON reports(id_deleted_item);
CREATE INDEX IF NOT EXISTS idx_reports_user ON reports(id_user);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);

-- Chat indexes
CREATE INDEX IF NOT EXISTS idx_chat_storage ON chat(id_storage);
CREATE INDEX IF NOT EXISTS idx_chat_user ON chat(id_user);
CREATE INDEX IF NOT EXISTS idx_chat_parent ON chat(id_chat);
CREATE INDEX IF NOT EXISTS idx_chat_meet ON chat(id_meet);

-- Gamification indexes
CREATE INDEX IF NOT EXISTS idx_gamification_user ON gamification(id_user);
CREATE INDEX IF NOT EXISTS idx_gamification_rank ON gamification(id_rank);
CREATE INDEX IF NOT EXISTS idx_gamification_score ON gamification(score);
CREATE INDEX IF NOT EXISTS idx_gamification_rank_refresh ON gamification(rank_refresh_date);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(id_user);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at);

CREATE INDEX IF NOT EXISTS idx_vouchers_code ON vouchers(code);
CREATE INDEX IF NOT EXISTS idx_vouchers_expiry ON vouchers(expiry_date);

CREATE INDEX IF NOT EXISTS idx_ranks_name ON ranks(name);
CREATE INDEX IF NOT EXISTS idx_ranks_refresh ON ranks(refresh_at);

-- ==========================================================
-- 3. FUNCTIONS (UTILITÁRIAS)
-- ==========================================================

-- ----------------------------------------------------------
-- 3.1 Trigger function: updated_at
-- ----------------------------------------------------------
CREATE OR REPLACE FUNCTION update_timestamp_fn()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================================
-- 4. TRIGGERS
-- ==========================================================

-- Update timestamps
CREATE OR REPLACE TRIGGER trg_users_update
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_storages_update
BEFORE UPDATE ON storages
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_places_update
BEFORE UPDATE ON places
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_posts_update
BEFORE UPDATE ON posts
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_meets_update
BEFORE UPDATE ON meets
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_participants_update
BEFORE UPDATE ON participants
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_connections_update
BEFORE UPDATE ON connections
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_posts_reviews_update
BEFORE UPDATE ON posts_reviews
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_meets_reviews_update
BEFORE UPDATE ON meets_reviews
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_places_reviews_update
BEFORE UPDATE ON places_reviews
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_reports_update
BEFORE UPDATE ON reports
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_chat_update
BEFORE UPDATE ON chat
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_gamification_update
BEFORE UPDATE ON gamification
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_vouchers_update
BEFORE UPDATE ON vouchers
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

CREATE OR REPLACE TRIGGER trg_ranks_update
BEFORE UPDATE ON ranks
FOR EACH ROW EXECUTE FUNCTION update_timestamp_fn();

-- ==========================================================
-- 5. FUNCTIONS (LEITURA)
-- ==========================================================

-- ----------------------------------------------------------
-- 5.1 USERS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_users()
RETURNS TABLE (
    id INT,
    name VARCHAR,
    nickname VARCHAR,
    email VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.nickname, u.email, u.created_at, u.updated_at
    FROM users u
    ORDER BY u.name ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_user_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    nickname VARCHAR,
    email VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.nickname, u.email, u.created_at, u.updated_at
    FROM users u
    WHERE u.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_user(p_identifier VARCHAR)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    nickname VARCHAR,
    email VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.nickname, u.email, u.created_at, u.updated_at
    FROM users u
    WHERE u.nickname = p_identifier OR u.email = p_identifier;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION login_user(
    p_identifier VARCHAR,
    p_password_peppered TEXT
)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    nickname VARCHAR,
    email VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.nickname, u.email
    FROM users u
    WHERE (u.nickname = p_identifier OR u.email = p_identifier)
      AND u.password = crypt(p_password_peppered, u.password);
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.2 STORAGES (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_storages()
RETURNS TABLE (
    id INT,
    src VARCHAR,
    alt TEXT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.src, s.alt, s.id_user, s.created_at, s.updated_at
    FROM storages s
    ORDER BY s.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_storage_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    src VARCHAR,
    alt TEXT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.src, s.alt, s.id_user, s.created_at, s.updated_at
    FROM storages s
    WHERE s.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_storage_by_user_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    src VARCHAR,
    alt TEXT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.src, s.alt, s.id_user, s.created_at, s.updated_at
    FROM storages s
    WHERE s.id_user = p_user_id
    ORDER BY s.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.3 PLACES (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_places()
RETURNS TABLE (
    id INT,
    name VARCHAR,
    postal_code VARCHAR,
    number INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT pl.id, pl.name, pl.postal_code, pl.number, pl.id_user, pl.created_at, pl.updated_at
    FROM places pl
    ORDER BY pl.name ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_place_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    postal_code VARCHAR,
    number INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT pl.id, pl.name, pl.postal_code, pl.number, pl.id_user, pl.created_at, pl.updated_at
    FROM places pl
    WHERE pl.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_place_by_user_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    postal_code VARCHAR,
    number INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT pl.id, pl.name, pl.postal_code, pl.number, pl.id_user, pl.created_at, pl.updated_at
    FROM places pl
    WHERE pl.id_user = p_user_id
    ORDER BY pl.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_place_by_name(p_search VARCHAR)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    postal_code VARCHAR,
    number INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT pl.id, pl.name, pl.postal_code, pl.number, pl.id_user, pl.created_at, pl.updated_at
    FROM places pl
    WHERE pl.name ILIKE '%' || p_search || '%'
    ORDER BY pl.name ASC;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.4 POSTS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_posts()
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.title, p.description, p.id_storage, p.id_user, p.created_at, p.updated_at
    FROM posts p
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_post_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.title, p.description, p.id_storage, p.id_user, p.created_at, p.updated_at
    FROM posts p
    WHERE p.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_post_by_user_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.title, p.description, p.id_storage, p.id_user, p.created_at, p.updated_at
    FROM posts p
    WHERE p.id_user = p_user_id
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_post_by_title(p_search VARCHAR)
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.title, p.description, p.id_storage, p.id_user, p.created_at, p.updated_at
    FROM posts p
    WHERE p.title ILIKE '%' || p_search || '%'
    ORDER BY p.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.5 MEETS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_meets()
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_place INT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id, m.title, m.description, m.id_place, m.id_storage, m.id_user, m.created_at, m.updated_at
    FROM meets m
    ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_meet_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_place INT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id, m.title, m.description, m.id_place, m.id_storage, m.id_user, m.created_at, m.updated_at
    FROM meets m
    WHERE m.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_meet_by_user_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_place INT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id, m.title, m.description, m.id_place, m.id_storage, m.id_user, m.created_at, m.updated_at
    FROM meets m
    WHERE m.id_user = p_user_id
    ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_meet_by_title(p_search VARCHAR)
RETURNS TABLE (
    id INT,
    title VARCHAR,
    description TEXT,
    id_place INT,
    id_storage INT,
    id_user INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT m.id, m.title, m.description, m.id_place, m.id_storage, m.id_user, m.created_at, m.updated_at
    FROM meets m
    WHERE m.title ILIKE '%' || p_search || '%'
    ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.6 CONNECTIONS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_connections()
RETURNS TABLE (
    id INT,
    id_user INT,
    id_user_target INT,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.id_user, c.id_user_target, c.status, c.created_at, c.updated_at
    FROM connections c
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_connection_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    id_user INT,
    id_user_target INT,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.id_user, c.id_user_target, c.status, c.created_at, c.updated_at
    FROM connections c
    WHERE c.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_connection_by_user_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    id_user INT,
    id_user_target INT,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.id_user, c.id_user_target, c.status, c.created_at, c.updated_at
    FROM connections c
    WHERE c.id_user = p_user_id
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_connection_by_target_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    id_user INT,
    id_user_target INT,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.id_user, c.id_user_target, c.status, c.created_at, c.updated_at
    FROM connections c
    WHERE c.id_user_target = p_user_id
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_connection_by_status(p_status VARCHAR)
RETURNS TABLE (
    id INT,
    id_user INT,
    id_user_target INT,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.id_user, c.id_user_target, c.status, c.created_at, c.updated_at
    FROM connections c
    WHERE c.status = p_status
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.7 RANKS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_ranks()
RETURNS TABLE (
    id INT,
    name VARCHAR,
    refresh_at VARCHAR,
    members_limit INT,
    id_voucher INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name, r.refresh_at, r.members_limit, r.id_voucher, r.created_at, r.updated_at
    FROM ranks r
    ORDER BY r.name ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_rank_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    name VARCHAR,
    refresh_at VARCHAR,
    members_limit INT,
    id_voucher INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name, r.refresh_at, r.members_limit, r.id_voucher, r.created_at, r.updated_at
    FROM ranks r
    WHERE r.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_rank_with_members(p_rank_id INT)
RETURNS TABLE (
    rank_id INT,
    rank_name VARCHAR,
    member_count INT,
    members_limit INT,
    refresh_at VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.name,
        COUNT(g.id)::INT,
        r.members_limit,
        r.refresh_at
    FROM ranks r
    LEFT JOIN gamification g ON r.id = g.id_rank
    WHERE r.id = p_rank_id
    GROUP BY r.id, r.name, r.members_limit, r.refresh_at;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.8 VOUCHERS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_vouchers()
RETURNS TABLE (
    id INT,
    code VARCHAR,
    description TEXT,
    value DECIMAL,
    discount_percentage SMALLINT,
    expiry_date TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.id, v.code, v.description, v.value, v.discount_percentage, v.expiry_date, v.created_at, v.updated_at
    FROM vouchers v
    ORDER BY v.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_voucher_by_id(p_id INT)
RETURNS TABLE (
    id INT,
    code VARCHAR,
    description TEXT,
    value DECIMAL,
    discount_percentage SMALLINT,
    expiry_date TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.id, v.code, v.description, v.value, v.discount_percentage, v.expiry_date, v.created_at, v.updated_at
    FROM vouchers v
    WHERE v.id = p_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_voucher_by_code(p_code VARCHAR)
RETURNS TABLE (
    id INT,
    code VARCHAR,
    description TEXT,
    value DECIMAL,
    discount_percentage SMALLINT,
    expiry_date TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT v.id, v.code, v.description, v.value, v.discount_percentage, v.expiry_date, v.created_at, v.updated_at
    FROM vouchers v
    WHERE v.code = p_code
      AND (v.expiry_date IS NULL OR v.expiry_date > CURRENT_TIMESTAMP);
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.9 GAMIFICATION (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION all_gamification()
RETURNS TABLE (
    id INT,
    id_user INT,
    score INT,
    score_rank INT,
    id_rank INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT g.id, g.id_user, g.score, g.score_rank, g.id_rank, g.created_at, g.updated_at
    FROM gamification g
    ORDER BY g.score DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_gamification_by_user_id(p_user_id INT)
RETURNS TABLE (
    id INT,
    id_user INT,
    score INT,
    score_rank INT,
    rank_name VARCHAR,
    id_rank INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        g.id,
        g.id_user,
        g.score,
        g.score_rank,
        r.name,
        g.id_rank,
        g.created_at,
        g.updated_at
    FROM gamification g
    LEFT JOIN ranks r ON g.id_rank = r.id
    WHERE g.id_user = p_user_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION global_ranking(p_limit INT DEFAULT 10)
RETURNS TABLE (
    position INT,
    id_user INT,
    nickname VARCHAR,
    score INT,
    rank_name VARCHAR,
    score_rank INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROW_NUMBER() OVER (ORDER BY g.score DESC)::INT,
        g.id_user,
        u.nickname,
        g.score,
        r.name,
        g.score_rank
    FROM gamification g
    INNER JOIN users u ON g.id_user = u.id
    LEFT JOIN ranks r ON g.id_rank = r.id
    ORDER BY g.score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ranking_by_rank(p_rank_id INT)
RETURNS TABLE (
    position INT,
    id_user INT,
    nickname VARCHAR,
    score_rank INT,
    score INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ROW_NUMBER() OVER (ORDER BY g.score_rank DESC)::INT,
        g.id_user,
        u.nickname,
        g.score_rank,
        g.score
    FROM gamification g
    INNER JOIN users u ON g.id_user = u.id
    WHERE g.id_rank = p_rank_id
    ORDER BY g.score_rank DESC;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------
-- 5.10 NOTIFICATIONS (leitura)
-- ----------------------------------------------------------

CREATE OR REPLACE FUNCTION search_notifications_by_user(p_user_id INT)
RETURNS TABLE (
    id INT,
    type VARCHAR,
    description TEXT,
    read BOOLEAN,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT n.id, n.type, n.description, n.read, n.created_at
    FROM notifications n
    WHERE n.id_user = p_user_id
    ORDER BY n.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION search_unread_notifications(p_user_id INT)
RETURNS TABLE (
    id INT,
    type VARCHAR,
    description TEXT,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT n.id, n.type, n.description, n.created_at
    FROM notifications n
    WHERE n.id_user = p_user_id
      AND n.read = FALSE
    ORDER BY n.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_unread_notifications(p_user_id INT)
RETURNS TABLE (
    unread_count INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*)::INT
    FROM notifications
    WHERE id_user = p_user_id AND read = FALSE;
END;
$$ LANGUAGE plpgsql;

-- ==========================================================
-- 6. PROCEDURES (ESCRITA)
-- ==========================================================

-- ----------------------------------------------------------
-- 6.1 USERS (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE logup_user(
    p_name VARCHAR,
    p_nickname VARCHAR,
    p_email VARCHAR,
    p_password_peppered TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO users (name, nickname, email, password)
    VALUES (
        p_name,
        p_nickname,
        p_email,
        crypt(p_password_peppered, gen_salt('bf'))
    );
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'E-mail ou Nickname já cadastrado no sistema.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_user(
    p_id INT,
    p_name VARCHAR,
    p_nickname VARCHAR,
    p_password_peppered TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE users
    SET name = p_name,
        nickname = p_nickname,
        password = crypt(p_password_peppered, gen_salt('bf'))
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Usuário não encontrado.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_user(
    p_user_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'users',
        jsonb_build_object('id', id, 'nickname', nickname, 'status', 'SELF_DELETED'),
        p_deleted_by
    FROM users
    WHERE id = p_user_id;

    DELETE FROM users WHERE id = p_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conta não encontrada.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.2 STORAGES (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_storage(
    p_src VARCHAR,
    p_alt TEXT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO storages (src, alt, id_user)
    VALUES (p_src, p_alt, p_id_user);
END;
$$;

CREATE OR REPLACE PROCEDURE update_storage(
    p_id INT,
    p_src VARCHAR,
    p_alt TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE storages
    SET src = p_src,
        alt = p_alt
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Arquivo não encontrado no storage.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_storage(
    p_storage_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'storages',
        jsonb_build_object('id', id, 'src', src),
        p_deleted_by
    FROM storages
    WHERE id = p_storage_id;

    DELETE FROM storages WHERE id = p_storage_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Arquivo não encontrado para exclusão.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.3 PLACES (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_place(
    p_name VARCHAR,
    p_postal_code VARCHAR,
    p_number INT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO places (name, postal_code, number, id_user)
    VALUES (p_name, p_postal_code, p_number, p_id_user);
END;
$$;

CREATE OR REPLACE PROCEDURE update_place(
    p_id INT,
    p_name VARCHAR,
    p_postal_code VARCHAR,
    p_number INT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE places
    SET name = p_name,
        postal_code = p_postal_code,
        number = p_number
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lugar não encontrado para atualização.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_place(
    p_place_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'places',
        jsonb_build_object('id', id, 'name', name),
        p_deleted_by
    FROM places
    WHERE id = p_place_id;

    DELETE FROM places WHERE id = p_place_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lugar não encontrado para exclusão.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.4 POSTS (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_post(
    p_title VARCHAR,
    p_description TEXT,
    p_id_storage INT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO posts (title, description, id_storage, id_user)
    VALUES (p_title, p_description, p_id_storage, p_id_user);
END;
$$;

CREATE OR REPLACE PROCEDURE update_post(
    p_id INT,
    p_title VARCHAR,
    p_description TEXT,
    p_id_storage INT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE posts
    SET title = p_title,
        description = p_description,
        id_storage = p_id_storage
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Post não encontrado.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_post(
    p_post_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'posts',
        jsonb_build_object('id', id, 'title', title),
        p_deleted_by
    FROM posts
    WHERE id = p_post_id;

    DELETE FROM posts WHERE id = p_post_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Post não encontrado.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.5 MEETS (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_meet(
    p_title VARCHAR,
    p_description TEXT,
    p_id_place INT,
    p_id_storage INT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_meet_id INT;
BEGIN
    INSERT INTO meets (title, description, id_place, id_storage, id_user)
    VALUES (p_title, p_description, p_id_place, p_id_storage, p_id_user)
    RETURNING id INTO v_meet_id;

    INSERT INTO participants (id_meet, id_user, status)
    VALUES (v_meet_id, p_id_user, 'OWNER');

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Participante OWNER já existe para este meet/usuário.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_meet(
    p_id INT,
    p_title VARCHAR,
    p_description TEXT,
    p_id_place INT,
    p_id_storage INT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE meets
    SET title = p_title,
        description = p_description,
        id_place = p_id_place,
        id_storage = p_id_storage
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Meet não encontrado para atualização.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_meet(
    p_meet_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'meets',
        jsonb_build_object('id', id, 'title', title),
        p_deleted_by
    FROM meets
    WHERE id = p_meet_id;

    DELETE FROM meets WHERE id = p_meet_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Meet não encontrado para exclusão.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.6 PARTICIPANTS (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_participant(
    p_id_meet INT,
    p_id_user INT,
    p_status VARCHAR DEFAULT 'PENDING'
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO participants (id_meet, id_user, status)
    VALUES (p_id_meet, p_id_user, p_status);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Usuário já é participante deste meet.';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Meet ou usuário não encontrado.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_participant(
    p_id INT,
    p_status VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE participants
    SET status = p_status
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Participante não encontrado.';
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_participant(
    p_id INT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM participants
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Participante não encontrado.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.7 CONNECTIONS (escrita)
-- ----------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_connection(
    p_id_user INT,
    p_id_user_target INT,
    p_status VARCHAR DEFAULT 'PENDING'
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_id_user = p_id_user_target THEN
        RAISE EXCEPTION 'Um usuário não pode se conectar consigo mesmo.';
    END IF;

    IF p_status NOT IN ('PENDING', 'ACCEPTED', 'REJECTED', 'BLOCKED') THEN
        RAISE EXCEPTION 'Status de conexão inválido. Valores permitidos: PENDING, ACCEPTED, REJECTED, BLOCKED.';
    END IF;

    INSERT INTO connections (id_user, id_user_target, status)
    VALUES (p_id_user, p_id_user_target, p_status);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Já existe uma conexão entre estes dois usuários.';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Um ou ambos os usuários não foram encontrados.';
    WHEN check_violation THEN
        RAISE EXCEPTION 'Violação de restrição: um usuário n��o pode se conectar consigo mesmo.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_connection(
    p_id INT,
    p_status VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_status NOT IN ('PENDING', 'ACCEPTED', 'REJECTED', 'BLOCKED') THEN
        RAISE EXCEPTION 'Status de conexão inválido. Valores permitidos: PENDING, ACCEPTED, REJECTED, BLOCKED.';
    END IF;

    UPDATE connections
    SET status = p_status
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conexão não encontrada.';
    END IF;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Status inválido para a conexão.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_connection_by_users(
    p_id_user INT,
    p_id_user_target INT,
    p_status VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_status NOT IN ('PENDING', 'ACCEPTED', 'REJECTED', 'BLOCKED') THEN
        RAISE EXCEPTION 'Status de conexão inválido. Valores permitidos: PENDING, ACCEPTED, REJECTED, BLOCKED.';
    END IF;

    UPDATE connections
    SET status = p_status
    WHERE (id_user = p_id_user AND id_user_target = p_id_user_target)
       OR (id_user = p_id_user_target AND id_user_target = p_id_user);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conexão não encontrada entre os usuários informados.';
    END IF;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'Status inválido para a conexão.';
END;
$$;

CREATE OR REPLACE PROCEDURE delete_connection(
    p_connection_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'connections',
        jsonb_build_object(
            'id', id,
            'id_user', id_user,
            'id_user_target', id_user_target,
            'status', status
        ),
        p_deleted_by
    FROM connections
    WHERE id = p_connection_id;

    DELETE FROM connections WHERE id = p_connection_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conexão não encontrada para exclusão.';
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Erro ao deletar conexão: referência de chave estrangeira.';
END;
$$;

CREATE OR REPLACE PROCEDURE delete_connection_by_users(
    p_id_user INT,
    p_id_user_target INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'connections',
        jsonb_build_object(
            'id', id,
            'id_user', id_user,
            'id_user_target', id_user_target,
            'status', status
        ),
        p_deleted_by
    FROM connections
    WHERE (id_user = p_id_user AND id_user_target = p_id_user_target)
       OR (id_user = p_id_user_target AND id_user_target = p_id_user);

    DELETE FROM connections
    WHERE (id_user = p_id_user AND id_user_target = p_id_user_target)
       OR (id_user = p_id_user_target AND id_user_target = p_id_user);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conexão não encontrada entre os usuários informados.';
    END IF;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Erro ao deletar conexão: referência de chave estrangeira.';
END;
$$;

-- ----------------------------------------------------------
-- 6.8 REVIEWS (escrita)
-- ----------------------------------------------------------

-- 6.8.1 POSTS_REVIEWS (create / update / delete)

CREATE OR REPLACE PROCEDURE create_post_review(
    p_id_post INT,
    p_id_user INT,
    p_rating SMALLINT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO posts_reviews (id_post, id_user, rating, comment)
    VALUES (p_id_post, p_id_user, p_rating, p_comment);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Você já avaliou este post.';
    WHEN check_violation THEN
        RAISE EXCEPTION 'A avaliação precisa estar entre 0 e 5.';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Post ou usuário não encontrado.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_post_review(
    p_id INT,
    p_id_user INT,
    p_rating SMALLINT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE posts_reviews
    SET rating = p_rating,
        comment = p_comment
    WHERE id = p_id
      AND id_user = p_id_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review não encontrada (ou você não tem permissão para editar).';
    END IF;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'A avaliação precisa estar entre 0 e 5.';
END;
$$;

CREATE OR REPLACE PROCEDURE delete_post_review(
    p_id INT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM posts_reviews
    WHERE id = p_id
      AND id_user = p_id_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review não encontrada (ou você não tem permissão para excluir).';
    END IF;
END;
$$;

-- 6.8.2 MEETS_REVIEWS (create / update / delete)

CREATE OR REPLACE PROCEDURE create_meet_review(
    p_id_meet INT,
    p_id_user INT,
    p_rating SMALLINT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO meets_reviews (id_meet, id_user, rating, comment)
    VALUES (p_id_meet, p_id_user, p_rating, p_comment);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Você já avaliou este meet.';
    WHEN check_violation THEN
        RAISE EXCEPTION 'A avaliação precisa estar entre 0 e 5.';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Meet ou usuário não encontrado.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_meet_review(
    p_id INT,
    p_id_user INT,
    p_rating SMALLINT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE meets_reviews
    SET rating = p_rating,
        comment = p_comment
    WHERE id = p_id
      AND id_user = p_id_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review não encontrada (ou você não tem permissão para editar).';
    END IF;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'A avaliação precisa estar entre 0 e 5.';
END;
$$;

CREATE OR REPLACE PROCEDURE delete_meet_review(
    p_id INT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM meets_reviews
    WHERE id = p_id
      AND id_user = p_id_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review não encontrada (ou você não tem permissão para excluir).';
    END IF;
END;
$$;

-- 6.8.3 PLACES_REVIEWS (create / update / delete)

CREATE OR REPLACE PROCEDURE create_place_review(
    p_id_place INT,
    p_id_user INT,
    p_rating SMALLINT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO places_reviews (id_place, id_user, rating, comment)
    VALUES (p_id_place, p_id_user, p_rating, p_comment);

EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Você já avaliou este lugar.';
    WHEN check_violation THEN
        RAISE EXCEPTION 'A avaliação precisa estar entre 0 e 5.';
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Lugar ou usuário não encontrado.';
END;
$$;

CREATE OR REPLACE PROCEDURE update_place_review(
    p_id INT,
    p_id_user INT,
    p_rating SMALLINT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE places_reviews
    SET rating = p_rating,
        comment = p_comment
    WHERE id = p_id
      AND id_user = p_id_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review não encontrada (ou você não tem permissão para editar).';
    END IF;

EXCEPTION
    WHEN check_violation THEN
        RAISE EXCEPTION 'A avaliação precisa estar entre 0 e 5.';
END;
$$;

CREATE OR REPLACE PROCEDURE delete_place_review(
    p_id INT,
    p_id_user INT
)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM places_reviews
    WHERE id = p_id
      AND id_user = p_id_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Review não encontrada (ou você não tem permissão para excluir).';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.9 REPORTS (escrita)
-- ----------------------------------------------------------

-- Criar denúncia
CREATE OR REPLACE PROCEDURE create_report(
    p_id_deleted_item INT,
    p_id_user INT,
    p_reason TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO reports (id_deleted_item, id_user, reason)
    VALUES (p_id_deleted_item, p_id_user, p_reason);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Item deletado ou usuário não encontrado.';
END;
$$;

-- Atualizar status da denúncia
CREATE OR REPLACE PROCEDURE update_report(
    p_id INT,
    p_status VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_status NOT IN ('PENDING', 'REVIEWING', 'RESOLVED', 'REJECTED') THEN
        RAISE EXCEPTION 'Status inválido. Valores permitidos: PENDING, REVIEWING, RESOLVED, REJECTED.';
    END IF;

    UPDATE reports
    SET status = p_status
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Denúncia não encontrada.';
    END IF;
END;
$$;

-- Deletar denúncia
CREATE OR REPLACE PROCEDURE delete_report(
    p_report_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'reports',
        jsonb_build_object('id', id, 'id_deleted_item', id_deleted_item),
        p_deleted_by
    FROM reports
    WHERE id = p_report_id;

    DELETE FROM reports WHERE id = p_report_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Denúncia não encontrada.';
    END IF;
END;
$$;

-- ----------------------------------------------------------
-- 6.10 CHAT (escrita)
-- ----------------------------------------------------------

-- Criar comentário/mensagem
CREATE OR REPLACE PROCEDURE create_chat(
    p_id_storage INT,
    p_id_user INT,
    p_id_meet INT,
    p_comment TEXT,
    p_id_chat INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO chat (id_storage, id_user, id_meet, comment, id_chat)
    VALUES (p_id_storage, p_id_user, p_id_meet, p_comment, p_id_chat);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'Storage, usuário, meet ou comentário pai não encontrado.';
END;
$$;

-- Atualizar comentário
CREATE OR REPLACE PROCEDURE update_chat(
    p_id INT,
    p_comment TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE chat
    SET comment = p_comment
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Comentário não encontrado.';
    END IF;
END;
$$;

-- Deletar comentário
CREATE OR REPLACE PROCEDURE delete_chat(
    p_chat_id INT,
    p_deleted_by INT DEFAULT NULL
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO deleted_items (origin_table, data, deleted_by)
    SELECT
        'chat',
        jsonb_build_object('id', id, 'id_meet', id_meet, 'comment', comment),
        p_deleted_by
    FROM chat
    WHERE id = p_chat_id;

    DELETE FROM chat WHERE id = p_chat_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Comentário não encontrado.';
    END IF;
END;
$$;

-- ==========================================================
-- 7. FUNCTIONS (RESTAURAÇÃO)
-- ==========================================================

-- Restaurar item deletado (volta o item para a tabela original)
CREATE OR REPLACE FUNCTION restore_deleted_item(
    p_deleted_item_id INT,
    p_restored_by INT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    origin_table VARCHAR,
    restored_id INT
) AS $$
DECLARE
    v_origin_table VARCHAR;
    v_data JSONB;
    v_restored_id INT;
BEGIN
    -- Buscar o item deletado
    SELECT origin_table, data INTO v_origin_table, v_data
    FROM deleted_items
    WHERE id = p_deleted_item_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Item deletado não encontrado.'::TEXT, NULL, NULL;
        RETURN;
    END IF;

    -- Restaurar baseado na tabela de origem
    BEGIN
        CASE v_origin_table
            -- Restaurar USERS
            WHEN 'users' THEN
                INSERT INTO users (id, name, nickname, email, password, status, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    v_data->>'name',
                    v_data->>'nickname',
                    v_data->>'email',
                    v_data->>'password',
                    COALESCE(v_data->>'status', 'PUBLIC'),
                    NOW(),
                    NOW()
                )
                RETURNING users.id INTO v_restored_id;

            -- Restaurar STORAGES
            WHEN 'storages' THEN
                INSERT INTO storages (id, src, alt, id_user, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    v_data->>'src',
                    v_data->>'alt',
                    (v_data->>'id_user')::INT,
                    NOW(),
                    NOW()
                )
                RETURNING storages.id INTO v_restored_id;

            -- Restaurar PLACES
            WHEN 'places' THEN
                INSERT INTO places (id, name, postal_code, number, id_user, type, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    v_data->>'name',
                    v_data->>'postal_code',
                    (v_data->>'number')::INT,
                    (v_data->>'id_user')::INT,
                    COALESCE(v_data->>'type', 'PUBLIC'),
                    NOW(),
                    NOW()
                )
                RETURNING places.id INTO v_restored_id;

            -- Restaurar POSTS
            WHEN 'posts' THEN
                INSERT INTO posts (id, title, description, id_storage, id_user, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    v_data->>'title',
                    v_data->>'description',
                    (v_data->>'id_storage')::INT,
                    (v_data->>'id_user')::INT,
                    NOW(),
                    NOW()
                )
                RETURNING posts.id INTO v_restored_id;

            -- Restaurar MEETS
            WHEN 'meets' THEN
                INSERT INTO meets (id, title, description, privacy, id_place, id_storage, id_user, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    v_data->>'title',
                    v_data->>'description',
                    COALESCE(v_data->>'privacy', 'PUBLIC'),
                    (v_data->>'id_place')::INT,
                    (v_data->>'id_storage')::INT,
                    (v_data->>'id_user')::INT,
                    NOW(),
                    NOW()
                )
                RETURNING meets.id INTO v_restored_id;

            -- Restaurar CONNECTIONS
            WHEN 'connections' THEN
                INSERT INTO connections (id, id_user, id_user_target, status, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    (v_data->>'id_user')::INT,
                    (v_data->>'id_user_target')::INT,
                    v_data->>'status',
                    NOW(),
                    NOW()
                )
                RETURNING connections.id INTO v_restored_id;

            -- Restaurar CHAT
            WHEN 'chat' THEN
                INSERT INTO chat (id, id_storage, id_user, id_meet, comment, id_chat, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    (v_data->>'id_storage')::INT,
                    (v_data->>'id_user')::INT,
                    (v_data->>'id_meet')::INT,
                    v_data->>'comment',
                    (v_data->>'id_chat')::INT,
                    NOW(),
                    NOW()
                )
                RETURNING chat.id INTO v_restored_id;

            -- Restaurar REPORTS
            WHEN 'reports' THEN
                INSERT INTO reports (id, id_deleted_item, id_user, reason, status, created_at, updated_at)
                VALUES (
                    (v_data->>'id')::INT,
                    (v_data->>'id_deleted_item')::INT,
                    (v_data->>'id_user')::INT,
                    v_data->>'reason',
                    COALESCE(v_data->>'status', 'PENDING'),
                    NOW(),
                    NOW()
                )
                RETURNING reports.id INTO v_restored_id;

            ELSE
                RETURN QUERY SELECT FALSE, 'Tipo de tabela desconhecida: ' || v_origin_table, v_origin_table, NULL;
                RETURN;
        END CASE;

        -- Deletar do histórico após restauração bem-sucedida
        DELETE FROM deleted_items WHERE id = p_deleted_item_id;

        RETURN QUERY SELECT TRUE, 'Item restaurado com sucesso.', v_origin_table, v_restored_id;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Erro ao restaurar: ' || SQLERRM, v_origin_table, NULL;
    END;

END;
$$ LANGUAGE plpgsql;
