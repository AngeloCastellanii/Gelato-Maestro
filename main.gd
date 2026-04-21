extends Control

# --- VARIABLES LÓGICAS Y DE DIFICULTAD ---
var sabores_disponibles = ["Fresa", "Vainilla", "Chocolate", "Menta"]
var receta_cliente = []
var mi_helado = []
var dificultad = "facil"
var es_primer_pedido = true # 

# --- VARIABLES DE ESTADO ---
var puntos = 0
var vidas = 3
var tiempo_cliente = 10.0 

# --- REFERENCIAS A NODOS VISUALES ---
@onready var lbl_pedido = $CajaTextos/LblPedido
@onready var lbl_mi_helado = $CajaTextos/LblMiHelado
@onready var lbl_resultado = $LblResultado
@onready var lbl_puntos = $LblPuntos
@onready var lbl_tiempo = $LblTiempo
@onready var timer_cliente = $TimerCliente
@onready var corazones = [$CajaCorazones/Corazon1, $CajaCorazones/Corazon2, $CajaCorazones/Corazon3]

# --- REFERENCIAS DE PAUSA Y GAME OVER ---
@onready var fondo_oscuro = $CapaUI/FondoOscuro
@onready var caja_pausa = $CapaUI/FondoOscuro/CajaPausa
@onready var caja_game_over = $CapaUI/FondoOscuro/CajaGameOver
@onready var lbl_puntos_finales = $CapaUI/FondoOscuro/CajaGameOver/LblPuntosFinales

# --- REFERENCIAS DE AUDIO ---
@onready var sfx_click = $SfxClick
@onready var sfx_campana = $SfxCampana
@onready var sfx_error = $SfxError

# --- REFERENCIAS VISUALES NPCs Y TORRE ---
@onready var cliente_npc = $ClienteNPC
@onready var caja_torre = $CajaTorre

# --- TEXTURAS DE LOS HELADOS ---
var tex_fresa = preload("res://Assets Godot Project/Sin fondo/Sabor_Fresa-removebg-preview.png")
var tex_vainilla = preload("res://Assets Godot Project/Sin fondo/Sabor_Vainilla-removebg-preview.png") 
var tex_choco = preload("res://Assets Godot Project/Sin fondo/Sabor_Chocolate-removebg-preview.png")
var tex_menta = preload("res://Assets Godot Project/Sin fondo/Sabor_Menta-removebg-preview.png")

var texturas_sabores = {
	"Fresa": tex_fresa,
	"Vainilla": tex_vainilla,
	"Chocolate": tex_choco,
	"Menta": tex_menta
}

# --- TEXTURAS DE LOS CLIENTES ---
var tex_hombre_1 = preload("res://Assets Godot Project/Sin fondo/Cliente_Hombre-removebg-preview.png")
var tex_mujer_1 = preload("res://Assets Godot Project/Sin fondo/Cliente_Mujer-removebg-preview.png")

var tex_chica_gafas = preload("res://Assets Godot Project/Sin fondo/Cliente_mujer_3-removebg-preview.png") # La primera
var tex_mujer_2 = preload("res://Assets Godot Project/Sin fondo/Cliente_Mujer_2-removebg-preview.png") 
var tex_hombre_2 = preload("res://Assets Godot Project/Sin fondo/Cliente_hombre_2-removebg-preview.png")
var tex_hombre_3 = preload("res://Assets Godot Project/Sin fondo/Cliente_hombre_3-removebg-preview.png")

var lista_clientes = []

func _ready():
	randomize()
	# Metemos a los 6 clientes en la lista aleatoria
	lista_clientes = [tex_hombre_1, tex_mujer_1, tex_chica_gafas, tex_mujer_2, tex_hombre_2, tex_hombre_3]
	
	get_tree().paused = false
	fondo_oscuro.visible = false
	lbl_pedido.visible = true
	
	if has_node("ClienteNPC/Burbuja"):
		$ClienteNPC/Burbuja.visible = false
	
	actualizar_stats()
	generar_nuevo_pedido()

func _process(_delta):
	if not timer_cliente.is_stopped():
		lbl_tiempo.text = str(snapped(timer_cliente.time_left, 0.1)) + "s"
		
	if Input.is_action_just_pressed("ui_cancel") and vidas > 0:
		if get_tree().paused == false: activar_pausa()
		else: reanudar_juego()

	if Input.is_action_just_pressed("ui_accept"):
		if cliente_npc.visible and vidas > 0 and not get_tree().paused:
			sfx_click.play()
			_on_btn_entregar_pressed()

# --- FUNCIONES DE PAUSA Y GAME OVER ---
func activar_pausa():
	get_tree().paused = true
	fondo_oscuro.visible = true
	caja_pausa.visible = true
	caja_game_over.visible = false

func reanudar_juego():
	get_tree().paused = false
	fondo_oscuro.visible = false
	caja_pausa.visible = false

