# Ready-to-use OpenSearch OpenTelemetry docker-compose file

This repository contains a docker-compose file and acompanying files which can help in quickly getting an 
OpenSearch cluster running with an OpenTelemetry ingestion pipeline using OpenTelemetry Collector and Data Prepper.

Planned architecture is having a reverse proxy in front of the OpenTelemetry Collector to authenticate clients. 
The scripts assume the proxy adds a `X-Authenticated-User` header, which will be used by the pipelines and configurations in thie repository
to segment indexes. (Further in this readme, the term Tenants will be used for unique `X-Authenticated-User` values)

# (Planned) Features

This repository is a work-in-progress. Below is a list of features and planned features:

- [x] Ingestion into OpenSearch works
- [x] Using OpenSearch Dashboards, data should be viewable
- - [x] Traces are correctly shown in Observability Dashboards
- - [ ] Logging are not visible yet. Going to Observability - Applications, selecting an Application and navigating to the Logs tab shows an empty page.
- - [ ] Metrics are not shown. 
- [ ] Set of indexes per tenant. Status per index category:
- - [ ] Metrics 
- - [ ] Raw logs
- - [ ] Spans
- - [ ] Service map