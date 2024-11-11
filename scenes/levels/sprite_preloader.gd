extends ResourcePreloader

@onready var options := get_resource_list().size()

func get_random_sprite() -> Texture2D:
	return get_resource(get_resource_list()[RNG.randi_in_range(0, options - 1)])
