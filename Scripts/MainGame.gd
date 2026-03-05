extends Node2D

@onready var money_label = $UI/TopBar/MoneyLabel
@onready var day_label = $UI/TopBar/DayLabel
@onready var weather_label = $UI/TopBar/WeatherLabel
@onready var log_text = $UI/LogBox/LogText

var money = 0
var day = 1
var weather = "맑음"
var pot_scene = preload("res://Scenes/PlantPot.tscn")
var pots = []

# 가공품 인벤토리
var inventory = {
	"하바리움": 0,
	"압화 액자": 0,
	"드라이플라워 다발": 0
}
var harvested_flowers: Array = [] # 수확한 꽃 목록

# 일기장 시스템 (감성 독백)
var diary_entries: Array = []
var diary_triggers = {
	"first_water": "오늘 처음으로 식물에 물을 주었다. 차가운 수돗물이 마른 흙에 스며드는 걸 보며 한참을 서 있었다.",
	"first_sprout": "새싹이 돋았다. 이 작은 생명이 나를 필요로 하고 있다는 게... 오랜만에 설레는 느낌이다.",
	"first_harvest": "처음으로 꽃이 만개했다. 내가 돌본 것이 이렇게 아름다운 결실을 맺다니. 사수님도 이런 기분이었을까.",
	"first_craft": "수확한 꽃으로 하바리움을 만들어 보았다. 서툴지만, 여기에 내 시간과 정성이 담겨 있다.",
	"first_sell": "만든 가공품을 처음 팔았다. 누군가가 내 작품의 가치를 인정해 주었다. 이상하게도 돈보다 그 사실이 더 기쁘다.",
	"first_explore": "들판에 나가 보았다. 콘크리트 숲에선 절대 만날 수 없었던 야생의 꽃들. 세상은 생각보다 넓었다.",
	"pot_5": "어느새 베란다에 화분 5개. 퇴근 후 문을 열면 초록빛 반겨주는 이 공간이 내 유일한 안식처가 되었다.",
}
var triggered_diary: Dictionary = {}

# NPC 위로 편지 시스템
var npc_letters: Array = [
	{"sender": "혜진 (직장 후배)", "text": "선배, 하바리움 너무 예뻐요! 책상 위에 놓았더니 사무실이 달라 보여요. 선배 덕분이에요 💚"},
	{"sender": "은수 (대학 친구)", "text": "야 너 이거 진짜 잘 만든다? 라벤더 압화 진짜 미쳤음ㅋㅋ 나도 하나 보내줘!"},
	{"sender": "어머니", "text": "아들, 보내준 드라이플라워 잘 받았다. 이렇게 예쁜 걸 만들 줄 아는 내 자식이 대견하구나."},
	{"sender": "익명의 구매자", "text": "포장 사이에 꽂혀 있던 메모를 읽었어요. '당신의 하루에 작은 초록빛을.' 덕분에 힘든 하루가 나아졌습니다."},
	{"sender": "사수님 (퇴사한)", "text": "네가 그 화분을 가져갔다고 들었어. 잘 키우고 있지? 그 녀석은 원래 잘 안 죽어. 네가 돌봐줘서 고마워."},
	{"sender": "옆집 할머니", "text": "베란다에 꽃이 참 예쁘더구나. 우리 집 쪽에서도 보인단다. 덕분에 아침이 즐거워ㅎㅎ"},
	{"sender": "고등학교 동창", "text": "SNS에 올린 압화 사진 봤어. 너 진짜 달라진 것 같아. 예전보다 훨씬 밝아 보여."},
]
var unread_letters: Array = []


func _ready():
	update_ui()
	
	# 들판에서 돌아온 경우 수익 반영
	if Engine.has_meta("field_earnings"):
		var earnings = Engine.get_meta("field_earnings")
		var plants = Engine.get_meta("field_plants")
		money += earnings
		for p in plants:
			harvested_flowers.append(p["name"])
		add_log("채집에서 돌아왔습니다! (+%d G, %d종 수확)" % [earnings, plants.size()])
		Engine.remove_meta("field_earnings")
		Engine.remove_meta("field_plants")
		update_ui()
	else:
		add_log("나만의 작은 베란다 정원을 가꿔보자.")
	
	# 초기 화분 배치 (처음 시작 시에만)
	if pots.size() == 0:
		spawn_new_pot(Vector2(576, 324), "행운초")

func spawn_new_pot(pos: Vector2, type: String):
	var new_pot = pot_scene.instantiate()
	new_pot.position = pos
	new_pot.connect("clicked", Callable(self, "_on_pot_clicked"))
	$UI.add_sibling(new_pot)
	pots.append(new_pot)
	new_pot.plant_seed(type)
	add_log("[%s] 화분을 베란다에 들여놓았습니다." % type)

func _on_pot_clicked(pot):
	if pot.current_stage == pot.max_stage:
		# 수확
		harvested_flowers.append(pot.plant_type)
		add_log("만개한 %s(을)를 수확했습니다! 가공품을 만들 수 있어요." % pot.plant_type)
		money += 20
		update_ui()
		pot.queue_free()
		pots.erase(pot)
		trigger_diary("first_harvest")
	elif not pot.is_watered:
		pot.water()
		add_log("%s에 물을 듬뿍 주었습니다. 무럭무럭 자라렴!" % pot.plant_type)
		trigger_diary("first_water")
	else:
		add_log("%s(은)는 이미 물을 충분히 먹고 자라고 있습니다." % pot.plant_type)

