extends Node2D

## 들판 맵 — 캐릭터가 직접 걸어다니며 야생 식물을 채집하는 필드
## 타일맵 기반 + 랜덤 야생 식물 배치

@onready var player = $Player
@onready var ui_layer = $UI
@onready var item_label = $UI/ItemLabel
@onready var back_button = $UI/BackButton

var collected_items: Array = []

# 야생 식물 데이터
var wild_plant_types = [
	{"name": "들꽃", "color": Color(1, 0.5, 0.8), "value": 5},
	{"name": "클로버", "color": Color(0.2, 0.8, 0.2), "value": 8},
	{"name": "민들레", "color": Color(1, 0.9, 0.2), "value": 6},
	{"name": "라벤더", "color": Color(0.6, 0.4, 0.9), "value": 12},
	{"name": "데이지", "color": Color(1, 1, 0.9), "value": 10},
	{"name": "제비꽃", "color": Color(0.5, 0.3, 0.8), "value": 15},
]

func _ready():
	update_ui()
	spawn_wild_plants()

func spawn_wild_plants():
	# 들판 곳곳에 랜덤으로 야생 식물 배치
	var plant_count = randi_range(10, 18)
	for i in range(plant_count):
		var plant = preload("res://Scenes/WildPlant.tscn").instantiate()
		var px = randf_range(80, 600)
		var py = randf_range(80, 400)
		plant.position = Vector2(px, py)
		
		var plant_data = wild_plant_types[randi() % wild_plant_types.size()]
		plant.setup(plant_data)
		plant.connect("collected", Callable(self, "_on_plant_collected"))
		add_child(plant)

func _on_plant_collected(plant_data: Dictionary):
	collected_items.append(plant_data)
	update_ui()

func update_ui():
	item_label.text = "채집: %d개" % collected_items.size()

func _on_back_pressed():
	# 메인으로 돌아가기
	var total_value = 0
	for item in collected_items:
		total_value += item["value"]
	
	Engine.set_meta("field_earnings", total_value)
	Engine.set_meta("field_plants", collected_items)
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
