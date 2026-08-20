APP_DIR := $(abspath $(lastword $(MAKEFILE_LIST)))

.PHONY: reload start stop kill remove clean update

reload:
	-$(MAKE) kill
	$(MAKE) start

start:
	docker compose -f compose.yaml -f compose.override.yaml up --remove-orphans --detach

stop:
	docker compose stop

kill:
	docker compose kill

remove:
	docker compose rm --force

clean:
	-$(MAKE) kill
	-$(MAKE) remove
	docker container prune -y
	docker volumes prune -y
	docker network prune -y

update: stop
	docker compose pull
	$(MAKE) start
