extends Node

## AdMob 글로벌 매니저 (싱글톤 AutoLoad)
## Godot AdMob 플러그인이 설치된 경우에만 실제 광고가 동작합니다.
## 플러그인 미설치 시에도 게임이 정상 동작하도록 안전하게 처리합니다.

var admob = null
var is_admob_available = false

# 광고 ID (테스트용 → 실제 배포 시 교체)
var banner_id = "ca-app-pub-3940256099942544/6300978111" # 테스트 배너
var rewarded_id = "ca-app-pub-3940256099942544/5224354917" # 테스트 보상형

# 보상형 광고 콜백
signal rewarded_ad_completed(reward_type: String)

func _ready():
	# AdMob 플러그인 확인
	if Engine.has_singleton("AdMob"):
		admob = Engine.get_singleton("AdMob")
		is_admob_available = true
		print("[AdMob] 플러그인 감지 - 광고 초기화 시작")
		_init_admob()
	else:
		is_admob_available = false
		print("[AdMob] 플러그인 미설치 - 광고 기능 비활성화")

func _init_admob():
	if not admob:
		return
	
	# AdMob 초기화
	admob.initialize()
	
	# 시그널 연결
	if admob.has_signal("initialization_completed"):
		admob.connect("initialization_completed", Callable(self, "_on_admob_initialized"))

func _on_admob_initialized():
	print("[AdMob] 초기화 완료!")
	load_banner()

# ── 배너 광고 ──
func load_banner():
	if not is_admob_available:
		return
	admob.load_banner({
		"ad_unit_id": banner_id,
		"position": 1, # BOTTOM
		"size": "BANNER"
	})
	print("[AdMob] 배너 광고 로드 요청")

func show_banner():
	if not is_admob_available:
		return
	admob.show_banner()

func hide_banner():
	if not is_admob_available:
		return
	admob.hide_banner()

# ── 보상형 광고 ──
func load_rewarded():
	if not is_admob_available:
		return
	admob.load_rewarded_ad(rewarded_id)
	print("[AdMob] 보상형 광고 로드 요청")

func show_rewarded(reward_type: String = "water_boost"):
	if not is_admob_available:
		# 플러그인 없을 때는 바로 보상 지급 (개발 편의)
		print("[AdMob] 테스트 모드 - 보상 즉시 지급: %s" % reward_type)
		emit_signal("rewarded_ad_completed", reward_type)
		return
	
	if admob.has_signal("rewarded_ad_earned_reward"):
		admob.connect("rewarded_ad_earned_reward", Callable(self, "_on_rewarded").bind(reward_type), CONNECT_ONE_SHOT)
	admob.show_rewarded_ad()

func _on_rewarded(_reward_type_from_admob, _reward_amount, custom_reward_type):
	print("[AdMob] 보상 획득: %s" % custom_reward_type)
	emit_signal("rewarded_ad_completed", custom_reward_type)
	# 다음 광고 미리 로드
	load_rewarded()
