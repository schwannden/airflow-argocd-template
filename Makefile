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
setup:
	kubectl create namespace airflow --dry-run=client -o yaml | kubectl apply -f -
	kubectl create -n airflow secret generic airflow-fernet-key \
		--save-config \
		--dry-run=client \
		--from-literal="fernet-key=XiS5LHZQvWJeqWKI_zAPZoAt_3f_mdYmcSCH7vMDyGU=" \
		-o yaml | \
		kubectl apply -n airflow -f -
	kubectl create -n airflow secret generic airflow-ssh-git-secret \
		--save-config \
		--dry-run=client \
		--from-file=gitSshKey=.ssh/id_rsa \
		-o yaml | \
		kubectl apply -n airflow -f -

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


## deploy airflow
deploy: check-K_ENV
	kubectl kustomize overlays/${K_ENV} --enable-helm | kubectl apply -f -

## stop airflow
stop: check-K_ENV
	kubectl kustomize overlays/${K_ENV} --enable-helm | kubectl delete -f -

## deploy airflow to argocd
argo/deploy: check-K_ENV
	kubectl apply -k cd/overlays/${K_ENV}

