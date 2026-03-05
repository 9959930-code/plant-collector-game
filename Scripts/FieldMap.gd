extends Node2D

## 들판 맵 — 절차적 생성(Procedural Generation) 기반의 '나만의 고유한 타일맵 들판'

@onready var player = $Player
@onready var ui_layer = $UI
@onready var item_label = $UI/ItemLabel

var collected_items: Array = []
var tilemap: TileMapLayer

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
	_generate_procedural_map()
	spawn_wild_plants()
	update_ui()
	
	# 이전 탐험 내역 로드 (누적)
	if Engine.has_meta("field_plants"):
		var prev_items = Engine.get_meta("field_plants")
		for item in prev_items:
			collected_items.append(item)
		update_ui()

func _generate_procedural_map():
	# 동적 타일맵 레이어 생성
	tilemap = TileMapLayer.new()
	tilemap.y_sort_enabled = true
	add_child(tilemap)
	move_child(tilemap, 0)
	
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	
	var ts_source = TileSetAtlasSource.new()
	ts_source.texture = preload("res://Assets/Images/field_autotile.png")
	ts_source.texture_region_size = Vector2i(64, 64)
	
	# 8x8 에셋 타일 등록 (풀밭, 흙길)
	for x in range(8):
		for y in range(8):
			ts_source.create_tile(Vector2i(x, y))
	
	tileset.add_source(ts_source, 0)
	tilemap.tile_set = tileset
	
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.08
	
	# 640x360 맵을 3x3배 스케일로 넓힘 (1920x1080 -> 30x17 타일)
	var map_w = 40
	var map_h = 24
	
	player.get_node("Camera2D").limit_left = 0
	player.get_node("Camera2D").limit_top = 0
	player.get_node("Camera2D").limit_right = map_w * 64
	player.get_node("Camera2D").limit_bottom = map_h * 64
	
	# 장애물 컨테이너
	var deco_container = Node2D.new()
	deco_container.y_sort_enabled = true
	add_child(deco_container)
	
	# 덤불/나무 기둥 리전 데이터 (field_autotile.png 내 위치)
	var deco_regions = [
		Rect2(0, 192, 64, 64), # 큰 덤불
		Rect2(64, 192, 64, 64),
		Rect2(128, 192, 64, 64),
		Rect2(192, 192, 64, 64), # 나무 기둥
		Rect2(256, 192, 64, 64),
		Rect2(320, 192, 64, 64)
	]
	var deco_scene = preload("res://Scenes/DecoObject.tscn")
	
	for x in range(map_w):
		for y in range(map_h):
			var n = noise.get_noise_2d(x, y)
			
			var tile_x = 0
			var tile_y = 0
			
			if n > 0.3:
				# 흙길 (대략 1,1)
				tile_x = 1
				tile_y = 1
			elif n < -0.3:
				# 짙은 잔디
				tile_x = 2
				tile_y = 0
			else:
				# 기본 잔디 (0,0)
				tile_x = 0
				tile_y = 0
			
			# 테두리는 어두운 숲 타일(추후 보정)로 덮기 (여기서는 임시로 풀밭)
			if x == 0 or x == map_w - 1 or y == 0 or y == map_h - 1:
				tile_x = 0
				tile_y = 0
			
			tilemap.set_cell(Vector2i(x, y), 0, Vector2i(tile_x, tile_y))
			
			# 내부 장식물(덤불, 그루터기) 스폰 확률 4%
			if x > 2 and x < map_w - 2 and y > 2 and y < map_h - 2:
				if randf() < 0.04 and n <= 0.3: # 흙길 위에는 장식물 안 생기게
					var deco = deco_scene.instantiate()
					deco.position = Vector2(x * 64 + 32 + randf_range(-10, 10), y * 64 + 32 + randf_range(-10, 10))
					deco.get_node("Sprite2D").region_rect = deco_regions[randi() % deco_regions.size()]
					deco_container.add_child(deco)

func spawn_wild_plants():
	var plant_count = randi_range(15, 25)
	var map_w = 40
	var map_h = 30
	
	for i in range(plant_count):
		var plant = preload("res://Scenes/WildPlant.tscn").instantiate()
		var px = randf_range(3 * 64, (map_w - 3) * 64)
		var py = randf_range(3 * 64, (map_h - 3) * 64)
		plant.position = Vector2(px, py)
		
		var plant_data = wild_plant_types[randi() % wild_plant_types.size()]
		plant.setup(plant_data)
		plant.connect("collected", Callable(self, "_on_plant_collected"))
		add_child(plant)

func _on_plant_collected(plant_data: Dictionary):
	collected_items.append(plant_data)
	update_ui()

func update_ui():
	item_label.text = "현재 채집: %d" % collected_items.size()

func _on_back_pressed():
	# 돌아가기: 수입 계산
	var total_value = 0
	for item in collected_items:
		total_value += item["value"]
	
	var prev_money = Engine.get_meta("field_earnings") if Engine.has_meta("field_earnings") else 0
	Engine.set_meta("field_earnings", prev_money + total_value)
	Engine.set_meta("field_plants", collected_items)
	
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
