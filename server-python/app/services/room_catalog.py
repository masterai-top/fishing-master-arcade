from app.models import GameMode, RoomSummary


class RoomCatalog:
    """In-memory catalog for local development; replace with service discovery."""

    def __init__(self) -> None:
        self._rooms = [
            RoomSummary(
                room_id="classic-rookie-01",
                name="Rookie Beach",
                mode=GameMode.CLASSIC,
                online_players=0,
                capacity=100,
                min_multiplier=1,
                max_multiplier=30_000,
            ),
            RoomSummary(
                room_id="tournament-01",
                name="Daily Tournament",
                mode=GameMode.TOURNAMENT,
                online_players=0,
                capacity=200,
                min_multiplier=1,
                max_multiplier=30_000,
            ),
            RoomSummary(
                room_id="jade-undead-01",
                name="Undead Ruins",
                mode=GameMode.JADE,
                online_players=0,
                capacity=80,
                min_multiplier=5_000,
                max_multiplier=10_000,
            ),
        ]

    def list_rooms(self, mode: GameMode | None = None) -> list[RoomSummary]:
        if mode is None:
            return list(self._rooms)
        return [room for room in self._rooms if room.mode == mode]

    def first_available(self, mode: GameMode) -> RoomSummary | None:
        return next(
            (
                room
                for room in self._rooms
                if room.mode == mode
                and room.accepting_players
                and room.online_players < room.capacity
            ),
            None,
        )


room_catalog = RoomCatalog()
