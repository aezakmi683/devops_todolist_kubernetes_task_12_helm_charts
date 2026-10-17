\# INSTRUCTION.md



\## Prerequisites



Install and configure the following tools:



\- Docker Desktop

\- kind

\- kubectl

\- Helm 3

\- Git



Run commands from the repository root.



\## 1. Validate the Helm charts



Build the MySQL chart dependency:



```bash

helm dependency build ./helm-chart/todoapp

```



Lint the parent chart:



```bash

helm lint ./helm-chart/todoapp

```



Lint the MySQL subchart:



```bash

helm lint ./helm-chart/todoapp/charts/mysql

```



Render the Kubernetes manifests to verify the templates:



```bash

helm template todoapp ./helm-chart/todoapp --namespace todoapp

```



\## 2. Deploy the application



Run the bootstrap script from a Bash-compatible terminal, such as Git Bash:



```bash

bash ./bootstrap.sh

```



The script creates a separate kind cluster named `task12` if it does not exist, installs the ingress controller prerequisite, validates the Helm charts, and deploys the ToDo application with its MySQL dependency.



The Kubernetes context used by the script is `kind-task12`.



\## 3. Verify the deployment



Check cluster nodes:



```bash

kubectl --context kind-task12 get nodes

```



Check application resources:



```bash

kubectl --context kind-task12 get all -n todoapp

```



Check MySQL resources:



```bash

kubectl --context kind-task12 get all -n mysql

```



Check persistent volumes and claims:



```bash

kubectl --context kind-task12 get pv

kubectl --context kind-task12 get pvc -A

```



Check the Helm release:



```bash

helm --kube-context kind-task12 list -A

```



Check the release status:



```bash

helm --kube-context kind-task12 status todoapp -n todoapp

```



\## 4. Save the resource inventory



The bootstrap script creates `output.log` in the repository root. To regenerate it manually, run:



```bash

kubectl --context kind-task12 get all,cm,secret,ing -A | tee output.log

```



\## 5. Troubleshooting



Check pod status:



```bash

kubectl --context kind-task12 get pods -A

```



Inspect a pod that is not starting:



```bash

kubectl --context kind-task12 describe pod POD\_NAME -n NAMESPACE

```



View application logs:



```bash

kubectl --context kind-task12 logs deployment/todoapp -n todoapp

```



Check Helm release details:



```bash

helm --kube-context kind-task12 status todoapp -n todoapp

```



If deployment fails, inspect the Helm output and Kubernetes events before changing or deleting resources.