func update_ui():
	money_label.text = "자금: %d G" % money
	day_label.text = "Day %d" % day
	weather_label.text = "날씨: %s" % weather

func add_log(text: String):
	log_text.text = text + "\n" + log_text.text

func _on_explore_button_pressed():
	trigger_diary("first_explore")
	get_tree().change_scene_to_file("res://Scenes/FieldExplore.tscn")

func _on_shop_button_pressed():
	if money >= 30:
		money -= 30
		var pot_types = ["라벤더", "해바라기", "장미", "민트", "로즈마리"]
		var chosen = pot_types[randi() % pot_types.size()]
		var offset_x = 300 + (pots.size() * 150)
		spawn_new_pot(Vector2(offset_x, 324), chosen)
		update_ui()
		add_log("새로운 [%s] 화분을 들여놓았습니다! (-30 G)" % chosen)
		if pots.size() >= 5:
			trigger_diary("pot_5")
	else:
		add_log("자금이 부족합니다. (화분 가격: 30 G)")

func _on_craft_button_pressed():
	if harvested_flowers.size() >= 3:
		var craft_types = ["하바리움", "압화 액자", "드라이플라워 다발"]
		var chosen = craft_types[randi() % craft_types.size()]
		inventory[chosen] += 1
		for i in range(3):
			harvested_flowers.pop_back()
		add_log("🎨 [%s]을(를) 제작했습니다! 판매할 수 있습니다." % chosen)
		trigger_diary("first_craft")
	else:
		add_log("꽃이 부족합니다. (필요: 3개, 보유: %d개)" % harvested_flowers.size())

func _on_sell_button_pressed():
	var total_sold = 0
	var sold_items = []
	var prices = {"하바리움": 50, "압화 액자": 40, "드라이플라워 다발": 35}
	
	for item_name in inventory.keys():
		if inventory[item_name] > 0:
			var price = prices[item_name]
			var count = inventory[item_name]
			total_sold += price * count
			sold_items.append("%s x%d" % [item_name, count])
			inventory[item_name] = 0
	
	if total_sold > 0:
		money += total_sold
		update_ui()
		add_log("💰 %s 판매! (+%d G)" % [", ".join(sold_items), total_sold])
		trigger_diary("first_sell")
		# 판매할 때마다 랜덤 NPC 편지 수신
		receive_letter()
	else:
		add_log("판매할 가공품이 없습니다. 먼저 제작해 보세요!")

# ── 일기장 시스템 ──
func trigger_diary(key: String):
	if key in diary_triggers and key not in triggered_diary:
		triggered_diary[key] = true
		var entry = diary_triggers[key]
		diary_entries.append(entry)
		add_log("📔 [일기] %s" % entry)

# ── 우편함 시스템 ──
func receive_letter():
	var letter = npc_letters[randi() % npc_letters.size()]
	unread_letters.append(letter)
	add_log("📬 편지가 도착했습니다! - From. " + str(letter["sender"]))
	add_log("   " + str(letter["text"]))

# ── 보상형 광고 시스템 ──
func _get_admob():
	return get_node_or_null("/root/AdMobManager")

func _on_water_ad_pressed():
	# 광고 시청 → 모든 화분에 즉시 물주기
	add_log("🎬 광고를 시청하면 모든 화분에 물을 줍니다!")
	var admob = _get_admob()
	if admob:
		admob.show_rewarded("water_boost")
		admob.connect("rewarded_ad_completed", Callable(self, "_on_reward_received"), CONNECT_ONE_SHOT)
	else:
		# AdMob 미설치 시 바로 보상 지급
		_on_reward_received("water_boost")

func _on_seed_ad_pressed():
	# 광고 시청 → 무료 화분 1개 (특별한 씨앗)
	add_log("🎬 광고를 시청하면 특별한 씨앗을 받습니다!")
	var admob = _get_admob()
	if admob:
		admob.show_rewarded("seed_vending")
		admob.connect("rewarded_ad_completed", Callable(self, "_on_reward_received"), CONNECT_ONE_SHOT)
	else:
		_on_reward_received("seed_vending")

func _on_reward_received(reward_type: String):
	if reward_type == "water_boost":
		var watered_count = 0
		for pot in pots:
			if not pot.is_watered:
				pot.water()
				watered_count += 1
		add_log("💧 보상 완료! %d개의 화분에 물을 주었습니다!" % watered_count)
	elif reward_type == "seed_vending":
		var special_seeds = ["금잔화", "수국", "오키드", "벚꽃", "무지개 장미"]
		var chosen = special_seeds[randi() % special_seeds.size()]
		var offset_x = 300 + (pots.size() * 150)
		spawn_new_pot(Vector2(offset_x, 324), chosen)
		add_log("🌟 특별한 [%s] 씨앗을 받았습니다!" % chosen)
