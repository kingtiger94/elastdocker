.DEFAULT_GOAL:=help

# This for future release of Compose that will use Docker Buildkit, which is much efficient.
COMPOSE_PREFIX_CMD := COMPOSE_DOCKER_CLI_BUILD=1

COMPOSE_ALL_FILES := -f docker-compose.yml -f docker-compose.monitor.yml -f docker-compose.tools.yml
ELK_SERVICES   := elasticsearch logstash kibana
ELK_MONITORING := elasticsearch_exporter logstash_exporter cadvisor_exporter filebeat_cluster_logs
ELK_TOOLS  := curator elastalert
ELK_ALL_SERVICES := ${ELK_SERVICES} ${ELK_MONITORING} ${ELK_TOOLS}
# --------------------------

.PHONY: setup all elk monitoring tools build down stop restart rm logs

setup:		    ## Setup Elasticsearch Keystore, by initializing passwords, and add credentials defined in `keystore.sh`.
	${COMPOSE_PREFIX_CMD} docker-compose -f docker-compose.setup.yml run --rm create_keystore

all:		    ## Start Elk and all its component (ELK, Monitoring, and Tools).
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} up -d ${ELK_ALL_SERVICES}

elk:		    ## Start ELK.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} up -d ${ELK_SERVICES}

monitoring:		## Start ELK Monitoring.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} up -d ${ELK_MONITORING}

tools:		    ## Start ELK Tools.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} up -d ${ELK_TOOLS}

build:			## Build ELK and all its extra components.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} build ${ELK_ALL_SERVICES}

down:			## Down ELK and all its extra components.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} down

stop:			## Stop ELK and all its extra components.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} stop ${ELK_ALL_SERVICES}
	
restart:		## Restart ELK and all its extra components.
	${COMPOSE_PREFIX_CMD} docker-compose ${COMPOSE_ALL_FILES} restart ${ELK_ALL_SERVICES}

rm:				## Remove ELK and all its extra components containers.
	@${COMPOSE_PREFIX_CMD} docker-compose $(COMPOSE_ALL_FILES) rm -f ${ELK_ALL_SERVICES}

logs:			## Tail all logs with -n 1000.
	@${COMPOSE_PREFIX_CMD} docker-compose $(COMPOSE_ALL_FILES) logs --follow --tail=1000 ${ELK_TOOLS} ${ELK_SERVICES}

images:			## Show all Images of ELK and all its extra components.
	@${COMPOSE_PREFIX_CMD} docker-compose $(COMPOSE_ALL_FILES) images ${ELK_ALL_SERVICES}

help:       	## Show this help.
	@echo "Make Application Docker Images and Containers using Docker-Compose files in 'docker' Dir."
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m (default: help)\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
