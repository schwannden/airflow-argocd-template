#!make
.PHONY: help

## this help
help:
	@printf "Usage:\n";

	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\0-9\/]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-25s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\0-9\/.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-25s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                           "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                          "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)

## create namespace
setup/namespace:
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

## create kustomize + helm plugin
setup/plugin:
	kubectl apply -n argocd -f helm-plugin.yaml

## install kustomize
download/kustomize:
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
	sudo chmod +x kustomize
	sudo mv kustomize /usr/local/bin

check-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi


## deploy argo
deploy: check-K_ENV
	kubectl apply -n argocd -k overlays/${K_ENV}

## stop argo
stop: check-K_ENV
	kubectl delete -n argocd -k overlays/${K_ENV}

