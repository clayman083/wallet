from datetime import datetime
from typing import AsyncGenerator
from uuid import uuid4

import attrs
import google.protobuf.empty_pb2
import google.protobuf.timestamp_pb2
from aiohttp import web
from grpc.aio import ServicerContext
from protos.wallet import wallet_pb2, wallet_pb2_grpc


@attrs.define(kw_only=True, slots=True)
class WalletServicer(wallet_pb2_grpc.WalletServiceServicer):
    """Wallet service implementation."""

    app: web.Application

    async def get_accounts(
        self,
        request: google.protobuf.empty_pb2.Empty,
        context: ServicerContext[
            wallet_pb2.CreateAccountRequest,
            wallet_pb2.AccountResponse,
        ],
    ) -> AsyncGenerator[wallet_pb2.AccountResponse, None]:
        """Get wallet accounts."""
        accounts = [
            wallet_pb2.Account(
                id=str(uuid4()),
                name="Foo",
                balance=wallet_pb2.Balance(expenses="0.0", incomes="0.0"),
                status=wallet_pb2.Account.Status.ACTIVE,
                created_at=google.protobuf.timestamp_pb2.Timestamp(
                    seconds=int(round(datetime.now().timestamp()))
                ),
            )
        ]

        for account in accounts:
            yield wallet_pb2.AccountResponse(account=account)

    async def create_account(
        self,
        request: wallet_pb2.CreateAccountRequest,
        context: ServicerContext[
            wallet_pb2.CreateAccountRequest,
            wallet_pb2.AccountResponse,
        ],
    ) -> wallet_pb2.AccountResponse:
        """Create new account."""
        return wallet_pb2.AccountResponse(
            account=wallet_pb2.Account(
                id=str(uuid4()),
                name=request.name,
                balance=wallet_pb2.Balance(expenses="0.0", incomes="0.0"),
                status=wallet_pb2.Account.Status.ACTIVE,
                created_at=google.protobuf.timestamp_pb2.Timestamp(
                    seconds=int(round(datetime.now().timestamp()))
                ),
            )
        )
