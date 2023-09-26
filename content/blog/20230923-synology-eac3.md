---
title: "[Synology] EAC3 코덱 재생하기"
date: 2023-09-23T23:35:00+09:00
draft: false
---

## 개요

Video Station에서 영상을 재생할 때 간헐적으로 지원되지 않는 오디오 코덱으로 안되는 경우가 있습니다.
원인을 찾아보면 특허 문제로 인하여 공식 지원이 불가능한 경우입니다.

[Video Station 에서 DTS 또는 EAC3 오디오 형식의 비디오를 재생할 수 없는 이유는 무엇입니까?](https://kb.synology.com/ko-kr/DSM/tutorial/Why_can_t_I_play_videos_with_DTS_or_EAC3_audio_format_on_Video_Station)

현재 Video Station 은 특허 라이센스 문제로 인해 다음과 같은 오디오 형식을 재생할 수 없습니다.

* DTS 및 DTS-HD를 포함하되 이에 국한되지 않고 모든 DTS 오디오 형식
* 부분적인 돌비 디지털 오디오 형식(Dolby Digital Plus(EAC3) 및 돌비 TrueHD를 포함하되 이에 국한되지 않음)

## 해결방법

아래와 같이 설정하면 장치가 재부팅할때 마다 스크립트가 실행됩니다.
따라서 DSM이 업데이트되더라도 계속적으로 적용이 가능합니다.

{{% steps %}}

### 커뮤니티 패키지 소스 설정하기

**패키지 센터 > 설정** 을 클릭한 뒤 **패키지 소스** 탭에서 다음과 같이 입력합니다.

위치 : https://packages.synocommunity.com/

![패키지 소스](/blog/images/4/synology-package.png)

### FFMPEG 패키지를 설치하기

패키지 소스 설정이 완료되면 왼쪽에 **커뮤니티** 메뉴가 추가되며 그곳에서 **ffmpeg**를 설치합니다. (4~6 버전 무관)

![FFMPEG](/blog/images/4/synology-ffmpeg.png)

### 작업 스케쥴러 생성하기

**제어판 > 서비스 > 작업 스케쥴러** 메뉴에서 **생성 > 트리거된 작업 > 사용자 정의 스크립트** 를 클릭합니다.

![트리거된 작업](/blog/images/4/synology-trigger.png)

일반 설정 탭에서 사용자는 **root**, 이벤트는 **부트업** 으로 설정합니다.

작업 설정 탭의 실행 명령에서 다음을 입력합니다. 이때 FFMEPG VERSION은 설치한 버전에 맞게 선택합니다. (예: 6)

```
curl https://raw.githubusercontent.com/AlexPresso/VideoStation-FFMPEG-Patcher/main/patcher.sh | bash -s -- <FFMEPG Version>
```

![Alt text](/blog/images/4/synology-script.png)

### 적용하기

작업 스케줄러 목록에서 생성한 대상을 선택 후 **마우스 오른쪽 > 실행** 버튼을 클릭합니다.

결과는 대상 선택 후 상단의 **작업 > 결과 보기** 로 확인할 수 있습니다.

{{% /steps %}}

참고 : [https://github.com/AlexPresso/VideoStation-FFMPEG-Patcher](https://github.com/AlexPresso/VideoStation-FFMPEG-Patcher)