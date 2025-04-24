# Constants

PY = ./manage.py

PYTEST = pytest --tb=short -s

DC = docker compose -f docker-compose.yml --env-file ./app/dotenv_files/.env 

EXEC = $(DC) exec

RUN = $(DC) run --rm

# Compose comands

up:
	@echo "Building project..."
	$(DC) up api postgres

down:
	$(DC) down

build:
	@echo "Copying environments files"
	cp ./app/dotenv_files/.env-example ./app/dotenv_files/.env

	$(DC) build --no-cache api postgres
	@make up

rebuild: 
	@echo "Removing project containers"
	-docker rm -f backend postgres ngrok

	@echo "Removing project images"
	docker rmi -f $(docker images -aq)

	@make build

run-back:
	$(RUN) backend $(cmd)

shell:
	@$(EXEC) backend $(PY) shell_plus

setup:
	@echo "Up backend..."
	@echo "Running migrations"
	@make run-back cmd="$(PY) makemigrations"
	@make run-back cmd="$(PY) migrate"

flush:
	@echo "Reseting DATABASE..."
	@make run-back cmd="$(PY) reset_db --noinput --close-sessions"
	@make setup

back-formatter:
	@echo "Formatting code accord Pep8 Style..."
	@echo "Sorting Imports..."
	@make run-back cmd="isort ."
	@echo "Formatting code..."
	@make run-back cmd="black --exclude "migrations" --line-length 120 ."
	@echo "Running flake8"
	@make run-back cmd="flake8 --exclude "migrations" --max-line-length 120 ."
	@echo "Completed with 0 erros"

test-back:
	@make run-back cmd="$(PYTEST)"

test-back-app:
	@echo "Running backend app tests"
	@make run-back cmd="$(PYTEST) app/tests/"

test-back-app-spec:
	@echo "Running backend app file tests"
	@make run-back cmd="$(PYTEST) app/tests/$(file)"
