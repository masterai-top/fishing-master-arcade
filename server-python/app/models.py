from enum import StrEnum

from pydantic import BaseModel, Field


class GameMode(StrEnum):
    CLASSIC = "classic"
    TOURNAMENT = "tournament"
    JADE = "jade"
    SEA_DEMON = "sea_demon"
    THRILL_ZONE = "thrill_zone"


class RoomSummary(BaseModel):
    room_id: str
    name: str
    mode: GameMode
    online_players: int = Field(ge=0)
    capacity: int = Field(gt=0)
    min_multiplier: int = Field(gt=0)
    max_multiplier: int = Field(gt=0)
    accepting_players: bool = True


class JoinRoomRequest(BaseModel):
    player_id: str = Field(min_length=3, max_length=64)
    mode: GameMode


class JoinRoomResponse(BaseModel):
    room_id: str
    session_ticket: str
    endpoint: str
