---
title: 인덱스분할 API
draft: false
type: docs
date: 2024-01-22
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
위 절에서 설명한 대로 샤드 수를 늘릴 때 이 비용은 곱셈 요소기반 합리적으로 유지됩니다.
이를 통해 엘라스틱서치는 분할을 로컬로 수행할 수 있으며 결과적으로 이동이 필요한 문서를 다시 색인화하는 대신 인덱스 수준에서 분할을 수행할 수 있을 뿐 아니라 효과적인 파일 복사를 위해 하드링크를 사용할 수 있습니다.

추가만 되는 데이터의 경우, 좀더 유연하게 새로운 인덱스를 생성하고 데이터를 저장합니다. 그리고 과거와 신규 데이터에 대한 읽기 연산수행을 위하여 별칠을 추가하는 것 입니다.
과거와 신규 인덱스가 각기 `M`과 `N` 샤드를 가지고 있을 경우 `M+N` 샤드를 가지는 인덱스를 검색하는 것과 비교하여 오버헤드가 없습니다.

### 인덱스 분할 {#split-index}

`my_source_indes`를 새로운 `my_target_index`로 분할 하는 경우 아래와 같이 요청합니다.

```bash
POST /my_source_index/_split/my_target_index
{
  "settings": {
    "index.number_of_shards": 2
  }
}
```

위 요청은 타겟 인덱스가 클러스터에 추가된 즉시 결과를 반환하며 분할 동작이 시작하는 것을 기다리지는 않습니다.

{{< callout type="warning" >}}
인덱스는 아래의 요건이 모두 만족하면 분할동작을 시작합니다.

* 타겟 인덱스가 존재하지 않습니다.
* 소스 인덱스는 타겟 인덱스보다 적은 기본 샤드를 가집니다.
* 타겟 인덱스의 기본 샤드수는 소스 인덱스의 기본 샤드수의 배수가 되어야합니다.
* 분할 동작을 처리하는 노드는 기존 인덱스의 복제본을 만들기 위해 충분한 디스크 공간이 있어야 합니다.
{{< /callout >}}

`_split` API는 [인덱스 생성 API](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)와 유사하며 타겟 인덱스의 `settings`와 `aliases` 매개변수를 받습니다.

```bash
POST /my_source_index/_split/my_target_index
{
  "settings": {
    "index.number_of_shards": 5 
  },
  "aliases": {
    "my_search_indices": {}
  }
}
```

### 분할처리 모니터링 {#monitor-split}

분할 처리는 [`_cat 복구` API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-recovery.html)를 사용하여 모니터링하거나 [`cluster 상태` API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)를 가지고 `wait_for_status` 매개변수를 `yellow`로 설정하여 모든 기본 샤드가 할당될 때까지 대기할 수 있습니다.

`_split` API는 어떤 샤드든 할당되기 전에 대상 인덱스가 클러스터 상태에 추가되면 바로 결과를 반환합니다.
이 시점에는 모든 샤드가 `unassigned` 상태에 있습니다.
다른 이유로 대상 인덱스가 할당되지 않으면, 기본 샤드는 해당 노드에 할당될 수 있을 때까지 `unassigned`로 남아있습니다.

기본 샤드가 할당되면 상태는 `initializing` 상태로 전환되며 분할 처리가 시작됩니다.
분할 동작이 완료되면 샤드는 `active` 상태가 됩니다.
이때부터 엘라스틱서치는 복제본 할당을 시작하고 기본 샤드를 다른 노드에 재배치를 고려하게 됩니다.

### 활성 샤드 대기 {#split-wait-active-shards}

