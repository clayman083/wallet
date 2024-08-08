import asyncio
import socket
from importlib.metadata import Distribution
from typing import AsyncGenerator

from aiohttp import web
from grpc.aio import Server
from grpc.aio import server as grpc_server
from grpc_reflection.v1alpha import reflection
from protos.wallet import wallet_pb2, wallet_pb2_grpc
from structlog.stdlib import BoundLogger

from wallet.rpcs.wallet import WalletServicer
from wallet.web.handlers import meta
from wallet.web.middlewares.logging import logging_middleware
from wallet.web.middlewares.metrics import metrics_middleware


async def grpc_server_ctx(app: web.Application) -> AsyncGenerator[None, None]:
    """GRPC server context."""

    async def _start_grpc_server(server: Server) -> None:
        await server.start()
        await server.wait_for_termination()

    listen_addr = "[::]:5005"

    server = grpc_server()
    server.add_insecure_port(listen_addr)

    wallet_pb2_grpc.add_WalletServiceServicer_to_server(  # type: ignore
        servicer=WalletServicer(app=app),
        server=server,
    )

    if app["debug"]:
        SERVICE_NAMES = (
            wallet_pb2.DESCRIPTOR.services_by_name["WalletService"].full_name,
            reflection.SERVICE_NAME,
        )
        reflection.enable_server_reflection(SERVICE_NAMES, server)

    task = asyncio.create_task(_start_grpc_server(server))

    app.logger.info(f"action=init_grpc_server, address={listen_addr}")

    yield

    await server.stop(grace=None)
    task.cancel()
    await task


def init(
    dist: Distribution, logger: BoundLogger, debug: bool = False
) -> web.Application:
    """Create application instance.

    Args:
        dist: Application distribution.
        logger: Bounded application logger.
        debug: Run application in debug mode.

    Return:
        New application instance.
    """
    app = web.Application(
        middlewares=(logging_middleware, metrics_middleware),
        logger=logger,  # type: ignore[arg-type]
    )

    app["hostname"] = socket.gethostname()
    app["distribution"] = dist

    app["debug"] = debug

    app.cleanup_ctx.append(grpc_server_ctx)

    app.router.add_routes(routes=meta.routes)

    return app
