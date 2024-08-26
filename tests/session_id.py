from typing import cast
from uuid import uuid4

import pytest

default_session_id = str(uuid4())


def session_id_type(string: str) -> str:
    """Choose session id type."""
    if string in ("default", "last"):
        return string

    return string


def pytest_addoption(parser: pytest.Parser) -> None:
    """Add test session id to pytest options parser."""
    group = parser.getgroup("session-id", "pytest-random-session-id")
    group._addoption(
        "--random-session-id",
        action="store",
        dest="session_id",
        default="default",
        type=session_id_type,
    )


def pytest_configure(config: pytest.Config) -> None:
    """Add test session id to pytest config."""
    session_id_value = config.getoption("session_id")

    match session_id_value:
        case "last":
            assert hasattr(
                config, "cache"
            ), "The cacheprovider plugin is required to use 'last'"
            assert config.cache is not None
            session_id = config.cache.get("random_session_id", default_session_id)
        case "default":
            session_id = default_session_id
        case _:
            session_id = session_id_value

    if hasattr(config, "cache"):
        assert config.cache is not None
        config.cache.set("random_session_id", session_id)

    config.option.session_id = session_id


def pytest_report_header(config: pytest.Config) -> str:
    """Add test session id to report header."""
    session_id = config.getoption("session_id")
    return f"Using --random-session-id={session_id}"


@pytest.fixture(scope="session")
def session_id(request: pytest.FixtureRequest) -> str:
    """Test session identifier."""
    return cast(str, request.config.getoption("session_id"))
