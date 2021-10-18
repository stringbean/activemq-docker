# ActiveMQ Docker Images

```sh
docker run -p 8161:8161 -p 61616:61616 ghcr.io/stringbean/activemq-docker
```

## Exposed Ports

| Port  | Description         |
|-------|---------------------|
| 8161  | Admin web interface |
| 61616 | OpenWire protocol   |
| 5672  | AMQP protocol       |
| 6163  | Stomp protocol      |
| 1883  | MQTT protocol       |

## Exposed Volumes

| Path                     | Description           |
|--------------------------|-----------------------|
| `/var/lib/data/activemq` | Main data & log files |
| `/var/tmp/activemq`      | Temporary files       |