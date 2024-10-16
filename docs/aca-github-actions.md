# Spring Boot Todo App and Pet Clinic App on Azure Container Apps (ACA)

## Deploying Todo App and Pet Clinic App into ACA using Github actions (CI/CD Pipeline)

![Architecture Diagram](./aca-java-demo-architecture.drawio.png)

* Copy [this](https://github.com/martinabrle/aca-java-demo) repo's content into your personal or organizational GitHub Account
* Copy pet clinic app's config repo content from [this](https://github.com/martinabrle/aks-java-demo-config) repo into your personal or organizational GitHub Account
* *Note: This limited example is not utilising GitHub->Settings->Environments. It would make sense to have separated DEVE, TEST, UAT and PRODUCTION environments and define unique variables under each of these environment*
* Click on *GitHub->Settings->Secrets and Variables* and set the following GitHub action secrets:

    ```bash
    AZURE_LOCATION: "switzerlandnorth" # <-- azure region for deploying resources

    AAD_CLIENT_ID="00000000-0000-0000-0000-000000000000" # <-- replace with the client Id of a Microsoft Entra ID registered application, used for deploying Azure resources (see below)
    AAD_TENANT_ID="00000000-0000-0000-0000-000000000000" # <-- replace with Azure tenantId for deploying resources
    ACA_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000" # <-- replace with azure subscription for deploying resources
    ACA_RESOURCE_GROUP: aca-rg # <-- resource group for deploying compute resources (will be created)

    ACA_NAME=aca-aks-java-demo # <-- name of the ACA cluster
    
    PGSQL_NAME="{{{REPLACE_WITH_PGSQL_NAME}}}" # <--PGSQL Server name, needs to be unique
    DBA_GROUP_NAME="All TEST PGSQL Admins" # <--Entra ID group of users with permissions to manage the PGSQL server
    DBA_GROUP_ID="00000000-0000-0000-0000-000000000000"  # Id of the Entra ID group of users with permissions to manage the PGSQL server, obtain from Portal's UI or by running 'az ad group show --group "${DBA_GROUP_NAME}" --query '[id]' -o tsv'

    CONTAINER_REGISTRY_NAME="{{{REPLACE_WITH_APP_SERVICE_NAME}}}" # <--needs to be unique
    LOG_ANALYTICS_WRKSPC_NAME="{{{REPLACE_WITH_LOG_WORKSPACE_NAME}}}" # <--needs to be unique

    PET_CLINIC_GIT_CONFIG_REPO_URI="https://github.com/martinabrle/aks-java-demo-config" # <--URI of YOUR Git repository with Pet Clinic Java Spring Boot configurations
    PET_CLINIC_GIT_CONFIG_REPO_USERNAME="martinabrle" # <--Username to access the Git repository with Pet Clinic Java Spring Boot configurations - in this case my GH handle
    PET_CLINIC_GIT_CONFIG_REPO_PASSWORD="PAT_TOKEN" # <--Token to access the Git repository with Pet Clinic Java Spring Boot configurations

    TODO_APP_DB_NAME="tododb" # <--Name of the database for the Todo App
    PET_CLINIC_DB_NAME="petclinicdb" # <--Name of the database for the Pet Clinic App

    TODO_APP_DB_USER_NAME="todoapp" # <--Name of database the user for the Todo App
    PET_CLINIC_CUSTS_SVC_DB_USER_NAME="custssvc" # <--Name of the database user for the Pet Clinic Customers Service
    PET_CLINIC_VETS_SVC_DB_USER_NAME="vetssvc" # <--Name of the database user for the Pet Clinic Vets Service
    PET_CLINIC_VISITS_SVC_DB_USER_NAME="visitssvc" # <--Name of database the user for the Pet Clinic Visits Service
    ```

* Optionally, set the following environment variables to deploy with custom DNS zone:

    ```bash
    DNS_ZONE_NAME="aca-java-demo" # <--Name of the DNS zone of all services - here I expect to use DNS names like "aca-java-demo.petclinic.DEVELOPMENT_ENVI.MY_COMPANY_DOMAIN.com"
    PARENT_DNS_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000" # <--Subscription ID where the parent DNS zone is located
    PARENT_DNS_ZONE_NAME="DEVELOPMENT_ENVI.MY_COMPANY_DOMAIN.com" # <--Name of the parent DNS zone - here I expect to use DNS names like "aca-java-demo.petclinic.DEVELOPMENT_ENVI.MY_COMPANY_DOMAIN.com
    PARENT_DNS_ZONE_RESOURCE_GROUP="domain_rg" # <--Resource group for the parent DNS zone
    PET_CLINIC_DNS_ZONE_NAME="petclinic" # <--Name of the subdomain where the Pet Clinic app will be deployed
    ```

* Optionaly, for a greater control over the names of deployed resources, separating deployment of stateless and statefull workloads, or governance, set the following GitHub action secrets:

    ```bash
    PGSQL_RESOURCE_GROUP="pgsql_rg" # <--Resource group for Postgresql server, replace with a name of your choice, following your company's policies
    PGSQL_SUBSCRIPTION_ID='00000000-0000-0000-0000-000000000000' # <--Subscription ID where PGSQL will be deployed
    CONTAINER_REGISTRY_RESOURCE_GROUP="acr_rg" # <-- Container registry resource group, replace with a name of your choice, following your company's policies
    CONTAINER_REGISTRY_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000" # <-- Replace with the container registry resource subscription Id, if different from ACA deployment's subscription Id
    LOG_ANALYTICS_WRKSPC_RESOURCE_GROUP="log-analytics_rg" # <-- Name of the log analytics workspace resource group
    LOG_ANALYTICS_WRKSPC_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000" # <--Subscription ID where Log Analytics will be deployed, if different from ACA deployment's subscription Id
    ```

* Optionally, you can set some or all of the following environment variables under *GitHub->Settings->Secrets and Variables* in order to tag resources for better governance:

    ```bash
    ACA_RESOURCE_TAGS: { \"Department\": \"RESEARCH\", \"CostCentre\": \"DEVELOPMENT\", \"DeleteWeekly\": \"true\", \"Workload\": \"DEVELOPMENT\", \"StopNightly\": \"true\"}
    CONTAINER_REGISTRY_RESOURCE_TAGS: { \"Department\": \"RESEARCH\", \"CostCentre\": \"DEVELOPMENT\", \"DeleteWeekly\": \"false\", \"Workload\": \"DEVELOPMENT\"}
    LOG_ANALYTICS_WRKSPC_RESOURCE_TAGS: { \"Department\": \"RESEARCH\", \"CostCentre\": \"DEVELOPMENT\", \"DeleteWeekly\": \"false\", \"Workload\": \"DEVELOPMENT\"}
    PARENT_DNS_ZONE_TAGS { \"Department\": \"RESEARCH\", \"CostCentre\": \"DEVELOPMENT\", \"DeleteWeekly\": \"false\", \"Workload\": \"DEVELOPMENT\"}
    PGSQL_RESOURCE_TAGS: { \"Department\": \"RESEARCH\", \"CostCentre\": \"DEVELOPMENT\", \"DeleteWeekly\": \"false\", \"Workload\": \"DEVELOPMENT\", \"StopNightly\": \"true\"}
    ```

* Register a Microsoft Entra application in Azure and add federated credentials in order for GitHub actions to deploy resources into Azure ([link](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Cwindows#use-the-azure-login-action-with-openid-connect)). You will need to assign *Key Vault Administrator*, *Contributor* and *Owner* role to the newly created SP for every subscription you are deploying into. The service principal will also need to have "Directory.Read" role assigned to it for the workflow to work. If you are integrating with a DNS Zone, this newly created SP will also need *DNS Zone Contributor role* assigned to it.

    ```bash
    az ad sp create-for-rbac --name {YOUR_DEPLOYMENT_PRINCIPAL_NAME} --role "Key Vault Administrator" --scopes /subscriptions/{AZURE_SUBSCRIPTION_ID} --sdk-auth
    az ad sp create-for-rbac --name {YOUR_DEPLOYMENT_PRINCIPAL_NAME} --role contributor --scopes /subscriptions/{AZURE_SUBSCRIPTION_ID} --sdk-auth
    az ad sp create-for-rbac --name {YOUR_DEPLOYMENT_PRINCIPAL_NAME} --role owner --scopes /subscriptions/{AZURE_SUBSCRIPTION_ID} --sdk-auth
    ```

* Copy the *clientId* value into a newly created *AAD_CLIENT_ID* repo secret
* Run the infrastructure deployment by running *Actions->00-Infra* manually; this action is defined in ```./aca-java-demo/.github/workflows/00-infra.yml```
* Generate releases for all apps and microservices by running *Actions->00-Init-Repository-Todo-App* and *Actions->00-Init-Repository-Pet-Clinic* manually; these actions are defined in ```./aca-java-demo/.github/workflows/01-init-todo-app.yml``` and ```./aca-java-demo/.github/workflows/01-init-pet-clinic.yml```
* Test the Todo application:
    If you have chosen to integrate with Azure DNS, point the browser to the custom URL of the Todo App, e.g. ```https://todoapp.aca-java-demo.DEVELOPMENT_ENVI.MY_COMPANY_DOMAIN.com``` - you can check the DNS records created. Alternatively, navigate to the newly created resource group and find the Todo ACA App service, and click on the URL in the overview blade.
* Test the Pet Clinic application:
    If you have chosen to integrate with Azure DNS, point the browser to the custom URL of the Pet Clinic App, e.g. ```https://api-gateway.petclinic.aca-java-demo.DEVELOPMENT_ENVI.MY_COMPANY_DOMAIN.com``` - you can check the DNS records created. Alternatively, navigate to the newly created resource group and find the Api Gateway service, and click on the URL in the overview blade.
* Delete created resources by deleting all newly created resource groups from Azure Portal. This will remove resources created.
