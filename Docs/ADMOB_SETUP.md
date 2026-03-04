# AdMob Integration Notes

## 준비 사항 (Godot 4.x)
1. Godot AdMob Plugin 설치: https://github.com/poing-studios/godot-admob-plugin
2. Android/iOS Export Template 설치

## 설정 방법
1. AssetLib에서 'AdMob' 검색하여 설치
2. Project Settings → AutoLoad에 AdMob 싱글톤 등록
3. `addons/admob/` 폴더의 설정 파일에 앱 ID 입력:
   - Android: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXXXXXXX
   - iOS: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXXXXXXX

## 배너 광고 코드 예시
```gdscript
# MainGame.gd의 _ready()에 추가
var admob = Engine.get_singleton("AdMob")
if admob:
    admob.load_banner({
        "ad_unit_id": "ca-app-pub-3940256099942544/6300978111", # 테스트 ID
        "position": admob.BOTTOM,
        "size": "BANNER"
    })
```

## 보상형 광고 코드 예시
```gdscript
func show_rewarded_ad():
    var admob = Engine.get_singleton("AdMob")
    if admob:
        admob.load_rewarded_ad("ca-app-pub-3940256099942544/5224354917") # 테스트 ID
        admob.connect("rewarded_ad_loaded", Callable(self, "_on_rewarded_loaded"))

func _on_rewarded_loaded():
    var admob = Engine.get_singleton("AdMob")
    admob.show_rewarded_ad()
```

## 주의사항
- 실제 배포 시 테스트 ID를 실제 앱 ID로 교체 필요
- AdMob 계정에서 앱 등록 후 발급받은 ID 사용
- 리뷰어 테스트를 위한 테스트 디바이스 ID 등록 필요
