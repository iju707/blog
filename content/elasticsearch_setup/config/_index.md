---
title: Elasticsearch 구성하기
draft: false
linkTitle: Elasticsearch 구성
type: docs
---

> https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html

엘라스틱서치는 좋은 기본값을 가지고 아주 약간의 구성을 요구하고 있습니다.
대부분의 설정은 [클러스터 설정 갱신 API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html)를 사용하여 실행중인 클러스터를 변경할 수 있습니다.

구성 파일은 특정 노드에 한정된 설정(`node.name`과 경로) 또는 클러스터에 합류하기 위해 필요한 노드 설정(`cluster.name`와 `network.host`)을 포함하고 있습니다.

## 구성 파일 위치

엘라스틱서치는 3가지 구성파일을 가지고 있습니다.

* 엘라스틱서치 구성을 위한 `elasitcsearch.yml`
* 엘라스틱서치 JVM 설정의 구성을 위한 `jvm.options`
* 엘라스틱서치 로깅 구성을 위한 `log4j2.properties`

이 파일은 구성 디렉터리에 위치하며 기본 위치는 압축배포판(`tar.gz` 또는 `zip`) 또는 패키지배포판(데비안 또는 RPM 패키지) 설치한 방법에 따라 결정됩니다.

압축배포판에서 구성 디렉터리 경로는 기본적으로 `$ES_HOME/config`입니다.
구성 디렉터리의 위치는 아래처럼 `ES_PATH_CONF` 환경 변수로 변경할 수 있습니다.

```
ES_PATH_CONF=/path/to/my/config ./bin/elasticsearch
```

다른 방법으로는 명령줄 또는 쉘 프로파일에 `export`로 `ES_PATH_CONF` 환경변수를 설정하는 것 입니다.

패키지배포판에서는 구성 디렉터리 위치는 `/etc/elasticsearch`가 기본값입니다.
구성 디렉터리 위치는 동일하게 `ES_PATH_CONF` 환경변수로 변경할 수 있지만 쉘에서 설정하는 것은 아닙니다.
대신 변수는 `/etc/default/elasticsearch` (데비안 패키지), `/etc/sysconfig/elasticsearch` (RPM 패키지)에 위치해있습니다.
원하는 구성 디렉터리 위치로 변경을 위하여 이 파일에서 `ES_PATH_CONF=/etc/elasticsearch` 항목을 수정하면 됩니다.

## 구성 파일 포맷

구성 포맷은 [YAML](https://yaml.org/) 입니다.
아래는 데이터와 로그 디렉터리의 경로를 변경하는 예제입니다.

```yaml
path:
  data: /var/lib/elasticsearch
  logs: /var/log/elasticsearch
```

또한 설정을 단순하게 할 수 있습니다.

```yaml
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
```

YAML에서 스칼라가 아닌 값을 시퀀스로 작성할 수 있습니다.

```yaml
discovery.seed_hosts:
  - 192.168.1.10:9300
  - 192.168.1.11
  - seeds.mydomain.com
```

덜 일반적이긴 하지만, 배열형태로도 작성할 수 있습니다.

```yaml
discovery.seed_hosts: ["192.168.1.10:9300", "192.168.1.11", "seeds.mydomain.com"]
```

## 환경변수 대체편집

구성 파일에서 환경변수는 `${...}` 형식으로 참조가 가능하며 환경변수의 값으로 대체가 됩니다.
예로 들면,

```yaml
node.name: ${HOSTNAME}
network.host: ${ES_NETWORK_HOST}
```

환경변수의 값은 단순 문자열이어야 합니다.
쉼표로 구분된 문자열이 값으로 제공되면 엘라스틱서치에서 목록으로 파싱합니다.
예로 들어, 엘라스틱서치는 `${HOSTNAME}` 환경변수의 문자열 값을 목록으로 분할합니다.

```
export HOSTNAME="host1,host2"
```

## 클러스터와 노드 설정 유형

클러스터와 노드 설정은 어떻게 구성하냐에 따라 카테고리화 합니다.

### 동적형

[클러스터 설정 갱신 API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html)를 사용하여 동작중인 클러스터의 동적 설정을 구성하고 갱신할 수 있습니다.

클러스터 설정 갱신 API를 통해 업데이트한 것은 클러스터가 재시작되도 적용되는 영구적, 클러스터가 재시작되면 초기화되는 휘발성 설정이 있습니다.
또한 API를 통해 `null` 값을 설정해서 휘발성, 영구적 설정을 초기화할 수 있습니다.

동일한 설정을 다양한 방법으로 구성하면 엘라스틱서치는 설정을 아래 순서대로 적용합니다.

1. 휘발성 설정
2. 영구적 설정
3. `elasticsearch.yml` 설정
4. 기본 설정 값

예로 들어, 영구적 설정 또는 `elasticsearch.yml` 설정을 덮어쓰기 위해 휘발성 설정을 적용할 수 있습니다.
그러나, `elasticsearch.yml`을 변경한 설정은 정의된 휘발성 또는 영구적 설정을 덮어쓸수 없습니다.

### 고정형

고정형 설정은 `elasticsearch.yml`을 사용해서 시작안된 또는 중단된 노드에 구성할 수 있습니다.

고정형 설정은 클러스터의 관련있는 모든 노드에 설정해야 합니다.