from datetime import datetime
from unittest import mock
from uuid import UUID

import google.protobuf.empty_pb2
import google.protobuf.timestamp_pb2
import pytest
from protos.wallet import wallet_pb2, wallet_pb2_grpc


@pytest.mark.usefixtures("freezer", "server")
async def test_success(
    client: wallet_pb2_grpc.WalletServiceStub,
    account_id: UUID,
) -> None:
    """Get wallet's accounts."""
    with mock.patch("wallet.rpcs.wallet.uuid4", return_value=account_id):
        result = [
            response.account
            async for response in client.get_accounts(
                request=google.protobuf.empty_pb2.Empty()
            )
        ]

    assert result == [
        wallet_pb2.Account(
            id=str(account_id),
            name="Foo",
            balance=wallet_pb2.Balance(expenses="0.0", incomes="0.0"),
            status=wallet_pb2.Account.Status.ACTIVE,
            created_at=google.protobuf.timestamp_pb2.Timestamp(
                seconds=int(round(datetime.now().timestamp()))
            ),
        )
    ]
