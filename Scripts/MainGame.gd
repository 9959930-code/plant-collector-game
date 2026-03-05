extends Node2D

## MainGame: 3/4 탑다운 뷰 레트로 베란다 
## (Pixle Perfect 640x360 resolution)

@onready var money_label = $UI/TopBar/MoneyLabel
@onready var day_label = $UI/TopBar/DayLabel
@onready var sys_log = $UI/BotUI/LogPanel/SystemLog
@onready var tilemap = $TileMapBackground
@onready var pots_container = $Environment/PotsContainer

var current_money = 0
var current_day = 1
var pots = []

func _ready():
	_draw_balcony_map()
	_load_state()
	update_ui()
	add_log("리틀 테라리움에 오신 것을 환영합니다.")
	add_log("번아웃을 피해 작은 화분을 가꿔보세요.")
	
	# 들판 수입 확인
	if Engine.has_meta("field_earnings"):
		var earned = Engine.get_meta("field_earnings")
		var plants_count = 0
		if Engine.has_meta("field_plants"):
			plants_count = Engine.get_meta("field_plants").size()
		if earned > 0:
			add_log("들판에서 돌아왔습니다! (+%d G, %d종 수확)" % [earned, plants_count])
			current_money += earned
			Engine.remove_meta("field_earnings")
			_save_state()
			update_ui()

func _draw_balcony_map():
	# 640x360 (타일크기 64x64 -> 10x6)
	var map_w = 10
	var map_h = 6
	
	for x in range(map_w):
		for y in range(map_h):
			if y < 2:
				# 난간 + 도시 배경 (타일셋에서 (x%10, 2) 정도 위치 가정)
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(x, 2))
			elif y == 2:
				# 벽면 하단 / 바닥 시작점
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 3))
			else:
				# 콘크리트 바닥 타일 (0,0 ~ 2,2 중 랜덤)
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(randi_range(0, 2), randi_range(0, 2)))

func update_ui():
	money_label.text = "자금: %d G" % current_money
	day_label.text = "Day %d" % current_day

func add_log(msg: String):
	sys_log.text += "\n" + msg
	# Scroll to bottom via call_deferred
	sys_log.call_deferred("scroll_to_line", sys_log.get_line_count() - 1)

func _on_explore_button_pressed():
	_save_state()
	get_tree().change_scene_to_file("res://Scenes/FieldMap.tscn")

func _on_buy_pot_button_pressed():
	if current_money >= 50:
		current_money -= 50
		var pot_data = {
			"id": Time.get_unix_time_from_system() + randi(),
			"px": randf_range(64, 576),
			"py": randf_range(200, 320), # 난간 아래 바닥 구역
			"plant_type": "행운초",
			"stage": 0,
			"watered": false
		}
		pots.append(pot_data)
		add_log("[행운초] 화분을 베란다에 들여놓았습니다.")
		_save_state()
		update_ui()
		_spawn_pot_node(pot_data)
	else:
		add_log("자금이 부족합니다. (50 G 필요)")

func _spawn_pot_node(data: Dictionary):
	var pot_scene = preload("res://Scenes/PlantPot.tscn")
	var pot = pot_scene.instantiate()
	pot.setup(data)
	pot.position = Vector2(data["px"], data["py"])
	pots_container.add_child(pot)

func _save_state():
	Engine.set_meta("money", current_money)
	Engine.set_meta("day", current_day)
	Engine.set_meta("pots", pots)

func _load_state():
	if Engine.has_meta("money"): current_money = Engine.get_meta("money")
	if Engine.has_meta("day"): current_day = Engine.get_meta("day")
	if Engine.has_meta("pots"): 
		pots = Engine.get_meta("pots")
		for p in pots:
			_spawn_pot_node(p)
