---
title: '[Git] Failed to find a valid digest in the "integrity" attribute for resource'
date: 2023-10-12T04:01:00+09:00
draft: false
---

## 현상

Hugo를 활용하여 Github Page에 블로그를 생성하였습니다.
기존 MacOS환경에서는 큰 문제가 없었는데 Windows 환경으로 오고나서 배포를 하니 버튼동작이 하지 않고 크롬콘솔에서 다음과 같이 오류가 발생하였습니다.

> Failed to find a valid digest in the 'integrity' attribute for resource '....' with computed SHA-256 integrity '....'. The resource has been blocked.

![크롬오류](/blog/images/20231012-core_autocrlf/image.png)

내용상 파일의 digest가 일치하지 않아 차단처리를 한 것으로 보입니다.

## 원인

MacOS 환경에서는 정상이었으나 Windows에서 문제가 발생하였다는 점에 빌드나 배포를 점검하였습니다.

Git에서 commit 하는 메시지 중 다음을 발견하였습니다.

```powershell
PS C:\workspace\blog> .\upload.bat
Initialized empty Git repository in C:/workspace/blog/public/.git/
warning: in the working copy of '404.html', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'blog/index.xml', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'boto3/example/index.html', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'boto3/example/index.xml', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'boto3/example/s3/index.xml', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'boto3/example/s3/presigned-urls/index.html', CRLF will be replaced by LF the next time Git touches it
```

내용인즉슨 windows에서 사용하는 줄내림(CRLF, \r\n)를 Linux/Mac용(LF, \n)로 변경하는 것 입니다.
이로 인하여 빌드시점의 파일과 형상에 업로드된 파일이 바뀌게 된 것 입니다.

## 해결책

배포할 때 줄내림을 바꾸지 않도록 git에 설정을 하였습니다.

`git config core.autocrlf false`

일반적으로 권장되지 않는 옵션이지만, 위와 같이 특수한 상황인 경우 적용이 필요합니다.