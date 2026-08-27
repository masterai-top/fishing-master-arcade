from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "OceanRaid Gateway"
    app_env: str = "development"
    app_host: str = "127.0.0.1"
    app_port: int = 8080
    database_url: str = "mysql://oceanraid:change-me@127.0.0.1/oceanraid"
    cpp_room_service_url: str = "http://127.0.0.1:8090"
    admin_api_key: str = "replace-in-local-env"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


@lru_cache
def get_settings() -> Settings:
    return Settings()
