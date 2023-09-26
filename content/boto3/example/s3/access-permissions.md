---
title: Boto3를 활용한 접근권한 예제
linkTitle: 접근 권한
draft: false
weight: 7
date: 2023-09-20
type: docs
---

> https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-example-access-permissions.html

이번 절에서 접근권한목록(ACL)을 사용해서 S3 버킷이나 객체에 대한 접근권한을 어떻게 관리하는지 알아보겠습니다.

## 버킷 접근 권한 목록 가져오기

아래 예제는 S3 버킷의 현재 접근권한목록을 검색하는 것 입니다.

```python
import boto3

# 버킷의 ACL 검색하기
s3 = boto3.client('s3')
result = s3.get_bucket_acl(Bucket='BUCKET_NAME')
print(result)
```