분할 동작은 샤드를 분할하기 위해 새로운 인덱스를 생성하기 때문에 인덱스 생성의 [샤드 활성 대기](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html#create-index-wait-for-active-shards) 설정이 인덱스 분할 동작에도 적용 가능합니다.

## 경로 매개변수 {#split-index-api-path-params}

###  `<index>`

(필수, 문자열) 분할하고자 하는 소스 인덱스명

### `<target-index>`

(필수, 문자열) 생성할 대상 인덱스명

인덱스명은 아래 규칙을 따라야 합니다.

* 소문자만 가능
* `\`, `/`, `*`, `?`, `"`, `<`, `>`, `|`, ` `(공백), `,`, `#` 불가
* 7.0 이전버전은 콜론(`:`)이 가능하나 7.0 이상은 더이상 사용되지 않아 지원되지 않음
* `-`, `_`, `+`로 시작하지 않음
* `.`, `..`가 될 수 없음
* 255 바이트가 될 수 없음 (바이트이므로 멀티바이트 문자열에서는 255글자보다 빨리 초과됨을 참고)
* [숨김 인덱스](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#index-hidden)와 플러그인에서 관리하는 내부 인덱스를 제외하고 `.`로 시작하는 이름은 더이상 사용되지 않음

## 쿼리 매개변수 {#split-index-api-query-params}

### `wait_for_active_shards`

(선택, 문자열) 작업을 처리하기 전에 활성화되어야하는 샤드 복사본의 수 입니다.
`all` 또는 인덱스의 전체 샤드 수 까지의 양의 정수로 설정합니다. (`number_of_replicas+1`)
기본값은 1, 기본 샤드 입니다.

자세한 것은 [활성 샤드](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#index-wait-for-active-shards)를 참고하세요.

### `master_timeout`

(선택, [시간단위](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#time-units)) 마스터 노드에 접속대기할 시간.
타임아웃이 초과되기 전까지 응답이 없으면 요청은 실패하고 오류를 반환합니다.
기본값은 `30s` 입니다.

### `timeout`

(선택, [시간단위](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#time-units)) 응답을 기다리는 시간.
타임아웃이 초과되기 전까지 응답이 없으면 요청은 실패하고 오류를 반환합니다.
기본값은 `30s` 입니다.

## 요청 본문 {#split-index-api-request-body}

### `aliases`

(선택, 객체의 객체) 결과 인덱스의 별칭

{{% details title="`aliases` 객체의 속성" closed="true" %}}

#### `<alias>`

(필수, 객체) 키는 별칭명. 인덱스 별칭이름은 [날짜 계산](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-date-math-index-names)을 지원합니다.

객체의 본문은 별칭의 옵션을 포함합니다.
비어있는 객체도 지원합니다.

{{% details title="`<alias>`의 속성" closed="true" %}}

#### `filter`

(선택, [쿼리 DSL 객체](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)) 별칭이 접근할 수 있는 제한된 문서에 사용될 쿼리

#### `index_routing`

(선택, 문자열) 인덱싱 동작을 특정 샤드로 라우팅할 때 사용되는 값.
지정되면 인덱싱 동작에는 `routing` 값을 덮어씁니다.

#### `is_hidden`

(선택, 부울) `true` 이면 별칭은 [숨겨집니다.](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#multi-hidden)
기본값은 `false` 입니다.
별칭의 모든 인덱스는 동일한 `is_hidden` 값을 가져야합니다.

#### `is_write_index`

(선택, 부울) `true` 이면, 인덱스는 별칭의 [쓰기 인덱스](https://www.elastic.co/guide/en/elasticsearch/reference/current/aliases.html#write-index)가 됩니다.
기본값은 `false` 입니다.

#### `routing`

(선택, 문자열) 인덱싱과 검색 동작을 특정 샤드로 라우팅할 때 사용되는 값.

#### `search_routing`

(선택, 문자열) 검색 동작을 특정 샤드로 라우팅할 때 사용되는 값.
지정되면 검색 동작에는 `routing` 값을 덮어씁니다.

{{% /details %}}

{{% /details %}}

### `settings`

(선택, [인덱스 설정 객체](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#index-modules-settings)) 대상 인덱스에 대한 구성 옵션.
[인덱스 설정](https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html#index-modules-settings)을 참고하세요.