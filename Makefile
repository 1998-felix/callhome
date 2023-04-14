PROGRAM = call-home
MF_DOCKER_IMAGE_NAME_PREFIX ?= et
SOURCES = $(wildcard *.go) cmd/main.go
CGO_ENABLED ?= 0
GOARCH ?= amd64
VERSION ?= $(shell git describe --abbrev=0 --tags)
COMMIT ?= $(shell git rev-parse HEAD)
TIME ?= $(shell date +%F_%T)

all: $(PROGRAM)

.PHONY: all clean $(PROGRAM)

define make_docker
	docker build \
		--no-cache \
		--build-arg SVC=$(PROGRAM) \
		--build-arg GOARCH=$(GOARCH) \
		--build-arg GOARM=$(GOARM) \
		--build-arg VERSION=$(VERSION) \
		--build-arg COMMIT=$(COMMIT) \
		--build-arg TIME=$(TIME) \
		--tag=$(MF_DOCKER_IMAGE_NAME_PREFIX)/$(PROGRAM) \
		-f docker/Dockerfile .
endef

define make_docker_dev
	docker build \
		--no-cache \
		--build-arg SVC=$(PROGRAM) \
		--tag=$(MF_DOCKER_IMAGE_NAME_PREFIX)/$(PROGRAM) \
		-f docker/Dockerfile.dev ./build
endef

$(PROGRAM): $(SOURCES)
	CGO_ENABLED=$(CGO_ENABLED) GOOS=$(GOOS) GOARCH=$(GOARCH) GOARM=$(GOARM) \
	go build -mod=vendor -ldflags "-s -w \
	-X 'github.com/mainflux/mainflux.BuildTime=$(TIME)' \
	-X 'github.com/mainflux/mainflux.Version=$(VERSION)' \
	-X 'github.com/mainflux/mainflux.Commit=$(COMMIT)'" \
	-o ./build/et-$(PROGRAM) cmd/main.go

clean:
	rm -rf $(PROGRAM)
docker-image:
	$(call make_docker,$(GOARCH))
