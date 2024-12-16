## iris-global-yaml

 [![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/iris-global-yaml)
 [![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-global-yaml&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-global-yaml)
 <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/intersystems-community/iris-global-yaml">

This is an API to do CRUD operations on InterSystems IRIS globals.
It also has OPEN API spec, 
can be developed with Docker and VSCode,
can ve deployed as ZPM module.

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation with ZPM

zpm:USER>install iris-global-yaml

## Installation with Docker

Create your repository from template.

Clone/git pull the repo into any local directory e.g. like it is shown below (here I show all the examples related to this repository, but I assume you have your own derived from the template):

```
$ git clone https://github.com/yurimarx/iris-global-yaml.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```

## How to Work With it

1. Try import to your postman this file (on root folder): iris-global-yaml.postman_collection.json.

2. This API creates /iris-global-yaml REST web-application on IRIS which implements 4 types of communication: GET, POST, PUT and DELETE aka CRUD operations on Globals. Open http://[your server]:[your web port]/swagger-ui/index.html to test the REST API