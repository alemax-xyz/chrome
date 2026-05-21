TAG ?= clover/chrome
PLATFORM ?= linux/amd64

latest:
	docker buildx build --progress plain --platform ${PLATFORM} --tag ${TAG}:$@ --push .

.PHONY: latest
