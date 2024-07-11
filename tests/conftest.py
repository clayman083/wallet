from importlib.metadata import Distribution, distribution

import pytest
from aiohttp import web
from structlog.stdlib import BoundLogger

from wallet.app import init
from wallet.logging import configure_logging


@pytest.fixture(scope="session")
def dist() -> Distribution:
    """Patch application distribution."""
    return distribution("wallet")


@pytest.fixture()
def logger(dist: Distribution) -> BoundLogger:
    """Configure logging for tests."""
    return configure_logging(dist=dist, debug=False)


@pytest.fixture()
def app(dist: Distribution, logger: BoundLogger) -> web.Application:
    """Prepare test application."""
    return init(dist=dist, logger=logger, debug=False)
