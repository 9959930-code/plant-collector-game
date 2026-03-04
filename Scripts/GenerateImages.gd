extends SceneTree

func _init():
	# 무채색 배경 텍스처 생성 (가상의 비 오는 거리 느낌)
	var bg_img = Image.create(1152, 648, false, Image.FORMAT_RGBA8)
	bg_img.fill(Color(0.2, 0.2, 0.25, 1.0)) # 약간 푸른빛 도는 짙은 회색
	
	# 화면 중간에 대충 길거리 실루엣 느낌의 가로선
	for x in range(1152):
		for y in range(350, 450):
			bg_img.set_pixel(x, y, Color(0.15, 0.15, 0.2, 1.0))
			
	bg_img.save_png("res://Assets/Images/bg_street_placeholder.png")
	
	# 무채색 화분(식물) 텍스처 생성
	var plant_img = Image.create(200, 200, false, Image.FORMAT_RGBA8)
	plant_img.fill(Color(0, 0, 0, 0)) # 투명
	
	# 화분 그리기 (회색)
	for x in range(60, 140):
		for y in range(150, 190):
			plant_img.set_pixel(x, y, Color(0.3, 0.3, 0.3, 1.0))
			
	# 죽어가는 줄기 그리기 (진한 회색)
	for y in range(60, 150):
		plant_img.set_pixel(99, y, Color(0.2, 0.2, 0.2, 1.0))
		plant_img.set_pixel(100, y, Color(0.2, 0.2, 0.2, 1.0))
		plant_img.set_pixel(101, y, Color(0.2, 0.2, 0.2, 1.0))
		
	# 잎 그리기 (회색)
	for x in range(70, 100):
		for y in range(70, 90):
			plant_img.set_pixel(x, y, Color(0.4, 0.4, 0.4, 1.0))
			
	for x in range(100, 130):
		for y in range(100, 120):
			plant_img.set_pixel(x, y, Color(0.4, 0.4, 0.4, 1.0))

	plant_img.save_png("res://Assets/Images/plant_placeholder.png")

	print("Placeholder images generated.")
	quit()
