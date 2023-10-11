---
title: Elasticsearch 설정하기
draft: false
linkTitle: Elasticsearch 설정
type: docs
---

> https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html

이번 절은 엘라스틱서치를 어떻게 설정하고 실행하는지 아래를 포함하여 소개합니다.

* 다운로드
* 설치
* 시작하기
* 구성하기

## 지원하는 플랫폼

공식적으로 지원하는 운영체제와 JVM에 대한 것은 [지원표](https://www.elastic.co/support/matrix)에 있습니다.
엘라스틱서치는 목록화된 플랫폼에서 테스트가 되었지만 그 외의 다른 플랫폼에서도 동작할 것 입니다.

## 전용 호스트를 사용하기

운영계에서 전용 호스트 또는 주서비스로 엘라스틱서치를 실행하길 권장합니다.
자동 JVM 힙 사이즈와 같은 여러가지 엘라스틱서치 기능은 호스트와 컨테이너에서 자원을 많이 사용하는 어플리케이션이라고 가정합니다.
예로 들면, 클러스터 통계를 위해 엘라스틱서치에 메트릭비트를 실행할 수 있지만, 자원을 많이 사용하는 로그스태시 배포는 독립 호스트에 배포해야합니다.