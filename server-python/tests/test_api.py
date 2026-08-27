from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    assert client.get("/health").json()["status"] == "ok"


def test_room_catalog_and_join() -> None:
    rooms = client.get("/v1/rooms", params={"mode": "classic"}).json()
    assert rooms[0]["room_id"] == "classic-rookie-01"

    response = client.post(
        "/v1/rooms/join",
        json={"player_id": "local-player", "mode": "classic"},
    )
    assert response.status_code == 200
    assert response.json()["session_ticket"]
