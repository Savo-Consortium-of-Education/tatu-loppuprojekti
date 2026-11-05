
extends CanvasLayer

@onready var deep_space: ColorRect = $DeepSpace
@onready var nebula_layer: ColorRect = $Nebula
@onready var starfield: ColorRect = $Starfield

var camera: Camera2D
var deep_material: ShaderMaterial
var nebula_material: ShaderMaterial
var star_material: ShaderMaterial

func _ready():
    camera = get_viewport().get_camera_2d()
    layer = -1
    
    deep_material = deep_space.material.duplicate()
    nebula_material = nebula_layer.material.duplicate()
    star_material = starfield.material.duplicate()

    deep_space.material = deep_material
    nebula_layer.material = nebula_material
    starfield.material = star_material


func _process(_delta):
    if camera == null:
        return

    var camera_pos = camera.get_screen_center_position()
    var zoom = camera.zoom.x
    var viewport_size = get_viewport().get_visible_rect().size
    var elapsed_time = Time.get_ticks_msec() / 1000.0

    # Animation
    deep_material.set_shader_parameter("time", elapsed_time)
    nebula_material.set_shader_parameter("time", elapsed_time)

    # Deep space
    deep_material.set_shader_parameter("camera_position", camera_pos)
    deep_material.set_shader_parameter("zoom", zoom)
    deep_material.set_shader_parameter("world_scale", viewport_size)

    # Nebula parallax
    nebula_material.set_shader_parameter(
        "camera_position", camera_pos * 0.15
    )
    nebula_material.set_shader_parameter("zoom", zoom)
    nebula_material.set_shader_parameter("world_scale", viewport_size)

    # Starfield
    star_material.set_shader_parameter("camera_position", camera_pos)
    star_material.set_shader_parameter("zoom", zoom)
    star_material.set_shader_parameter("world_scale", viewport_size)
