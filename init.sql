-- FUNÇÔES --

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TABELAS --

CREATE TABLE IF NOT EXISTS client (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    name TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS auth (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    hash_password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_auth_user FOREIGN KEY (user_id) REFERENCES client (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS session (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    user_agent TEXT NOT NULL,
    ip_address TEXT NOT NULL,
    hash_refresh_token TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,  -- Tempo de expiração né xd
    revoked BOOLEAN DEFAULT FALSE,  -- Caso o servidor queira invalidar esse token

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES client (id) ON DELETE CASCADE
);

-- VIEWS --

CREATE VIEW active_session AS
SELECT user_id, user_agent, ip_address, hash_refresh_token
FROM session
WHERE revoked = FALSE
    AND expires_at > NOW();

-- TRIGGERS --

CREATE TRIGGER update_client_timestamp
BEFORE UPDATE ON client
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_auth_timestamp
BEFORE UPDATE ON auth
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_session_timestamp
BEFORE UPDATE ON session
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();