extends Node2D

## 들판 채집 미니게임
## 화면에 랜덤으로 야생 식물이 나타나고, 클릭하면 채집하는 미니게임

signal plant_collected(plant_name: String)

@onready var background = $Background
@onready var timer = $SpawnTimer
@onready var collect_label = $UI/CollectLabel
@onready var back_button = $UI/BackButton
@onready var time_bar = $UI/TimeBar
@onready var result_label = $UI/ResultLabel

var collected_plants: Array = []
var spawn_count = 0
var max_spawns = 8
var explore_time = 15.0 # 15초 동안 채집
var time_left = 15.0
var is_active = true

# 채집 가능한 식물 목록
var wild_plants = [
	{"name": "들꽃", "color": Color(1, 0.5, 0.8), "value": 5},
	{"name": "클로버", "color": Color(0.2, 0.8, 0.2), "value": 8},
	{"name": "민들레", "color": Color(1, 0.9, 0.2), "value": 6},
	{"name": "라벤더", "color": Color(0.6, 0.4, 0.9), "value": 12},
	{"name": "데이지", "color": Color(1, 1, 0.9), "value": 10},
	{"name": "제비꽃", "color": Color(0.5, 0.3, 0.8), "value": 15},
]

func _ready():
	result_label.visible = false
	update_collect_label()
	time_left = explore_time
	time_bar.max_value = explore_time
	time_bar.value = explore_time
	
	timer.wait_time = 1.5
	timer.start()
	
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))

func _process(delta):
	if is_active:
		time_left -= delta
		time_bar.value = time_left
		if time_left <= 0:
			end_explore()

func _on_spawn_timer_timeout():
	if not is_active:
		return
	if spawn_count >= max_spawns:
		return
	spawn_wild_plant()
	spawn_count += 1

func spawn_wild_plant():
	var plant_data = wild_plants[randi() % wild_plants.size()]
	
	var plant_btn = Button.new()
	plant_btn.text = plant_data["name"]
	plant_btn.add_theme_font_size_override("font_size", 14)
	
	# 랜덤 위치 (화면 내)
	var x = randf_range(80, 1050)
	var y = randf_range(150, 500)
	plant_btn.position = Vector2(x, y)
	plant_btn.size = Vector2(70, 35)
	
	# 색상 스타일링
	var style = StyleBoxFlat.new()
	style.bg_color = plant_data["color"]
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	plant_btn.add_theme_stylebox_override("normal", style)
	
	# 등장 애니메이션 (작게 → 크게)
	plant_btn.scale = Vector2(0.1, 0.1)
	plant_btn.pivot_offset = Vector2(35, 17)
	
	plant_btn.connect("pressed", Callable(self, "_on_plant_clicked").bind(plant_btn, plant_data))
	add_child(plant_btn)
	
	var tween = create_tween()
	tween.tween_property(plant_btn, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_ELASTIC)
	
	# 일정 시간 후 사라짐
	var disappear_tween = create_tween()
	disappear_tween.tween_interval(4.0)
	disappear_tween.tween_property(plant_btn, "modulate:a", 0.0, 0.5)
	disappear_tween.tween_callback(plant_btn.queue_free)

func _on_plant_clicked(btn: Button, data: Dictionary):
	if not is_active:
		return
	collected_plants.append(data)
	update_collect_label()
	
	# 수확 이펙트
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.5, 1.5), 0.15)
	tween.tween_property(btn, "modulate:a", 0.0, 0.15)
	tween.tween_callback(btn.queue_free)

func update_collect_label():
	collect_label.text = "채집: %d개" % collected_plants.size()

func end_explore():
	is_active = false
	timer.stop()
	
	# 남은 식물 정리
	for child in get_children():
		if child is Button and child != back_button:
			child.queue_free()
	
	# 결과 표시
	var total_value = 0
	var names = []
	for p in collected_plants:
		total_value += p["value"]
		if p["name"] not in names:
			names.append(p["name"])
	
	result_label.visible = true
	result_label.text = "🌿 채집 완료!\n"
	result_label.text += "수집: %d 종 %d개\n" % [names.size(), collected_plants.size()]
	result_label.text += "획득: %d G" % total_value
	
	# 결과를 글로벌에 저장 (메인으로 돌아갈 때 사용)
	set_meta("collected_value", total_value)
	set_meta("collected_plants", collected_plants)

func _on_back_pressed():
	# 메인으로 돌아가기 (수집 결과와 함께)
	var total_value = 0
	for p in collected_plants:
		total_value += p["value"]
	
	# 글로벌 변수에 결과 저장
	if Engine.has_meta("field_earnings"):
		Engine.remove_meta("field_earnings")
	Engine.set_meta("field_earnings", total_value)
	Engine.set_meta("field_plants", collected_plants)
	
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
