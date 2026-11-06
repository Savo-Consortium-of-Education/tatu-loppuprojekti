extends CanvasLayer

signal upgrade_finished

func _ready() -> void:
    add_to_group("upgrade_menu")

func finish_upgrade() -> void:
    upgrade_finished.emit()
    queue_free()
