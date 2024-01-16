extends Node2D

@onready var polygon_2d = %Polygon2D
@onready var collision_polygon_2d = %CollisionPolygon2D
@onready var polygon_2d2 = %Polygon2D2
@onready var collision_polygon_2d2 = %CollisionPolygon2D2

func _ready(): 
	RenderingServer.set_default_clear_color(Color.BLACK)
	polygon_2d.polygon = collision_polygon_2d.polygon
	polygon_2d2.polygon = collision_polygon_2d2.polygon
	
