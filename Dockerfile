ARG PYTHON_BASE=3.12-slim

FROM python:$PYTHON_BASE as build

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y -q \
      build-essential python3-dev libffi-dev git && \
    python3 -m pip install --no-cache-dir --quiet -U pip && \
    python3 -m pip install --no-cache-dir --quiet pdm

ENV PDM_CHECK_UPDATE=false

COPY pyproject.toml pdm.lock README.md /app/
COPY src/ /app/src

WORKDIR /app

RUN pdm build


FROM python:$PYTHON_BASE

COPY --from=build /app/dist/*.whl .

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y -q \
      build-essential python3-dev libffi-dev git && \
    python3 -m pip install --no-cache-dir --quiet -U pip && \
    python3 -m pip install --no-cache-dir --quiet *.whl && \
    rm -f *.whl && \
    apt remove -y --quiet build-essential python3-dev libffi-dev git && \
    apt autoremove -y --quiet

EXPOSE 5000

HEALTHCHECK --interval=10s --timeout=3s \
  CMD curl -f http://localhost:5000/-/health || exit 1

ENTRYPOINT ["python3", "-m", "wallet"]

CMD ["server", "run", "--host=0.0.0.0"]
