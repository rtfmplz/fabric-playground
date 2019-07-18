# Docker default logging driver

Hyperledger-Fabric Network를 Docker 기반으로 운영할 때, 각 서비스 Container log를 관리하기 위한 목적으로 rsyslog와 logrotate를 사용할 수 있다.

적용하기전에 테스트하고 기록하기 위한 목적으로 간단한 예제를 작성하였다.

## Docker log by default

* Container의 stdout, stderr가 Host의 아래 경로에 JSON 파일로 기록된다.
* 이 파일은 신경쓰지 않으면 엄청 커져버린다.
  * /var/lib/docker/contrainers/[contrainer-id]/[contrainer-id]-json.log

### Check default log file

* Log를 확인 하기위해서는 아래 예와 같은 명령을 이용한다.

```bash
docker logs -f my_container
```

## Docker log w/ syslog

컨테이너의 로그는 기본 제공하는 JSON뿐만 아니라 별도의 로그 시스템을 사용해서 저장할 수 있다.

그 중 syslog driver를 사용하는 예제를 다룬다.

아래 docker-compose 파일로 test에 필요한 rsyslog server와 log를 생성하는 nginx server를 실행한다.

### docker-compose.yaml

```yaml
version: "3"

networks:
  basic:

services:
  rsyslog:
    image: rsyslog/rsyslog_base_centos7
    container_name: rsyslog
    ports:
        - 10514:10514
    volumes:
        - "./rsyslog.conf:/etc/rsyslog.conf"
        - "./log/nginx:/var/log/nginx"
    command: /sbin/rsyslogd -n
    networks:
        - basic

  rsyslog_nginx:
    image: nginx
    container_name: rsyslog_nginx
    ports:
        - 8080:80
    logging:
      # @see https://docs.docker.com/config/containers/logging/syslog/
      driver: syslog
      options:
        syslog-address: "udp://localhost:10514"
        syslog-facility: "local0"
        tag: "{{.Name}}"
    networks:
        - basic
    depends_on:
        - rsyslog
```

### rsyslog.conf.template

```yaml
module(load="imtcp")
input(type="imtcp" port="10514")

#local0.* /var/log/nginx/nginx.log
local0.debug;local0.info;local0.notice /var/log/nginx/access.log
local0.warn /var/log/nginx/error.log
```

severity를 이용해서 log의 내용을 구분해서 저장할 수 있다.

facility를 이용해서 서비스를(local0, local1, ..., local7)를 구분할 수 있다.

## Test

아래 명령으로 rsyslog, rsyslog_nginx container를 기동시킨다.

```bash
docker-compose up
```

정상적으로 기동되면 아래와 같은 로그가 출력된다.

```bash
rsyslog          | rsyslogd 8.33.0: running as pid 1, enabling container-specific defaults, press ctl-c to terminate rsyslog
rsyslog_nginx    | WARNING: no logs are available with the 'syslog' log driver
```

다른 shell에서 아래 명령을 실행하면 rsyslog의 volumes에 설정한 log 경로에 access.log 가 생성되고 로그가 쌓이는것을 확인할 수 있다.

```bash
curl localhost:8080
```

## Logrotate

[TODO] Logrotate 설정 추가하기
