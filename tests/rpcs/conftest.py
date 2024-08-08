from collections.abc import Awaitable, Callable

import pytest
from aiohttp import web
from aiohttp.test_utils import TestServer


@pytest.fixture()
async def server(
    app: web.Application,
    aiohttp_server: Callable[[web.Application], Awaitable[TestServer]],
) -> TestServer:
    """Test server."""
    return await aiohttp_server(app)
