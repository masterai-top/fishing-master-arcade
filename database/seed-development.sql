USE oceanraid;

INSERT INTO game_modes (mode_id, display_name, min_multiplier, max_multiplier, enabled)
VALUES
    ('classic', 'Classic Mode', 1, 30000, TRUE),
    ('tournament', 'Tournament Mode', 1, 30000, TRUE),
    ('jade', 'Jade Field', 5000, 10000, FALSE),
    ('sea_demon', 'Sea Demon Assault', 1, 30000, FALSE),
    ('thrill_zone', 'Thrill Zone', 1, 10000, FALSE)
ON DUPLICATE KEY UPDATE display_name = VALUES(display_name);

INSERT INTO game_rooms (room_id, mode_id, display_name, capacity, status)
VALUES
    ('classic-rookie-01', 'classic', 'Rookie Beach', 100, 'open'),
    ('tournament-01', 'tournament', 'Daily Tournament', 200, 'open'),
    ('jade-undead-01', 'jade', 'Undead Ruins', 80, 'offline')
ON DUPLICATE KEY UPDATE display_name = VALUES(display_name);
