extends StaticBody2D

## 야생 식물 오브젝트 — 캐릭터가 다가가서 상호작용하면 채집
## 들판에 랜덤 배치되며, 인터랙션 시 채집 애니메이션 재생

signal collected(plant_data: Dictionary)

@onready var sprite = $Sprite2D
@onready var label = $Label

var plant_data: Dictionary = {}
var is_collected = false

func setup(data: Dictionary):
	plant_data = data
	label.text = data["name"]
	sprite.modulate = data["color"]

func on_interact(_player):
	if is_collected:
		return
	
	is_collected = true
	
	# 채집 연출: 위로 튀기 + 사라짐
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 20, 0.2)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		emit_signal("collected", plant_data)
		queue_free()
	)
