# Ready-to-use OpenSearch OpenTelemetry docker-compose file

This repository contains a docker-compose file and acompanying files which can help in quickly getting an 
OpenSearch cluster running with an OpenTelemetry ingestion pipeline using OpenTelemetry Collector and Data Prepper.

Planned architecture is having a reverse proxy in front of the OpenTelemetry Collector to authenticate clients. 
The scripts assume the proxy adds a `X-Authenticated-User` header, which will be used by the pipelines and configurations in this repository
to segment indexes. (Further in this readme, the term Tenants will be used for unique `X-Authenticated-User` values)

# Security warning

This repository plans to act as a starting point for getting things working. This does not mean all aspects are perfect. Please pay attention to details yourself!

# (Planned) Features

This repository is a work-in-progress. Below is a list of features and planned features:

- - [x] Ingestion into OpenSearch works
- - [x] Using OpenSearch Dashboards, data should be viewable
- - - [x] Traces are correctly shown in Observability Dashboards
- - - [ ] Logging are not visible yet. Going to Observability - Applications, selecting an Application and navigating to the Logs tab shows an empty page.
- - - [ ] Metrics are not shown. 
- - [ ] Set of indexes per tenant. Status per index category:
- - - [ ] Metrics 
- - - [ ] Raw logs
- - - [ ] Spans
- - - [ ] Service map



# Requirements

For running this `docker-compose` file, you need a Linux host running docker. 

# Getting started

1. The `docker-compose` file in this repository requires the following environment variables (or entries in the `.env` file):
    1. `OPENSEARCH_ADMIN_PASSWORD` - The initial OpenSearch password 
    2. `MASTER_ENCRYPTION_KEY` - The encryption key used for storing secrets.
2. Copy the file `data-prepper/pipelines.yaml.tpl` to `data-pepper/pipelines.yaml` and replace all `%%PLACEHOLDER%%` values with real values. The line will contain a comment saying what to fill.


# Random todo's

1. Find a way to fill the `OPENSEARCH_ADMIN_PASSWORD` in the `data-pepper/pipelines.yaml` file
