import pytest
from grpc.aio import insecure_channel
from protos.wallet import wallet_pb2_grpc
from typing_extensions import AsyncGenerator


@pytest.fixture()
async def client() -> AsyncGenerator[wallet_pb2_grpc.WalletServiceStub, None]:
    """RPC service client."""
    async with insecure_channel("127.0.0.1:5005") as channel:
        yield wallet_pb2_grpc.WalletServiceStub(channel)
