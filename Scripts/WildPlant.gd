extends StaticBody2D

## 야생 식물 오브젝트 — 캐릭터가 다가가서 상호작용하면 채집

signal collected(plant_data: Dictionary)

var plant_data: Dictionary = {}
var is_collected = false
var _pending_setup: Dictionary = {}

func _ready():
	# setup()이 _ready() 전에 호출될 수 있으므로 여기서 적용
	if not _pending_setup.is_empty():
		_apply_setup(_pending_setup)

func setup(data: Dictionary):
	plant_data = data
	_pending_setup = data
	# _ready 이후라면 바로 적용
	if is_inside_tree():
		_apply_setup(data)

func _apply_setup(data: Dictionary):
	var lbl = $Label
	var spr = $Sprite2D
	if lbl:
		lbl.text = data["name"]
		lbl.visible = true
	if spr:
		spr.modulate = data["color"]

func on_interact(_player):
	if is_collected:
		return
	
	is_collected = true
	
	var spr = $Sprite2D
	var lbl = $Label
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.2)
	if spr:
		tween.parallel().tween_property(spr, "modulate:a", 0.0, 0.4)
	if lbl:
		tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		emit_signal("collected", plant_data)
		queue_free()
	)
