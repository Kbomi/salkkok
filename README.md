
# 살꼭 (Salkkok)

**살 때 꼭 필요한 물건, 깜빡하지 말고 '살꼭'에 담아두세요! 🛒**

살꼭은 사용자가 일상 속에서 **사야 할 물건**을 간편하게 메모하고,  
나중에 마트나 상점에서 **필요한 물품만** 확인할 수 있도록 돕는 **합리적 소비 지원 메모 앱**입니다.

---

## 📱 주요 기능

- 장소별 메모 입력: `"냉장고에 우유 담기"`처럼 물건을 장소에 연결해 저장
- 탭/Chip UI로 장소 선택 후 물건 리스트 보기
- 메모 항목 체크 및 다중 삭제
- 장소별 전체 삭제 기능
- Hive 기반 로컬 저장
- 입력시 공백 자동 제거 (trim)
- `살거야!` 버튼으로 간단하게 메모 등록

---

## 🎯 개발 목표

- Flutter 기반의 Android 앱
- OneStore 출시 예정
- 누구나 쉽게 필요한 물건을 담아두고, 쇼핑할 때 꼭 필요한 것만 사도록 돕는 UX 설계

---

## 🔮 앞으로 추가될 기능

- `"살꼭아~ 냉장고에 우유 담기"`와 같은 **음성 커맨드 자동 등록 기능**  
  → 사용자가 마이크 버튼 없이도 말로 메모를 등록할 수 있도록 연구 예정  
  → **OS 차원의 호출어 인식 (Hotword Detection)** 또는 **Siri / Google Assistant 연동** 검토

- Firebase 또는 자체 백엔드를 통한 멀티 디바이스 동기화

- UI 디자인 개선 및 다크모드 지원

---

## ⚙️ 기술 스택

- Flutter (Dart)
- Hive (로컬 DB)
- speech_to_text (음성 인식)
- path_provider (파일 시스템 접근)

---

## 🧪 실행 방법

```bash
flutter pub get
flutter run
```

---

## 📂 프로젝트 구조

```
/lib
  └── main.dart          # 앱 메인 로직 및 UI
/assets/images           # 앱 로고 및 이미지 리소스
```

---

## 💡 이름의 의미

**살꼭**: "살 때 꼭 필요한 것만 사자"는 의미의 줄임말  
→ 필요한 걸 제때 사고, **불필요한 소비를 줄이자**는 앱의 철학이 담겨있습니다.

---

## 🙋‍♀️ 제작자

- 기획 & 개발: [김보미]  
- ChatGPT의 도움으로 Flutter 입문 및 프로젝트 설계 중
