extends Node2D
	

func generate_layers(texture : Texture, num_layers : int) -> void:
	_clear_old_sprites()
	
	var cutout_length : int = texture.get_width() / num_layers
	var cutout_size : Vector2 = Vector2(cutout_length, cutout_length)
	
	for i in range(num_layers):
		var layer : Sprite = Sprite.new()
		var cutout : AtlasTexture = AtlasTexture.new()
		cutout.atlas = texture
		cutout.region = Rect2(Vector2(cutout_length * i, 0), cutout_size)
		
		layer.texture = cutout
		add_child(layer)
		layer.position = Vector2.UP * i
	
	
func _clear_old_sprites() -> void:
	for child in get_children():
		child.queue_free()
		
	
func _process(delta : float) -> void:
	if abs(global_rotation) > 0.00001:
		var difference = global_rotation
		global_rotation = 0
		for sprite in get_children():
			sprite.global_rotation += difference
