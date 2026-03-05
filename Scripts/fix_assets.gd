extends SceneTree

func _init():
	# 1. 자연 타일셋 간격 수리 (80x80 -> 64x64 로 잘라서 병합)
	var img = Image.load_from_file("res://Assets/Images/tileset_nature.png")
	var new_img = Image.create_empty(8 * 64, 8 * 64, true, Image.FORMAT_RGBA8)
	
	for r in range(8):
		for c in range(8):
			var rect = Rect2i(c * 80 + 8, r * 80 + 8, 64, 64)
			var dest = Vector2i(c * 64, r * 64)
			new_img.blit_rect(img, rect, dest)
			
	new_img.save_png("res://Assets/Images/tileset_nature_fixed.png")
	
	# 2. 야생 식물 고정 좌표로 수리 (640x640 -> 6x1 의 64x64 스프라이트로 압축)
	var p_img = Image.load_from_file("res://Assets/Images/wild_plants.png")
	var np_img = Image.create_empty(6 * 64, 64, true, Image.FORMAT_RGBA8)
	
	for c in range(6):
		var cx = int(c * 106.6 + 53)
		var cy = 320
		var rect = Rect2i(cx - 32, cy - 32, 64, 64)
		var dest = Vector2i(c * 64, 0)
		np_img.blit_rect(p_img, rect, dest)
	
	np_img.save_png("res://Assets/Images/wild_plants_fixed.png")
	
	print("ASSETS_FIXED_SUCCESS")
	quit()
