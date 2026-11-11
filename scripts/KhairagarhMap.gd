extends Node3D

func _ready() -> void:
	build_khairagarh_environment()

func build_khairagarh_environment() -> void:
	# Ground Terrain
	var ground = create_box(Vector3(0, -0.5, 0), Vector3(250, 1, 250), Color(0.28, 0.45, 0.22)) # Grass
	add_child(ground)
	
	# Roads (Asphalt)
	var main_road = create_box(Vector3(0, 0.02, 0), Vector3(18, 0.05, 200), Color(0.18, 0.18, 0.2))
	var cross_road = create_box(Vector3(0, 0.02, 0), Vector3(200, 0.05, 18), Color(0.18, 0.18, 0.2))
	add_child(main_road)
	add_child(cross_road)

	# 1. Gol Bazar (Center roundabout + Market stalls)
	var roundabout = create_cylinder(Vector3(0, 0.2, 0), 12.0, 0.4, Color(0.4, 0.4, 0.4))
	var clock_tower = create_box(Vector3(0, 6, 0), Vector3(4, 12, 4), Color(0.78, 0.72, 0.6))
	add_child(roundabout)
	add_child(clock_tower)
	build_market_shops(Vector3(-25, 0, -25))
	
	# 2. Bus Stand (Shelter + Buses)
	build_bus_stand(Vector3(45, 0, 30))

	# 3. Indira Kala Sangeet Vishwavidyalaya (Campus building with pillars)
	build_university(Vector3(60, 0, -60))

	# 4. Arts College Khairagarh
	build_arts_college(Vector3(-60, 0, 50))

	# 5. Water Tank Landmark (Tall cylinder + Stilt legs)
	build_water_tank(Vector3(25, 0, -45))

	# 6. Khairagarh Temple Area (Shikhara structure)
	build_temple(Vector3(-55, 0, -50))

	# Scatter tactical crates and walls for cover
	scatter_covers()

func create_box(pos: Vector3, size: Vector3, col: Color) -> StaticBody3D:
	var body = StaticBody3D.new()
	body.position = pos
	
	var col_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	col_shape.shape = box_shape
	body.add_child(col_shape)
	
	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	var mat = StandardMaterial3D.new()
	mat.albedo_color = col
	box_mesh.material = mat
	mesh_inst.mesh = box_mesh
	body.add_child(mesh_inst)
	
	return body

func create_cylinder(pos: Vector3, radius: float, height: float, col: Color) -> StaticBody3D:
	var body = StaticBody3D.new()
	body.position = pos
	
	var col_shape = CollisionShape3D.new()
	var cyl_shape = CylinderShape3D.new()
	cyl_shape.radius = radius
	cyl_shape.height = height
	col_shape.shape = cyl_shape
	body.add_child(col_shape)
	
	var mesh_inst = MeshInstance3D.new()
	var cyl_mesh = CylinderMesh.new()
	cyl_mesh.top_radius = radius
	cyl_mesh.bottom_radius = radius
	cyl_mesh.height = height
	var mat = StandardMaterial3D.new()
	mat.albedo_color = col
	cyl_mesh.material = mat
	mesh_inst.mesh = cyl_mesh
	body.add_child(mesh_inst)
	
	return body

func build_market_shops(origin: Vector3) -> void:
	for i in range(4):
		var shop = create_box(origin + Vector3(i * 9, 2.5, 0), Vector3(7, 5, 8), Color(0.85, 0.75, 0.55))
		add_child(shop)

func build_bus_stand(origin: Vector3) -> void:
	var canopy = create_box(origin + Vector3(0, 4.5, 0), Vector3(25, 0.5, 12), Color(0.2, 0.45, 0.75))
	add_child(canopy)
	# Buses
	var bus1 = create_box(origin + Vector3(-6, 1.8, 0), Vector3(4, 3.6, 9), Color(0.9, 0.2, 0.2))
	var bus2 = create_box(origin + Vector3(6, 1.8, 0), Vector3(4, 3.6, 9), Color(0.15, 0.6, 0.25))
	add_child(bus1)
	add_child(bus2)

func build_university(origin: Vector3) -> void:
	var main_hall = create_box(origin + Vector3(0, 6, 0), Vector3(32, 12, 18), Color(0.82, 0.78, 0.72))
	var dome = create_cylinder(origin + Vector3(0, 13, 0), 6.0, 3.0, Color(0.88, 0.85, 0.4))
	add_child(main_hall)
	add_child(dome)

func build_arts_college(origin: Vector3) -> void:
	var wing_a = create_box(origin, Vector3(26, 8, 14), Color(0.72, 0.65, 0.6))
	add_child(wing_a)

func build_water_tank(origin: Vector3) -> void:
	# Stilt legs
	for dx in [-3, 3]:
		for dz in [-3, 3]:
			var leg = create_box(origin + Vector3(dx, 7, dz), Vector3(0.8, 14, 0.8), Color(0.4, 0.4, 0.42))
			add_child(leg)
	# Elevated Tank
	var tank = create_cylinder(origin + Vector3(0, 16, 0), 5.5, 6.0, Color(0.75, 0.8, 0.85))
	add_child(tank)

func build_temple(origin: Vector3) -> void:
	var base = create_box(origin + Vector3(0, 2, 0), Vector3(16, 4, 16), Color(0.88, 0.55, 0.35))
	var shikhara = create_cylinder(origin + Vector3(0, 8, 0), 4.5, 8.0, Color(0.92, 0.4, 0.15))
	add_child(base)
	add_child(shikhara)

func scatter_covers() -> void:
	var crate_positions = [
		Vector3(12, 1, 15), Vector3(-14, 1, 8), Vector3(5, 1, -20),
		Vector3(-8, 1, -12), Vector3(25, 1, 20), Vector3(-30, 1, -5)
	]
	for pos in crate_positions:
		var crate = create_box(pos, Vector3(2, 2, 2), Color(0.55, 0.38, 0.2))
		add_child(crate)
