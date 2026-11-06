extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var level_bar: TextureProgressBar = %Level
@onready var level_label: Label = %LevelLabel

func update_time(time: int) -> void:
    var minutes := time / 60
    var seconds := time % 60
    time_label.text = "%02d:%02d" % [minutes, seconds]

func update_xp(current_xp: float, xp_required: float, level: int) -> void:
    level_bar.max_value = xp_required
    level_bar.value = current_xp
    level_label.text = "Lv: %d" % level
