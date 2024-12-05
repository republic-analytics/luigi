IMAGE:=luigi-test
TAG:=3.11

.PHONY: clean
clean:
	docker image prune --force
	rm -rf .tox

.PHONY: test
test:
	docker buildx build \
		--platform=linux/amd64 \
		-t "$(IMAGE):$(TAG)" \
		-f test.dockerfile \
		--build-arg PYTHON_VERSION="$(TAG)" \
		.
	# when running in CI, provide `-e CI=true` to support codecov docker execution
	docker run \
		--rm \
		--platform=linux/amd64 \
		-v ./.tox:/app/.tox \
		-v /var/run/docker.sock:/var/run/docker.sock \
		"$(IMAGE):$(TAG)" $(CMD)
