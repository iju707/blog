---
title: "[Git] src refspec master does not match any 오류"
date: 2025-03-05T00:41:00+09:00
draft: false
authors:
  - name: iju707
    link: https://github.com/iju707
    image: https://github.com/iju707.png
tags:
  - git
  - refspec
---

## 문제점

Git으로 Commit을 하고 Push할 때 아래와 같은 오류가 발생됩니다.

```
error: src refspec master does not match any
```

수행했던 명령은 아래와 같습니다.

```
> git init
> git add -A
> git commit -m "deploy"
> git push -f https://github.com/iju707/blog.git master:gh-pages
```

## 원인

Push 할 대상으로 지정된 브랜치명이 잘못된 경우입니다.
브랜치의 경로를 `git show-ref` 명령으로 확인해보니 main으로 지정되어있었습니다.

```
> git show-ref
aa7fe6bee3ecde2877a05f6dc156763dab49a7fa refs/heads/main
```

## 해결방법

Push할 대상의 정보를 `master:gh-pages`에서 `main:gh-pages`로 변경합니다.

또는, Init을 할 때 대상 `git init -b master` 명령으로 브랜치 명을 지정합니다.
