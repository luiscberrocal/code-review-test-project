define BROWSER_PYSCRIPT
import os, webbrowser, sys

from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"
UNIT_TESTS = happy_condo

MINIMUM_COVERAGE = 93.0

DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
ifeq ($(DOCKER_COMPOSE),)
    DOCKER_COMPOSE := $(shell which docker 2>/dev/null)
    ifneq ($(DOCKER_COMPOSE),)
        DOCKER_COMPOSE_CMD := docker compose
    else
        $(error Neither docker-compose nor docker command found. Please install Docker and docker-compose)
    endif
else
    DOCKER_COMPOSE_CMD := docker-compose
endif

clean:
	rm -rf output/*.*

format:
	ruff format

test: format
	$(DOCKER_COMPOSE_CMD) -f local.yml  down --remove-orphans
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django pytest  $(UNIT_TESTS)

test-list:
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django pytest --co -q

cov:
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django coverage run manage.py test $(UNIT_TESTS) --settings=config.settings.local --exclude-tag=INTEGRATION
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django coverage report --fail-under=$(MINIMUM_COVERAGE) -m
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django coverage html
	$(BROWSER) htmlcov/index.html

list-outdated-local:
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django pip3 list --outdated -v

update-libraries:
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django pur -r requirements/local.txt --minor "django,*"
	$(DOCKER_COMPOSE_CMD) -f local.yml run --rm django pur -r requirements/production.txt --minor "django,*"
