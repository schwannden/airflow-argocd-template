# Airflow ArgoCD Template
A template project to deploy airflow with argo CD. The project is designed for the following purpose
1. Need of separating development and production Airflow environment
2. Develop environment and production environment deploys Airflow with different parameters (password, ingress rule, worker replica, ...etc).
3. Enable our data scientist team to deploy to develop or production environment with ease.

# Pre-requisite
1. Access an to existing k8s cluster.
2. Basic familiarity with Airflow component.
3. Access to a separate Airflow dags repository.

# Project Structure Explained
1. this project uses kustomize to manage develop and production environments.
2. the root project folder contains `base` and `overlays` folder, kustomize uses these folder generate airflow deployment yaml file from airflow helm chart.
3. the `cd` folder also contains `base` and `overlays` folder, kustomize uses these to generate argocd's application deployment manifest.
4. `Makefile` contains all the useful commands

# Setup
Here is a list of secrets/files that you should change before your deployment to production.
1. `.ssh/id_rsa` and `.ssh/id_rsa.pub`: these files are used for gitSync to pull your dags repository.
2. `base/values.yaml`: update all paswords and secrets to your own password and secrets.
3. `overlays/develop/kustomize.yaml`: update ingress route to your develop instance host.
4. `overlays/production/kustomize.yaml`: update ingress route to your production instance host.
5. `Makefile`: update the `fernet-key` in setup command section.
