CREATE DATABASE IF NOT EXISTS oceanraid CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oceanraid;

CREATE TABLE game_modes (
    mode_id VARCHAR(40) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    min_multiplier INT UNSIGNED NOT NULL,
    max_multiplier INT UNSIGNED NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT FALSE,
    config_version INT UNSIGNED NOT NULL DEFAULT 1,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (min_multiplier > 0),
    CHECK (max_multiplier >= min_multiplier)
) ENGINE=InnoDB;

CREATE TABLE game_rooms (
    room_id VARCHAR(64) PRIMARY KEY,
    mode_id VARCHAR(40) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    capacity INT UNSIGNED NOT NULL,
    status ENUM('offline', 'open', 'draining', 'maintenance') NOT NULL DEFAULT 'offline',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_room_mode FOREIGN KEY (mode_id) REFERENCES game_modes(mode_id),
    CHECK (capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE player_profiles (
    player_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    public_id CHAR(36) NOT NULL UNIQUE,
    display_name VARCHAR(80) NOT NULL,
    status ENUM('active', 'suspended', 'deleted') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE tournaments (
    tournament_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    public_id CHAR(36) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NULL,
    capacity INT UNSIGNED NOT NULL,
    status ENUM('draft', 'registration', 'running', 'completed', 'cancelled') NOT NULL,
    rules_json JSON NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (capacity > 1)
) ENGINE=InnoDB;

CREATE TABLE tournament_entries (
    tournament_id BIGINT UNSIGNED NOT NULL,
    player_id BIGINT UNSIGNED NOT NULL,
    score BIGINT NOT NULL DEFAULT 0,
    rank_position INT UNSIGNED NULL,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tournament_id, player_id),
    CONSTRAINT fk_entry_tournament FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id),
    CONSTRAINT fk_entry_player FOREIGN KEY (player_id) REFERENCES player_profiles(player_id)
) ENGINE=InnoDB;

CREATE TABLE credit_ledger (
    ledger_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    player_id BIGINT UNSIGNED NOT NULL,
    idempotency_key VARCHAR(80) NOT NULL UNIQUE,
    entry_type ENUM('grant', 'spend', 'reward', 'refund', 'adjustment') NOT NULL,
    amount BIGINT NOT NULL,
    reason_code VARCHAR(60) NOT NULL,
    reference_id VARCHAR(80) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ledger_player FOREIGN KEY (player_id) REFERENCES player_profiles(player_id),
    INDEX idx_ledger_player_time (player_id, created_at)
) ENGINE=InnoDB;

CREATE TABLE admin_audit_log (
    audit_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    actor_id VARCHAR(64) NOT NULL,
    action VARCHAR(80) NOT NULL,
    resource_type VARCHAR(60) NOT NULL,
    resource_id VARCHAR(80) NOT NULL,
    reason TEXT NOT NULL,
    before_json JSON NULL,
    after_json JSON NULL,
    source_ip VARBINARY(16) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_resource (resource_type, resource_id, created_at),
    INDEX idx_audit_actor (actor_id, created_at)
) ENGINE=InnoDB;
