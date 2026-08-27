from secrets import token_urlsafe

from fastapi import APIRouter, HTTPException, Query, status

from app.models import GameMode, JoinRoomRequest, JoinRoomResponse, RoomSummary
from app.services.room_catalog import room_catalog

router = APIRouter(prefix="/v1/rooms", tags=["rooms"])


@router.get("")
def list_rooms(mode: GameMode | None = Query(default=None)) -> list[RoomSummary]:
    return room_catalog.list_rooms(mode)


@router.post("/join", response_model=JoinRoomResponse)
def join_room(payload: JoinRoomRequest) -> JoinRoomResponse:
    room = room_catalog.first_available(payload.mode)
    if room is None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="No room available")
    return JoinRoomResponse(
        room_id=room.room_id,
        session_ticket=token_urlsafe(24),
        endpoint="ws://127.0.0.1:8090/game",
    )
