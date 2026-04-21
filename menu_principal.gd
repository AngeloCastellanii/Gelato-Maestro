extends Control

# Referencias a nuestros nodos
@onready var panel_creditos = $PanelCreditos
@onready var sfx_click = $SfxClick

func _ready() -> void:
	panel_creditos.visible = false

func _process(delta: float) -> void:
	pass

func _on_iniciar_pressed() -> void:
	sfx_click.play()
	# Esperamos 0.2 segundos para que el sonido termine antes de cambiar de escena
	await get_tree().create_timer(0.2).timeout 
	get_tree().change_scene_to_file("res://Gelatomain.tscn")

func _on_creditos_pressed() -> void:
	sfx_click.play()
	panel_creditos.visible = true

func _on_salir_pressed() -> void:
	sfx_click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _on_btn_cerrar_creditos_pressed() -> void:
	sfx_click.play()
	panel_creditos.visible = false
