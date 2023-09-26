---
title: '[PostgreSQL] 재시작없이 설정불러오기 (reload configuration without restart)'
date: 2023-09-27T00:20:35+09:00
draft: false
---

## 개요

PostgreSQL은 다양한 설정을 파일로 다루고 있습니다.
그중 pg_hba.conf 파일로 접근제어를 하게 되는데 운영중 수정이 필요한 상황이 발생했을 때 재시작 없이 적용하는 방법을 가이드 합니다.

## pg_ctl 이용

pg_ctl에서는 다음방법으로 설정로딩을 지원합니다.

```bash
$ pg_ctl reload [-s] [-D datadir]
```

옵션은
* **-s** : 오류 관련 메시지만 출력합니다.
* **-D datadir** : PostgreSQL이 사용하는 데이터 경로를 지정합니다.

## Query 이용

SQL 내에서도 설정로딩을 할 수 있습니다.

```sql
SELECT PG_RELOAD_CONF();
```

## 제약사항

일반적인 설정은 재적용이 가능하나, 일부 재시작이 필요한 설정은 적용되지 않습니다.