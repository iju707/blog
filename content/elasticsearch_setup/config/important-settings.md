---
title: 중요 엘라스틱서치 구성
draft: true
linkTitle: 중요구성
type: docs
---

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
## 클러스터명 설정

## 노드명 설정

## 네트워크 호스트 설정

## 디스커버리 설정

## 힙크기 설정

## JVM 힙덤프 경로 설정

## GC 로깅 설정

## 임시 디렉터리 설정

## JVM 치명적 오류로그 설정

## 클러스터 백업