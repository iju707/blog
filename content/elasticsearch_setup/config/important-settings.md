---
title: 중요 엘라스틱서치 구성
draft: true
linkTitle: 중요구성
type: docs
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

## 네트워크 호스트 설정

## 디스커버리 설정

## 힙크기 설정

## JVM 힙덤프 경로 설정

## GC 로깅 설정

## 임시 디렉터리 설정

## JVM 치명적 오류로그 설정

## 클러스터 백업