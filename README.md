# Distributed version of the Spring PetClinic Sample Application built with Spring Cloud 

Clone of the  spring-petclinic-microservices GitHub Repo: [https://github.com/spring-petclinic/spring-petclinic-microservices](https://github.com/spring-petclinic/spring-petclinic-microservices), used to demonstrate deploying a distributed Spring Boot App into Azure Container Apps (ACA), while usilising other services as managed PostgreSQL database, Application Insights, Azure Key Vaults etc..

Application architecture and the original description of this Spring Boot app can be found [here](./README_orig.md).

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[![01-Infra](https://github.com/martinabrle/aca-java-demo/actions/workflows/00-infra.yml/badge.svg)](https://github.com/martinabrle/aca-java-demo/actions/workflows/00-infra.yml)

[![00-Init-Repository-Todo-App - Init Repo](https://github.com/martinabrle/aca-java-demo/actions/workflows/01-init-todo-app.yml/badge.svg)](https://github.com/martinabrle/aca-java-demo/actions/workflows/01-init-todo-app.yml)

[![00-Init-Repository-Pet-Clinic - Init Repo](https://github.com/martinabrle/aca-java-demo/actions/workflows/01-init-pet-clinic.yml/badge.svg)](https://github.com/martinabrle/aca-java-demo/actions/workflows/01-init-pet-clinic.yml)

## Different ways of deploying the app into Azure Container Apps (ACA)

![Architecture Diagram](./docs/aca-java-demo-architecture.drawio.png)

* [Deploying apps using Command Line Interface (AZ CLI) and Bicep templates](./docs/aca-bicep.md)
* [Deploying the app using GitHub Actions (CI/CD pipelines)](./docs/aca-github-actions.md)