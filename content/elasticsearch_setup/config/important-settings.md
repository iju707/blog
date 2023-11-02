---
title: 중요 엘라스틱서치 구성
draft: false
linkTitle: 중요구성
type: docs
date: 2023-11-01T01:48:00+09:00
---

> [https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html)

엘라스틱서치는 시작하는데 아주 작은 설정을 요구하지만 운영환경에서 클러스터를 구성하는데 **필수로** 고려해야될 다수의 설정이 있습니다.

* [경로 설정](#경로-설정)
* [클러스터명 설정](#클러스터명-설정)
* [노드명 설정](#노드명-설정)
* [네트워크 호스트 설정](#네트워크-호스트-설정)
* [디스커버리 설정](#디스커버리-설정)
* [힙크기 설정](#힙크기-설정)
* [JVM 힙덤프 경로 설정](#jvm-힙덤프-경로-설정)
* [GC 로깅 설정](#gc-로깅-설정)
* [임시 디렉터리 설정](#임시-디렉터리-설정)
* [JVM 치명적 오류로그 설정](#jvm-치명적-오류로그-설정)
* [클러스터 백업](#클러스터-백업)

[Elastic Cloud](https://www.elastic.co/cloud/elasticsearch-service/signup?page=docs&placement=docs-body) 서비스에서 이러한 설정을 자동으로 구성하며 기본적으로 운영환경에 바로 사용하 수 있도록 클러스터를 만들어줍니다.

## 경로 설정

엘라스틱서치는 인덱싱된 인덱스 데이터와 스트림 데이터를 `data` 디렉터리에 저장합니다.
클러스터 상태 및 동작 등의 정보를 포함한 어플리케이션 로그를 `logs` 디렉터리에 저장합니다.

[macOS `.tar.gz`](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html), [Linux `.tar.gz`](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html), [Windows `.zip`](https://www.elastic.co/guide/en/elasticsearch/reference/current/zip-windows.html) 설치에서는 `data`와 `logs`가 `$ES_HOME`의 하위 디렉터리로 기본설정 되어있습니다.
그러나 `$ES_HOME`의 파일은 업그레이드때 삭제될 가능성이 있습니다.

운영환경에서 `elasticsearch.yml`의 `path.data`와 `path.logs`를 `$ES_HOME` 밖으로 설정하길 권장합니다.
[Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html), [Debian](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html), [RPM](https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html) 패키지로 설치한 경우 기본적으로 `$ES_HOME`의 밖 위치에서 데이터와 로그를 기록합니다.

플랫폼에 따라 `path.data`와 `path.logs` 값이 다르게 지원됩니다.

{{< tabs items="Unix 시스템,Windows" >}}
{{< tab >}}
리눅스와 macOS 설치는 Unix 스타일 경로를 지원합니다.

```yaml
path:
  data: /var/data/elasticsearch
  logs: /var/log/elasticsearch
```
{{< /tab >}}
{{< tab >}}
Windows 설치는 이스케이프된 백슬래시와 DOS 경로를 지원합니다.

```yaml
path:
  data: "C:\\Elastic\\Elasticsearch\\data"
  logs: "C:\\Elastic\\Elasticsearch\\logs"
```
{{< /tab >}}
{{< /tabs >}}

{{< callout type="warning" >}}
절대 데이터 디렉터리안을 수정하거나 안의 내용을 방해하는 프로세스를 실행하면 안됩니다.
엘라스틱서치가 아닌 다른 것이 데이터 디렉터리의 내용을 수정한다면, 엘라스틱서치는 오류가 발생하여 손상이나 데이터 불일치가 보고되거나 올바르게 작동하긴 하지만 일부 데이터가 손실될 수 있습니다.

데이터 디렉터리 자체를 파일시스템 백업으로 수행하지 마세요.
대신, [스냅샷과 복구](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshot-restore.html)를 활용하여 안전하게 백업하세요.

데이터 디렉터리에 바이러스 검사를 수행하지 마세요.
바이러스 검사기가 엘라스틱서치의 정상작동을 막고 데이터 디렉터리의 내용을 수정할 수 있습니다.
데이터 디렉터리에는 실행파일이 없으므로 거짓된 긍정만 발견될 수 있습니다.
{{< /callout >}}

## 다중 데이터 경로

{{< callout type="warning" >}}
7.13.0부터 더이상 사용되지 않음
{{< /callout >}}

필요하다면, `path.data`에 다중경로를 설정할 수 있습니다.
엘라스틱서치는 모든 제공되는 경로 전반적으로 노드의 데이터를 저장하지만 각각 샤드는 동일한 경로에 저장합니다.

엘라스틱서치는 노드의 데이터 경로에 샤드의 균형을 맞추지는 않습니다.
단일 경로에 높은 디스크 사용률은 노드 전체에 [높은 디스크 사용량 워터마크](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-cluster.html#disk-based-shard-allocation)를 발생시킵니다.
발생된다면 엘라스틱서치는 해당 노드의 다른 경로에 충분한 디스크 용량이 있더라도 샤드를 추가하지 않습니다.
추가적인 디스크 공간이 필요하다면, 추가 데이터 경로보다는 신규 노드를 추천합니다.

{{< tabs items="Unix 시스템,Windows" >}}
{{< tab >}}
리눅스와 macOS 설치는 `path.data`에 Unix 스타일의 다중 경로를 지원합니다.

```yaml
path:
  data:
    - /mnt/elasticsearch_1
    - /mnt/elasticsearch_2
    - /mnt/elasticsearch_3
```
{{< /tab >}}
{{< tab >}}
Windows 설치는 `path.data`에 DOS의 다중 경로를 지원합니다.

```yaml
path:
  data:
    - "C:\\Elastic\\Elasticsearch_1"
    - "E:\\Elastic\\Elasticsearch_2"
    - "F:\\Elastic\\Elasticsearch_3"
```
{{< /tab >}}
{{< /tabs >}}

## 다중 데이터 경로에서 마이그레이션하기

다중 데이터 경로 지원은 7.13부터 사용되지 않으며 추후 릴리즈에서 삭제될 예정입니다.

다중 데이터 경로대신 RAID와 같은 하드웨어 가상화 계층 또는 리눅스에서 논리 볼륨 관리자(LVM, Logical Volume Manager)나 윈도우의 저장소 공간(Storage Spaces)와 같은 소프트웨어 가상화 계층으로 다수의 디스크를 묶은 파일시스템을 생성할 수 있습니다.
하나의 장비에서 다수의 데이터 경로를 사용하고 싶다면 필히 데이터 경로마다 노드를 실행해야합니다.

현재 [고가용성 클러스터](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/high-availability-cluster-design.html)에 다중 데이터 경로를 사용하고 있다면 각각 노드에 단일 경로를 사용하도록 [롤링 시작](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/restart-cluster.html#restart-cluster-rolling)과 유사한 절차를 사용하여 중단시간 없이 설정을 마이그레이션 해야합니다.
각각 노드가 차례로 중단 되면서 단일 데이터 경로로 구성된 하나이상의 노드로 교체됩니다.
더 자세한 것은 현재 다중 데이터 경로를 가지고 있는 각각의 노드에 대하여 아래 프로세스를 수행해야 합니다.
원칙적으로 이 마이그레이션을 8.0으로 롤링업그레이드 할 때 가능하나, 단일 데이터 경로 구성 후 업그레이드 시작을 권장합니다.

1. 장애에 대비하여 데이터보호를 위해 스냅샷을 수행합니다.

2. 선택적으로, [할당 필터](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/modules-cluster.html#cluster-shard-allocation-filtering)를 사용하여 대상 노드를 데이터에서 떼어놓습니다.
  ```bash
  PUT _cluster/settings
  {
    "persistent": {
      "cluster.routing.allocation.exclude._name": "target-node-name"
    }
  }
  ```
  [할당 보기 API](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/cat-allocation.html)를 통해 이 데이터 마이그레이션 처리과정을 추적할 수 있습니다.
  일부 샤드가 마이그레이션이 안되면 [클러스터 할당 설명 API](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/cluster-allocation-explain.html)를 통해 왜 안되는지 확인이 가능합니다.

3. 대상 노드 중단을 포함하여 [롤링 시작 프로세스](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/restart-cluster.html#restart-cluster-rolling)의 단계를 따르세요.

4. 클러스터의 상태가 `yello`나 `green`이면 모든 샤드의 복제가 클러스터내 적어도 다른 노드 하나에 할당 되었다는 것 입니다.

5. 적용이 되면, 이전 단계에서 적용한 할당 필터를 제거합니다.
  ```bash
  PUT _cluster/settings
  {
    "persistent": {
      "cluster.routing.allocation.exclude._name": null
    }
  }
  ```
6. 데이터 경로의 내용를 삭제하여 중지된 노드가 보유한 데이터를 폐기해야합니다.

7. 저장소를 재구성합니다. 예로, LVM이나 저장소 공간을 사용한 단일 파일시스템으로 디스크를 결합합니다. 재구성된 저장소에 보유한 데이터를 위한 충분한 공간이 있는지 확인합니다.

8. `elasitcsearch.yml` 파일의 `path.data` 설정을 조정하여 노드를 재구성합니다. 필요하면 분리된 데이터 경로를 `path.data`로 설정하여 추가적인 노드를 설치합니다.

9. 새 노드를 시작하고 [롤링 시작 절차](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/restart-cluster.html#restart-cluster-rolling)의 나머지를 따라합니다.

10. 클러스터의 상태가 `green`임을 확인합니다. 그럼 모든 샤드가 할당되었습니다.

다른 방법으로는 단일 데이터 경로 노드를 클러스터에 추가하고 [할당 필터](https://www.elastic.co/guide/en/elasticsearch/reference/8.10/modules-cluster.html#cluster-shard-allocation-filtering)를 사용하여 새로운 노드에 데이터 전반을 마이그레이션하고 클러스터에서 이전 노드를 삭제합니다.
이 방법은 순간적으로 클러스터의 크기를 두배로 사용되기 때문에 가능한 용량이 있는지 확인하고 진행해야합니다.

현재 다중 데이터 경로를 사용하고 클러스터의 가용성이 높지 않은 경우 스냅샷을 만들고 원하는 구성으로 클러스터를 생성한 뒤 복원하여 더 이상 사용하지 않는 구성으로 마이그레이션할 수 있습니다.

## 클러스터명 설정

노드는 클러스터의 다른 모든 노드와 동일한 `cluster.name`을 공유할때만 합류할 수 있습니다. 기본값은 `elasticsearch` 입니다. 클러스터 목적에 따라 적절한 이름으로 변경도 가능합니다.

```yaml
cluster.name: logging-prod
```

{{< callout type="warning" >}}
절대로 다른 환경에서 동일한 클러스터명을 사용하지 마세요.
그렇지 않으면 원치않게 노드가 다른 클러스터로 합류할 수 있습니다.
{{< /callout >}}

{{< callout type="info" >}}
클러스터명의 변경은 [클러스터 전체 재시작](https://www.elastic.co/guide/en/elasticsearch/reference/current/restart-cluster.html#restart-cluster-full)이 필요합니다.
{{< /callout >}}

## 노드명 설정

엘라스틱서치는 `node.name`를 사용해서 엘라스틱서치의 특정 인스턴스에 대한 사람이 읽을 수 있는 식별자 지정이 가능합니다.
이 이름은 많은 API 응답에 포함됩니다.
엘라스틱서치가 시작될 때 장치의 호스트명이 기본값으로 설정되나 명시적으로 `elasticsearch.yml`에 구성할 수 있습니다.

```yaml
node.name: prod-data-2
```

## 네트워크 호스트 설정

기본적으로 엘라스틱서치는 `127.0.0.1` 또는 `[::1]`과 같은 루프백 주소에만 바인딩됩니다.
이것은 개발 또는 테스트 목적으로 단일 서버에 한개이상의 노드로 클러스터를 실행할때 적합합니다.
그러나, [탄력적인 운영환경 클러스터](https://www.elastic.co/guide/en/elasticsearch/reference/current/high-availability-cluster-design.html)는 다른서버의 노드를 포함해야합니다.
다양한 [네트워크 설정](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-network.html)이 있지만 보통 필요한 설정은 `network.host` 입니다.

```yaml
network.host: 192.168.1.10
```

{{< callout type="warning" >}}
`network.host`의 값을 설정할 때 엘라스틱서치는 개발모드에서 운영모드로 전환된다고 가정하고 시스템 시작 확인의 다수를 경고에서 예외로 변경합니다.
[개발과 운영 모드](https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html#dev-vs-prod)의 차이를 살펴보세요.
{{< /callout >}}

## 디스커버리 설정

두가지 중요한 디스커버리와 클러스터 형성 설정을 운영에 가기전에 구성해서 클러스터의 노드가 서로를 탐색하고 마스터 노드를 선출할 수 있게 합니다.

`discovery.seed_hosts`

네트워크 구성없이 즉시사용할 경우 엘라스틱서치는 사용가능한 루프백 주소에 바인딩되고 `9300`부터 `9305`까지 동일한 서버에 다른 노드가 실행중인지 로컬포트를 스캔합니다.
이 동작으로 다른 구성없이 자동 클러스터링 경험을 제공합니다.

다른 호스트의 노드와의 클러스터 형태를 원한다면, [정적](../#고정형) `discovery.seed_hosts` 설정을 사용합니다.
이 설정은 [디스커버리 절차]의 시작이 가능한 살아있고 접근가능한 클러스터의 다른 마스터적격 노드 목록을 제공합니다.
이 설정은 클러스터의 마스터적격 노드의 모든 주소를 YAML 시퀀스나 목록으로 설정됩니다.
각각의 주소는 IP 주소 또는 DNS를 통해 한개이상의 IP 주소로 변경이 가능한 호스트명으로 구성됩니다.

```yaml
discovery.seed_hosts:
  - 192.168.1.10:9300
  - 192.168.1.11
  - seeds.mydomain.com
  - [0:0:0:0:0:ffff:c0a8:10c]:9301
```

- 포트는 기본값으로 `9300`입니다. [덮어쓸 수 있습니다.](https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-hosts-providers.html#built-in-hosts-providers)
- 호스트명이 다수의 IP로 해석이되면, 노드는 확인된 모든 주소에서 다른 노드를 찾으려고 시도합니다.
- IPv6 주소는 대괄호로 묶여야합니다.

마스터적격 노드가 고정된 이름 또는 주소가 없을 경우 주소를 동적으로 찾을 수 있도록 [대안 호스트 제공자](https://www.elastic.co/guide/en/elasticsearch/reference/current/discovery-hosts-providers.html#built-in-hosts-providers)를 사용할 수 있습니다.

`cluster.initial_master_nodes`

엘라스틱서치가 최초 동작시, [클러스터 부트스트래핑](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-bootstrap-cluster.html) 절차에서 최초선거의 투표가 집계되는 마스터적격 노드의 집합을 결정합니다.

자동-부트스트래핑은 [잠재적으로 불안정](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-quorums.html)하기 때문에 운영모드의 새로운 클러스터를 시작할 때 가장 최초선거에서 투표 집계가 되는 마스터적격 노드를 명시적으로 목록화 해야합니다.
이 목록은 `cluster.initial_master_nodes`를 사용하여 설정할 수 있습니다.

{{< callout type="warning" >}}
최초 클러스터 구성이 성공하면 각각 노드 구성의 `cluster.initial_master_nodes` 설정을 제거합니다.
클러스터를 재시작할 때 또는 기존 클러스터에 새로운 노드를 추가할 때 이 설정을 사용하면 안됩니다.
{{< /callout >}}

```yaml
discovery.seed_hosts:
  - 192.168.1.10:9300
  - 192.168.1.11
  - seeds.mydomain.com
  - [0:0:0:0:0:ffff:c0a8:10c]:9301
cluster.initial_master_nodes:
  - master-node-a
  - master-node-b
  - master-node-c
```

- 호스트명이 기본값으로 사용되는 [`node.name`](https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html#node-name)으로 초기 마스터노드를 식별합니다.
  `cluster.initial_master_nodes`의 값에 `node.name`가 명확히 일치해야합니다.
  노드명에 `master-node-a.example.com`과 같은 정규화된 도메인명(FQDN, Fully-Qualified Domain Name)을 사용한다면 목록에 FQDN을 사용해야합니다.
  반대로, `node.name`이 후행 한정자가 없는 순수 호스트이름인 경우 `cluster.initial_master_nodes`에서 후행 한정자를 생략해야합니다.

[클러스터 부트스트래핑](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-bootstrap-cluster.html)과 [디스커버리와 클러스터 형성 설정](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-discovery-settings.html)을 참고하세요.

## 힙크기 설정

기본적으로 엘라스틱서치는 JVM 힙크기를 노드의 [역할](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#node-roles)과 전체 메모리를 기반으로 자동설정합니다.
대부분의 운영환경에서는 기본크기를 권장합니다.

필요하다면 기본크기를 [JVM 힙 크기 설정](https://www.elastic.co/guide/en/elasticsearch/reference/current/advanced-configuration.html#set-jvm-heap-size)으로 설정할 수 있습니다.

## JVM 힙덤프 경로 설정

엘라스틱서치는 기본적으로 데이터 디렉터리에 메모리초과 오류가 발생하면 힙덤프를 받도록 JVM 설정이 되어있습니다.
[RPM](https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html)과 [Debian](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html) 패키지에서 데이터 디렉터리는 `/var/lib/elasticsearch`입니다.
[리눅스와 맥](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html), [윈도우](https://www.elastic.co/guide/en/elasticsearch/reference/current/zip-windows.html) 배포판은 `data` 디렉터리가 엘라스틱서치 설치의 상위디렉터리에 위치해있습니다.

이 경로가 힙덤프를 받기 적절치 않으면, [`jvm.options`](https://www.elastic.co/guide/en/elasticsearch/reference/current/advanced-configuration.html#set-jvm-options)의 `-XX:HeapDumpPath=...`를 수정합니다.

- 디렉터리를 지정하면 JVM이 실행중인 인스턴스의 PID를 기반으로 힙덤프 파일명을 생성합니다.
- 디렉터리 대신 고정된 파일명으로 지정하면 JVM이 메모리초과 오류가 발생해서 힙덤프를 만들 때 파일이 있으면 안됩니다.
  그렇지 않으면 힙덤프는 실패합니다.

## GC 로깅 설정

엘라스틱서치는 가비지컬렉션(GC) 로그를 활성화합니다.
`jvm.options`에서 구성할 수 있고 엘라스틱서치 로그의 동일 기본경로에 출력됩니다.
기본 구성은 매 64MB 마다 로그가 순환되고 디스크공간을 최대 2GB 사용합니다.

[JEP 158: Unified JVM Logging](https://openjdk.java.net/jeps/158)에 설명된 것 처럼 명령줄 옵션으로 JVM 로깅을 재구성할 수 있습니다.
기본 `jvm.options` 파일을 직접 변경하지 않으면 엘라스틱서치는 기본 구성에 설정을 추가합니다.
기본 구성을 비활성화 하려면 `-xlog:disable`로 최초 로깅을 비활성화 한 뒤 명령줄 옵션을 적용합니다.
이렇게 하면 모든 JVM 로깅을 비활성화되기 때문에 사용가능한 옵션을 확인하고 필요한 모든것을 활성화 해야합니다.

JEP 원본에 포함되지 않은 많은 옵션은 [JVM Unified Logging 프레임워크로 로깅활성화](https://docs.oracle.com/en/java/javase/13/docs/specs/man/java.html#enable-logging-with-the-jvm-unified-logging-framework)를 참고하세요.

### JVM 예제

몇몇 샘플 옵션과 함께 `/opt/my-app/gc.log`로 기본 GC 로그 출력위치를 변경하는 `$ES_HOME/config/jvm.options.d/gc.options`파일 예제입니다.

```
# 모든 로그설정을 비활성화 합니다.
-Xlog:disable

# JEP 158의 기본설정이지만 다음줄과 일치하도록 `uptime` 대신 `utctime`을 사용합니다.
-Xlog:all=warning:stderr:utctime,level,tags

# 다양한 옵션과 사용자정의 위치로 GC 로깅을 활성화 합니다.
-Xlog:gc*,gc+age=trace,safepoint:file=/opt/my-app/gc.log:utctime,level,pid,tags:filecount=32,filesize=64m
```

엘라스틱서치 [Docker 컨테이너]가 GC 디버그 로그를 표준 에러(`stderr`)로 전송할 수 있도록 구성합니다.
이를 통해 컨테이너 오케스트레이터가 출력을 다룰 수 있습니다.
`ES_JAVA_OPTS` 환경변수를 사용하면 다음과 같이 지정하세요.

```
MY_OPTS="-Xlog:disable -Xlog:all=warning:stderr:utctime,level,tags -Xlog:gc=debug:stderr:utctime"
docker run -e ES_JAVA_OPTS="$MY_OPTS" # etc
```

## 임시 디렉터리 설정

엘라스틱서치는 시작스크립트에서 시스템 임시 디렉터리 하위에 바로 개별 임시 디렉터리를 생성하여 사용합니다.

몇몇 리눅스 배포판에는 시스템유틸리티가 최근 접근하지 않았으면 `/tmp`에 파일과 디렉터리를 청소합니다.
이 동작은 엘라스틱서치가 동작중일 때 임시 디렉터리를 사용하는 기능이 장기간 사용되지 않으면 개별 임시 디렉터리 또한 삭제된다는 것 입니다.
이 기능이 나중에 다시 사용되면 개별 임시 디렉터리가 삭제됨으로 문제가 발생할 수 있습니다.

`.deb`나 `.rpm` 패키지를 사용하여 엘라스틱서치를 설치하고 `systemd` 하위에 실행된다면 개별 임시 디렉터리는 정기적 정리대상에서 제외됩니다.

장기간동안 리눅스나 맥의 `.tar.gz` 배포판을 실행한 경우 오래된 파일이나 디렉터리가 정리되는 경로 하위말고 다른 위치에 임시 디렉터리 생성을 고려해야합니다.
이 디렉터리는 엘라스틱서치를 실행한 사용자가 접근할 수 있도록 권한을 설정해야합니다.
그리고 엘라스틱서치가 실행할 때 `$EV_TMDIR` 환경변수로 설정하여 해당 위치를 가리킵니다.

## JVM 치명적 오류로그 설정

엘라스틱서치는 기본 로깅 디렉터리에 fatal 에러 로그를 작성하도록 JVM을 구성합니다.
[RPM](https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html)과 [Debian](https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html) 패키지는 이 디렉터리가 `/var/log/elasticsearch` 입니다.
[리눅스와 맥](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html)과 [윈도우](https://www.elastic.co/guide/en/elasticsearch/reference/current/zip-windows.html) 배포판의 `logs` 디렉터리는 엘라스틱서치 설치의 상위 디렉터리에 위치합니다.

세그먼트폴트와 같은 fatal 에러가 발생하면 JVM이 생성하는 로그가 있습니다.
로그를 받기 경로가 적절치 않다면 [`jvm.options`](https://www.elastic.co/guide/en/elasticsearch/reference/current/advanced-configuration.html#set-jvm-options)의 `-XX:ErrorFile=...` 항목을 수정하세요.

## 클러스터 백업

재해시 [스냅샷](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshot-restore.html)은 영구적 데이터 손실을 방지합니다.
[스냅샷 생명주기 관리](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html#automate-snapshots-slm)는 클러스터의 일반적인 백업을 쉽게 생성하는 방법입니다.
자세한 정보는 [스냅샷을 생성](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)을 참고하세요.

{{< callout type="warning" >}}
**스냅샷을 만드는 것이 클러스터를 백업하는 안정적이고 지원되는 유일한 방법입니다.**
노드의 데이터 디렉터리만 복사하는 것으로 엘라스틱서치 클러스터를 백업할 수 없습니다.
파일시스템수준 백업으로 데이터를 복구하는 방법을 지원하지 않습니다.
이러한 백업으로 클러스터를 복구하면 손상, 누락된 파일 또는 기타 데이터 불일치로 보고되어 실패하거나 성공으로 보이나 부분적 데이터 손실이 발생할 수 있습니다.
{{< /callout >}}