func mostrar_game_over():
	get_tree().paused = true
	sfx_error.play() 
	lbl_puntos_finales.text = "Puntos Finales: " + str(puntos)
	fondo_oscuro.visible = true
	caja_pausa.visible = false
	caja_game_over.visible = true

func cambiar_dificultad(nueva_dificultad: String):
	sfx_click.play()
	dificultad = nueva_dificultad
	puntos = 0
	vidas = 3
	es_primer_pedido = true # La chica de lentes vuelve a salir al reiniciar dificultad
	actualizar_stats()
	reanudar_juego()
	generar_nuevo_pedido()


# --- SISTEMA CENTRAL DEL JUEGO ---
func generar_nuevo_pedido():
	if vidas <= 0: return 
	receta_cliente.clear()
	mi_helado.clear()
	
	for hijo in caja_torre.get_children(): hijo.queue_free()
	
	lbl_resultado.text = "Esperando..."
	lbl_resultado.modulate = Color.WHITE
	
	# --- LÓGICA DEL PRIMER CLIENTE ---
	if es_primer_pedido == true:
		cliente_npc.texture = tex_chica_gafas
		es_primer_pedido = false 
	else:
		cliente_npc.texture = lista_clientes.pick_random()
		
	cliente_npc.visible = true 
	
	var cantidad_sabores = 2
	if dificultad == "facil":
		tiempo_cliente = 10.0
		cantidad_sabores = 2
	elif dificultad == "intermedio":
		tiempo_cliente = 7.0
		cantidad_sabores = 3
	elif dificultad == "dificil":
		tiempo_cliente = 5.0
		cantidad_sabores = 5 if randf() <= 0.20 else 4
	
	for i in range(cantidad_sabores):
		receta_cliente.append(sabores_disponibles.pick_random())
	
	lbl_pedido.text = "El cliente pide:\n" + str(receta_cliente)
	actualizar_pantalla()
	timer_cliente.start(tiempo_cliente)

func agregar_sabor(sabor_elegido: String):
	sfx_click.play()
	mi_helado.append(sabor_elegido)
	
	var bola = TextureRect.new()
	bola.texture = texturas_sabores[sabor_elegido]
	bola.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bola.custom_minimum_size = Vector2(80, 80)
	
	caja_torre.add_child(bola)
	caja_torre.move_child(bola, 0)
	
	actualizar_pantalla()

func actualizar_pantalla():
	lbl_mi_helado.text = "Mi helado:\n" + str(mi_helado)

func actualizar_stats():
	lbl_puntos.text = "Puntos: " + str(puntos)
	for i in range(corazones.size()):
		corazones[i].visible = i < vidas

# --- SEÑALES DE LOS BOTONES ---
func _on_btn_fresa_pressed(): agregar_sabor("Fresa")
func _on_btn_vainilla_pressed(): agregar_sabor("Vainilla")
func _on_btn_choco_pressed(): agregar_sabor("Chocolate")
func _on_btn_menta_pressed(): agregar_sabor("Menta")

func _on_btn_entregar_pressed():
	if vidas <= 0 or get_tree().paused: return 
	timer_cliente.stop() 
	
	if mi_helado == receta_cliente:
		sfx_campana.play() 
		lbl_resultado.text = "¡PERFECTO! +100"
		lbl_resultado.modulate = Color.GREEN
		puntos += 100
	else:
		sfx_error.play() 
		lbl_resultado.text = "¡ERROR! -1 Vida"
		lbl_resultado.modulate = Color.RED
		vidas -= 1
	
	actualizar_stats()
	cliente_se_va()

func _on_timer_cliente_timeout():
	sfx_error.play() 
	lbl_resultado.text = "¡TIEMPO AGOTADO!"
	lbl_resultado.modulate = Color.RED
	vidas -= 1
	actualizar_stats()
	cliente_se_va()

func cliente_se_va():
	cliente_npc.visible = false 
	if vidas <= 0:
		lbl_resultado.text = "¡GAME OVER!"
		lbl_pedido.text = ""
		lbl_tiempo.text = "0.0s"
		mostrar_game_over() 
	else:
		await get_tree().create_timer(1.5).timeout
		generar_nuevo_pedido()

func _on_btn_continuar_pressed(): sfx_click.play(); reanudar_juego()
func _on_btn_facil_pressed(): cambiar_dificultad("facil")
func _on_btn_intermedio_pressed(): cambiar_dificultad("intermedio")
func _on_btn_dificil_pressed(): cambiar_dificultad("dificil")
func _on_btn_reintentar_pressed(): sfx_click.play(); get_tree().paused = false; get_tree().reload_current_scene()
func _on_btn_salir_menu_pressed(): sfx_click.play(); get_tree().paused = false; get_tree().change_scene_to_file("res://menu_principal.tscn")
func _on_btn_salir_menu_2_pressed(): sfx_click.play(); get_tree().paused = false; get_tree().change_scene_to_file("res://menu_principal.tscn")
