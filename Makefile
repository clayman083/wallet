.PHONY: build clean test

NAME		:= ghcr.io/clayman083/wallet
VERSION		?= latest
HOST 		?= 0.0.0.0
PORT 		?= 5000

clean: clean-build clean-pyc clean-test

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test:
	rm -fr .tox/
	rm -f .coverage
	rm -fr tests/coverage
	rm -f tests/coverage.xml

format:
	uv run ruff --select I --fix src/wallet tests
	uv run ruff format src/wallet tests

check_mypy:
	@echo Check project with Mypy typechecker.
	uv run mypy src/wallet tests

check_ruff:
	@echo Check project with Ruff linter.
	uv run ruff check --output-format=full --no-fix src/wallet tests

check_format:
	@echo Check formatting
	uv run ruff format --check --diff src/wallet tests

install: clean
	uv sync

lint: check_format check_ruff check_mypy

run:
	uv run python3 -m wallet --debug server run --host=$(HOST) --port=$(PORT)

test:
	uv run pytest

build:
	docker build -t ${NAME} .
	docker tag ${NAME} ${NAME}:$(VERSION)

publish:
	docker login -u $(DOCKER_USER) -p $(DOCKER_PASS) ghcr.io
	docker push ${NAME}
