ARG PYTHON_BASE=3.12-slim

FROM python:$PYTHON_BASE as build

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qy && apt-get install -qyy \
    build-essential curl python3-setuptools python3-dev libffi-dev git

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.12

RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && uv venv /app/.venv

COPY pyproject.toml /app
COPY uv.lock /app
RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && cd /app \
    && uv sync --frozen --no-install-project

WORKDIR /app

COPY . /src
RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && uv pip install --python=/app/.venv --no-deps /src


FROM python:$PYTHON_BASE

ENV PATH=/app/.venv/bin:$PATH

RUN set -ex \
    && groupadd -r wallet \
    && useradd -r -d /app -g wallet -N wallet

STOPSIGNAL SIGINT

# RUN set -ex \
#     && apt-get update -qy  \
#     && apt-get install -qyy \
#     -o APT::Install-Recommends=false \
#     -o APT::Install-Suggests=false \
#     python3-dev \
#     libpython3.12 \
#     libpcre3 \
#     libxml2 \
#     && rm -rf /var/lib/apt/lists/*

COPY --from=build --chown=wallet:wallet /app /app

USER wallet
WORKDIR /app

RUN set -ex \
    && python -V \
    && python -Im site

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=3s \
    CMD curl -f http://localhost:5000/-/health || exit 1

ENTRYPOINT ["python3", "-m", "wallet"]

CMD ["server", "run", "--host=0.0.0.0"]
