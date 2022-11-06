### Configuration files for Grafana & Prometheus Monitoring Stack

Prometheus will scrape Gateway (acai), Auth Service (durian), Persist Service (kiwi) metrics,
for: `Ecto.Repo`, `Phoenix`, `Beam`

To start monitoring the system on local development (services on host machine).
```shell
cd local
docker compose up --build
```

`prod` - config used in main [`docker-compose.yml`](../docker-compose.yml)

### Dashboard Examples

### Prometheus Scrape Targets
![prometheus_targets](./dashboard-images/prometheus_targets.png)

### Prometheus Query (Auth Service Ecto metrics)
![prometheus_query](./dashboard-images/prometheus_durian.png)

### Prometheus Graph (Gateway all channel connections - topic join events)
![prometheus_graph](./dashboard-images/prometheus_graph.png)

### Grafana (Gateway Beam metrics)
![acai_beam](./dashboard-images/acai_beam.png)

### Grafana (Gateway Channel joins)
![acai_channel_joins](./dashboard-images/acai_channel_joins.png)

### Grafana (Gateway Socket metrics)
![acai_channel_joins](./dashboard-images/acai_socket_details.png)

### Grafana (Persist Service Ecto general metrics)
![acai_channel_joins](./dashboard-images/kiwi_ecto.png)

### Grafana (Persist Service Ecto query metrics)
![acai_channel_joins](./dashboard-images/kiwi_ecto_query_metrics.png)

### Grafana (Persist Service Ecto - Average query execution time metrics)
![acai_channel_joins](./dashboard-images/kiwi_ecto_query_time.png)