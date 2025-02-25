.PHONY: help
help: ## display this help
	@grep -E '^[.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: action.yaml
action.yaml: tmp/next ## update image version in action.yaml
	yq -i '.runs.image="docker://ghcr.io/charlesthomas/github-action-svu:$(shell cat tmp/next | tr + -)"' action.yaml

build-image: tmp/current ## build docker image
	docker build -t ghcr.io/charlesthomas/github-action-svu:$(shell cat tmp/current | tr + -) .

tag: action.yaml ## use svu next to make a new tag and push it
	git add action.yaml
	git commit -m "chore: bump version in action.yaml to $(shell cat tmp/next)"
	git push
	git tag $(shell cat tmp/next)
	git push --tags

clean:
	-rm -rf tmp/

tmp/:
	mkdir -p $(@)

tmp/current: tmp/
	svu current > $(@)

.PHONY: tmp/next
tmp/next: tmp/svu
	svu next --metadata $(shell cat tmp/svu) > $(@)

tmp/svu: tmp/
	head -1 VERSION > $(@)
