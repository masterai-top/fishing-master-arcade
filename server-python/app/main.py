from fastapi import FastAPI

from app.api.health import router as health_router
from app.api.rooms import router as rooms_router
from app.config import get_settings

settings = get_settings()
app = FastAPI(title=settings.app_name, version="0.1.0")
app.include_router(health_router)
app.include_router(rooms_router)
