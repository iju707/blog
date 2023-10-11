---
title: '[Git] Submodule이 있는 저장소 Clone 하기'
date: 2023-10-12T03:22:19+09:00
draft: false
---

## 개요

Git 프로젝트에서 다른 Repository를 모듈로 참조할 경우 Submodule로 등록합니다.
아래는 기존의 프로젝트를 Clone할 때 Submodule을 어떻게 처리해야하는지 안내합니다.

## 방법 1 : 개별 초기화

먼저 `git submodule init` 명령으로 submodule을 초기화 합니다.

```shell
$ git submodule init
Submodule 'themes/hextra' (https://github.com/imfing/hextra.git) registered for path 'themes/hextra'
```

`git submodule update` 로 최신 형상으로 업데이트 합니다.

```shell
$ git submodule update
Cloning into 'C:/workspace/blog/themes/hextra'...
Submodule path 'themes/hextra': checked out '28a20e1e7e2e90dc128a3439bf88c1ecccff9220'
```

## 방법 2 : Clone시 옵션주기

Clone을 할 때 `--recurse-submodules` 옵션을 추가하면 됩니다.
그러면 형상을 Clone하면서 Submodule 까지 포함하여 진행합니다.

```shell
$ git clone --recurse-submodules https://github.com/iju707/blog.git
Cloning into 'blog'...
remote: Enumerating objects: 448, done.
remote: Counting objects: 100% (448/448), done.
remote: Compressing objects: 100% (203/203), done.
Receiving objects:  87% (390/448)used 418 (delta 150), pack-reused 0
Receiving objects: 100% (448/448), 852.84 KiB | 35.53 MiB/s, done.
Resolving deltas: 100% (176/176), done.
Submodule 'themes/hextra' (https://github.com/imfing/hextra.git) registered for path 'themes/hextra'
Cloning into 'C:/workspace/test/blog/themes/hextra'...
remote: Enumerating objects: 1781, done.        
remote: Counting objects: 100% (413/413), done.
remote: Compressing objects: 100% (121/121), done.
remote: Total 1781 (delta 327), reused 312 (delta 288), pack-reused 1368        
Receiving objects: 100% (1781/1781), 3.02 MiB | 29.17 MiB/s, done.
Resolving deltas: 100% (1017/1017), done.
Submodule path 'themes/hextra': checked out '28a20e1e7e2e90dc128a3439bf88c1ecccff9220'
```