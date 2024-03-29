otel-logs-pipeline:
  workers: 5
  delay: 10
  source:
    otel_logs_source:
      ssl: false
      port: 21892
  buffer:
    bounded_blocking:
  sink:
    - opensearch:
        hosts: ["https://opensearch-node1:9200"]
        username: "admin"
        password: "%%PLACEHOLDER%%"  # Replace with OPENSEARCH_ADMIN_PASSWORD value         
        insecure: true
        index_type: custom
        #index: raw-logs-%{yyyy.MM}
        index: raw-logs-${/attributes/log.attributes.EnvironmentName}-%{yyyy.MM}
        #max_retries: 20
        bulk_size: 4
#    - stdout:
        
otel-trace-pipeline:
  # workers is the number of threads processing data in each pipeline. 
  # We recommend same value for all pipelines.
  # default value is 1, set a value based on the machine you are running Data Prepper
  workers: 8 
  # delay in milliseconds is how often the worker threads should process data.
  # Recommend not to change this config as we want the otel-trace-pipeline to process as quick as possible
  # default value is 3_000 ms
  delay: "100" 
  source:
    otel_trace_source:
      ssl: false # Change this to enable encryption in transit
      port: 21890
  buffer:
    bounded_blocking:
      # buffer_size is the number of ExportTraceRequest from otel-collector the data prepper should hold in memeory. 
      # We recommend to keep the same buffer_size for all pipelines. 
      # Make sure you configure sufficient heap
      # default value is 12800
      buffer_size: 25600
      # This is the maximum number of request each worker thread will process within the delay.
      # Default is 200.
      # Make sure buffer_size >= workers * batch_size
      batch_size: 400
  sink:
    - pipeline:
        name: "raw-traces-pipeline"
    - pipeline:
        name: "otel-service-map-pipeline"

raw-traces-pipeline:
  workers: 5
  delay: 3000
  source:
    pipeline:
      name: "otel-trace-pipeline"
  buffer:
    bounded_blocking:
      buffer_size: 25600 # max number of records the buffer accepts
      batch_size: 400 # max number of records the buffer drains after each read
  processor:
    - otel_trace_raw:
    - otel_trace_group:
        hosts: [ "https://opensearch-node1:9200" ]
        insecure: true
        username: "admin"
        password: "%%PLACEHOLDER%%"  # Replace with OPENSEARCH_ADMIN_PASSWORD value
  sink:
    - opensearch:
        hosts: ["https://opensearch-node1:9200"]
        username: "admin"
        password: "%%PLACEHOLDER%%"  # Replace with OPENSEARCH_ADMIN_PASSWORD value  
        insecure: true
        trace-analytics-raw: true
        index-type: custom
        index: otel-v1-apm-span-${/attributes/span.attributes.EnvironmentName}-%{yyyy.MM}
        
otel-service-map-pipeline:
  workers: 5
  delay: 3000
  source:
    pipeline:
      name: "otel-trace-pipeline"
  processor:
    - service_map_stateful:
        # The window duration is the maximum length of time the data prepper stores the most recent trace data to evaluvate service-map relationships. 
        # The default is 3 minutes, this means we can detect relationships between services from spans reported in last 3 minutes.
        # Set higher value if your applications have higher latency. 
        window_duration: 180 
  buffer:
      bounded_blocking:
        # buffer_size is the number of ExportTraceRequest from otel-collector the data prepper should hold in memeory. 
        # We recommend to keep the same buffer_size for all pipelines. 
        # Make sure you configure sufficient heap
        # default value is 12800
        buffer_size: 25600
        # This is the maximum number of request each worker thread will process within the delay.
        # Default is 200.
        # Make sure buffer_size >= workers * batch_size
        batch_size: 400
  sink:
    - opensearch:
        hosts: ["https://opensearch-node1:9200"]
        username: "admin"
        password: "%%PLACEHOLDER%%"  # Replace with OPENSEARCH_ADMIN_PASSWORD value  
        insecure: true
        trace-analytics-service-map: true
        index-type: custom
        index: otel-v1-apm-service-map-%{yyyy.MM}
        #max_retries: 20
        bulk_size: 4   
        
otel-metrics-pipeline:
  workers: 8
  delay: 3000
  source:
    otel_metrics_source:
      health_check_service: true
      ssl: false
      port: 21891
#  buffer:
#    bounded_blocking:
#      buffer_size: 1024 # max number of records the buffer accepts
#      batch_size: 1024 # max number of records the buffer drains after each read
  processor:
    - otel_metrics_raw_processor:
#    - otel_metrics:
#        calculate_histogram_buckets: true
#        calculate_exponential_histogram_buckets: true
#        exponential_histogram_max_allowed_scale: 10
#        flatten_attributes: false
  sink:
    - opensearch:
        hosts: ["https://opensearch-node1:9200"]
        username: "admin"
        password: "%%PLACEHOLDER%%"  # Replace with OPENSEARCH_ADMIN_PASSWORD value  
        insecure: true
        index_type: custom
        index: metrics-otel-v1-${/attributes/metric.attributes.EnvironmentName}-%{yyyy.MM}
        #max_retries: 20
        bulk_size: 4
