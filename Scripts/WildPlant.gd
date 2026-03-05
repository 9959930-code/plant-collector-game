extends StaticBody2D

## 야생 식물 오브젝트 — 실제 스프라이트 + 채집 인터랙션

signal collected(plant_data: Dictionary)

var plant_data: Dictionary = {}
var is_collected = false
var _pending_setup: Dictionary = {}

# 식물 스프라이트시트에서 각 식물의 영역 (6종)
var plant_regions = {
	"라벤더": Rect2(0, 300, 80, 120),
	"민들레": Rect2(90, 300, 80, 120),
	"들꽃": Rect2(180, 300, 80, 120),
	"데이지": Rect2(270, 300, 80, 120),
	"클로버": Rect2(360, 300, 80, 120),
	"제비꽃": Rect2(450, 300, 80, 120),
}

func _ready():
	if not _pending_setup.is_empty():
		_apply_setup(_pending_setup)

func setup(data: Dictionary):
	plant_data = data
	_pending_setup = data
	if is_inside_tree():
		_apply_setup(data)

func _apply_setup(data: Dictionary):
	var spr = $Sprite2D
	var lbl = $Label
	
	if spr:
		# 식물 스프라이트시트에서 해당 식물 영역 추출
		var sheet = preload("res://Assets/Images/wild_plants.png")
		var plant_name = data["name"]
		
		if plant_regions.has(plant_name):
			var region = plant_regions[plant_name]
			var atlas = AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = region
			spr.texture = atlas
		else:
			# 기본: 첫 번째 식물 사용
			var atlas = AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(0, 300, 80, 120)
			spr.texture = atlas
		
		spr.scale = Vector2(0.35, 0.35)
	
	if lbl:
		lbl.text = data["name"]
		lbl.visible = false  # 기본적으로 숨김, 가까이 가면 표시

func on_interact(_player):
	if is_collected:
		return
	
	is_collected = true
	
	var spr = $Sprite2D
	var lbl = $Label
	
	# 채집 이름 표시
	if lbl:
		lbl.visible = true
	
	# 채집 연출: 위로 퐁 + 사라짐
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 15, 0.15).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", position.y - 5, 0.1)
	if spr:
		tween.parallel().tween_property(spr, "modulate:a", 0.0, 0.5)
	if lbl:
		tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		emit_signal("collected", plant_data)
		queue_free()
	)
