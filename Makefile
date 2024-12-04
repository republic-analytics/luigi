IMAGE:=luigi-test
TAG:=3.12

.PHONY: clean
clean:
	docker image prune --force

.PHONY: test
test:
	docker buildx build \
		--platform=linux/amd64 \
		-t "$(IMAGE):$(TAG)" \
		-f test.dockerfile \
		--build-arg PYTHON_VERSION="$(TAG)" \
		. && \
	docker run \
		--rm \
		--platform=linux/amd64 \
		"$(IMAGE):$(TAG)" $(CMD)
