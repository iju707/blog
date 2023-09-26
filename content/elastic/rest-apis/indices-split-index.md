---
title: 인덱스분할 API
draft: true
date: 2023-09-20
---

> [https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-split-index.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-split-index.html)

기존 인덱스를 추가적인 기본 샤드를 가진 새로운 인덱스로 분할합니다.

```Bash
POST /my-index-000001/_split/split-my-index-000001
{
    "settings": {
        "index.number_of_shards": 2
    }
}
```

```python
def test(self, aaa: int) -> None:
  pass
```

## 요청 {#split-index-api-request}

`POST /<index>/_split/<target-index>`

`PUT /<index>/_split/<target-index>`

## 사전조건 {#split-index-api-prereqs}

* 만약 엘라스틱서치의 보안기능이 활성화되어있다면, 작업할 인덱스에 대한 `manage` [권한](https://www.elastic.co/guide/en/elasticsearch/reference/current/security-privileges.html#privileges-list-indices)이 있어야 합니다.
* 인덱스를 분할하기 전에
  * 인덱스는 읽기 전용이어야 합니다.
  * [클러스터의 상태](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)는 그린이어야 합니다.

아래의 요청으로 인덱스를 읽기전용으로 만들 수 있습니다.

```Bash
PUT /my_source_index/_settings
{
  "settings": {
    "index.blocks.write": true 
  }
}
```
* 인덱스에 쓰기 동작을 방지하더라도 인덱스 삭제와 같은 메타데이터 변경은 허용됩니다.

현재 데이터 스트림에서 쓰고있는 인덱스는 분할할 수 없습니다.
현재 쓰고 있는 인덱스를 분할하기 위해서는 데이터 스트림이 먼저 [롤오버](https://www.elastic.co/guide/en/elasticsearch/reference/current/data-streams.html#data-streams-rollover)되어 새로운 인덱스에 쓰기를 해야 이전 인덱스의 분할이 가능합니다.

## 설명 {#split-index-api-desc}

분할 인덱스 API는 기존 인덱스의 기본 샤드를 두개 또는 그이상으로 분할하여 새로운 인덱스를 만들 수 있게 합니다.

인덱스를 분할할 수 있는 횟수(원래 샤드가 분할하여 변경되는 샤드 수)는 `index.number_of_routing_shards` 설정으로 결정됩니다.
라우팅 샤드의 수는 일관된 해싱으로 문서를 내부적으로 분산하도록 하는 해싱 공간을 정의합니다.
예로, 5개 샤드를 가진 인덱스가 `number_of_routing_shards`를 `30` (`5 x 2 x 3`)으로 설정하면 `2` 또는 `3`의 배수로 나뉘게 됩니다.
다시 설명하면 아래와 같이 분산됩니다.

* `5` > `10` > `30` (2로 분할 후 3으로 분할)
* `5` > `15` > `30` (3으로 분할 후 2로 분할)
* `5` > `30` (6으로 분할)

`index.number_of_routing_shards`는 [정적 인덱스 설정](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#index-modules-settings) 입니다.
따라서 `index.number_of_routing_shards`의 설정은 인덱스 생성 시점 또는 [종료된 인덱스](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html)에서 가능합니다.

### 인덱스 생성 예제

아래의 [인덱스 생성 API]는 `my-index-000001` 인덱스를 `index.number_of_routing_shards`를 30으로 설정하여 생성하는 것 입니다.

```Bash
PUT /my-index-000001
{
  "settings": {
    "index": {
      "number_of_routing_shards": 30
    }
  }
}
```

`index.number_of_routing_shards` 설정의 기본값은 원본 인덱스의 기본 샤드의 개수에 종속됩니다.
기본값은 최대 1024의 샤드를 2배수로 분할할 수 있도록 고안되어있습니다.
그러나, 기본 샤드의 원래 개수를 고려해야 합니다.
예로 들면, 5개의 기본샤드로 생성된 인덱스는 10, 20, 40, 80, 160, 320 또는 최대 640 샤드로 분할(단일 분할 또는 다중 분할) 될 수 있습니다.

만약 원래 인덱스가 한개의 샤드 (또는 다중-샤드 인덱스에서 단일 기본샤드로 [축소](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-shrink-index.html)된 것)를 가지고 있는 경우, 1보다 큰 임의의 샤드 수로 분할될 수 있습니다.
라우팅 샤드의 기본값 속성은 새로 분할된 인덱스에 적용이 가능합니다.

### 분할 동작 원리 {#how-split-works}

분할 동작은 다음과 같습니다.

1. 대상인덱스와 동일한 정의를 가지지만 더 큰수의 기본 샤드를 설정할 수 있는 새로운 인덱스를 생성합니다.
2. 대상인덱스에서 신규인덱스로 세그먼트를 하드링크합니다. (만약 파일 시스템이 하드링크를 지원하지 않으면 처리하는데 시간이 좀더 걸리지만 새로운 인덱스로 모든 세그먼트를 복사합니다)
3. 하위 수준의 파일이 생성되면 다른 샤드에 속해있는 문서를 삭제하기 위해 모든 문서를 다시 해싱합니다.
4. 다시 오픈할 닫힌 인덱스처럼 신규 인덱스를 복구합니다.

### 왜 엘라스틱서치가 증분 재샤딩을 지원하지 않을까? {#incremental-resharding}

`N` 샤드에서 `N+1` 샤드로 확장되는, 일명 증분 재샤딩은 많은 키-값 저장소에서 지원되는 기능입니다.
새로운 샤드를 추가하고 새로운 데이터를 이 샤드로 저장하는 것은 선택지가 아닙니다.
이런 환경에서는 인덱싱 병목이 발생하고 조회/삭제/갱신 요청에 필요한 주어진 `_id`를 가지고 문서가 어떤 샤드에 속해있는지 알아내는 것이 더 복잡해집니다.
따라서 다른 해싱 스키마를 가지고 기존 데이터를 재분배가 필요하다는 것 입니다.

키-값 저장소에서 이것을 효율적으로 하기 위해 일반적으로 사용되는 방법은 일관된 해싱을 사용하는 것 입니다.
일반된 해싱은 샤드의 수를 `N`에서 `N+1`로 증가시킬 때 재할당을 위해 `1/N` 번째의 키만 있으면 됩니다.
그렇지만 엘라스틱서치의 저장 단위인 샤드는 루씬 인덱스 입니다.
검색기반의 데이터 구조이기 때문에 문서의 5%에 불과하더라도 루씬 인덱스의 상당부분을 차지하고 이를 삭제하고 다른 샤드에 인덱싱하는 것은 보통 키-값 저장소보다 훨씬 더 높은 비용이 발생합니다.


### 인덱스 분할 {#split-index}

### 분할 모니터링 {#monitor-split}

### 활성 샤드 대기 {#split-wait-active-shards}

## 경로 매개변수 {#split-index-api-path-params}

## 쿼리 매개변수 {#split-index-api-query-params}

## 요청 본문 {#split-index-api-request-body}

<AdsenseB />