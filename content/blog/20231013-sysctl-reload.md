---
title: '[Linux] 재부팅없이 sysctl 설정 다시읽기(reload)'
date: 2023-10-13T23:39:00+09:00
draft: false
---

## 개요

Linux 환경에 Elasticsearch를 설치하는데 시스템 설정 수정이 필요합니다. (vm.max_map_count)
다만, 운영환경이고 별도절차가 있어서 재부팅하기 쉽지 않습니다.
재부팅하지 않고 sysctl로 설정한 내용을 다시 읽는 법을 공유합니다.

## 다시읽기

아래 명령을 수행하면 재부팅없이 다시 읽게 됩니다. 필요시 `sudo`가 요구됩니다.

```shell
$ sysctl --system
```

## 다시읽은 파일

위 명령을 실행하면 아래의 파일을 다시 읽게 됩니다.

* /run/sysctl.d/*.conf
* /etc/sysctl.d/*.conf
* /usr/local/lib/sysctl.d/*conf
* /usr/lib/sysctl.d/*.conf
* /lib/sysctl.d/*conf
* /etc/sysctl.conf
