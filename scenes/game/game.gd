extends Node2D

# This script is on the main game state and event managing node.

# Preloading the powerup pickup scene.
const POWERUP_PICKUP := preload("res://scenes/game/entity/powerup/powerup_pickup.tscn")
# Texts used by the different messages displayed in game.
# In a larger project these should be read from seperate files that enable
# localization to be made.
const CHECKPOINT_MESSAGE := "GAME_CHECKPOINT"
const GAME_OVER_MESSAGE := "GAME_OVER"
const VICTORY_MESSAGE := "GAME_VICTORY"
# Some basic constant numbers used by the game node.
const LEVEL_WIDTH := 1920.0
const GAME_OVER_DELAY := 4.0
const VICTORY_DELAY := 5.0
const MUSIC_FADE := 4.0

# Triggered once exiting the game. Used to return to the main menu.
signal exit_game()

# Getting node references.
onready var main_node := find_parent("Main")
onready var player_node := $Player
onready var gui_node := $GuiLayer/GameGui
onready var powerup_spawn_point := $PowerupSpawnPoint
onready var music_game := $Music/Game
onready var music_boss := $Music/Boss

# The level to be used is added as a scene to this exported variable.
# This would allow for multiple different levels to be loaded in a larger game.
export(PackedScene) var level_scene
# This is a dictionary of powerups that the game can spawn.
export(Dictionary) var powerup_list
# This array of strings determines the (repeating) order powerups are spawned in.
export(Array, String) var powerup_order

# A few more variables to manage the game state.
var game_running := false
var level_node
var powerup_index := 0
var current_checkpoint := ""
var tween := Tween.new()

func _ready():
	# At the start, the level scene is instanced as a child.
	# The level is reloaded upon starting a new game anyway, but this might help
	# with loading times, since the first instancing (which might be slow) is
	# done right away.
	level_node = level_scene.instance()
	add_child(level_node)
	add_child(tween)
	# The tween used by the game node has to process even when paused.
	tween.pause_mode = PAUSE_MODE_PROCESS
	# Connecting the game altering signals of the player.
	player_node.connect("player_death", self, "player_death")
	player_node.connect("player_destroyed", self, "player_destroyed")
	# Making the in-game gui initially invisible.
	gui_node.modulate = Color.transparent

# This method handles starting a new game session.
func start_game():
	# Resetting score handled by the global score manager.
	ScoreManager.reset_score()
	# Resetting checkpoint.
	current_checkpoint = ""
	# The player has a method to reset all upgrades, position etc. to defaults.
	player_node.reset_player(true)
	# Reloading the level.
	reload_level()
	# Fading in the in-game gui.
	tween.interpolate_property(gui_node, "modulate", null, Color.white, 1.0)
	tween.start()
	# Game is now running.
	game_running = true
	# Play the in-game music.
	play_music()

# This method handles the conclusion of a game session.
# The boolean determines which of the two possible outcomes the game ends with,
# running out of lives or defeating the boss.
func game_over(victory: bool = false):
	# Game is not running anymore.
	game_running = false
	# The message displayed depends on if the player won or not.
	if victory:
		gui_node.center_message(tr(VICTORY_MESSAGE))
	else:
		gui_node.center_message(tr(GAME_OVER_MESSAGE))
		# Also if defeated, the destroyed player ship can't move anymore.
		player_node.controllable = false
	# Stop the music.
	stop_music()
	# There is a delay while the message is displayed.
	yield(get_tree().create_timer(GAME_OVER_DELAY), "timeout")
	# If the player won, control is taken away only at this point.
	player_node.controllable = false
	# If the player won, there is an additional animation for the ship.
	if victory:
		player_node.player_victory()
	# Stop the level from scrolling.
	level_node.running = false
	# Set the gui score value.
	# Normally this number animates, but here it skips to the final value
	# instantly for the final score to show during high score input screen.
	gui_node.set_score(ScoreManager.score)
	# Check if the score value should be entered as a new high score.
	if ScoreManager.check_highscore():
		gui_node.enter_score()
	else:
		exit_game()

# This method exists out of the game in preparation for returning to the main menu.
func exit_game():
	# Stopping game running, level scrolling and player controls.
	# These are set in the game over method too, but called here again in case
	# the exiting is happening through the pause menu.
	game_running = false
	level_node.running = false
	player_node.controllable = false
	# Emit exit game signal for transfer back to menus.
	emit_signal("exit_game")
	# Stop in-game music if not already stopped by a game over.
	stop_music()
	# Delay while the menu fades in, then reset score and remove level node.
	yield(get_tree().create_timer(0.5), "timeout")
	ScoreManager.reset_score()
	remove_level()

# Method removes the level node if it exists.
func remove_level():
	if level_node != null:
		level_node.queue_free()
		level_node = null

# This method reloads the level. This is done to reset all the enemies and reset
# scrolling to the correct checkpoint.
func reload_level():
	# Remove the level and then wait a frame for the node tree to update.
	remove_level()
	yield(get_tree(), "idle_frame")
	# Instance a new level from the scene and add it as a child.
	level_node = level_scene.instance()
	add_child(level_node)
	# If the current checkpoint is not the default, reset to that checkpoint.
	if current_checkpoint != "":
		# Adjust the level scroll position based on a value from the checkpoint.
		level_node.position.y -= level_node.checkpoints[current_checkpoint].level_scroll
		# Account for player spawn offset.
		level_node.position.y += player_node.SPAWN_OFFSET.y * get_viewport_rect().size.y
		# Don't display the checkpoint reached message of the checkpoint respawned at.
		level_node.checkpoints[current_checkpoint].display_message = false
	# Reset the player bullet parent's node reference, since it was outdated.
	player_node.player_gun.bullets_parent = level_node.bullets
	# Connect all the level's checkpoints' reached signals.
	for checkpoint in level_node.checkpoints:
		level_node.checkpoints[checkpoint].connect("checkpoint_reached", self, "checkpoint_reached")
	# Center level node horizontally in viewport
	level_node.position.x = (get_viewport_rect().size.x - LEVEL_WIDTH) / 2.0
	# Level is ready to start scrolling
	level_node.running = true

# Called right as the player ship is destroyed, stopping the in-game music.
func player_destroyed():
	stop_music()

# Handles player death events. Has an argument for once lives have run out.
func player_death(out_of_lives: bool):
	# If the player is out of lives, call game over and exit method.
	if out_of_lives:
		game_over()
		return
	# If still continuing, reset the level to the correct checkpoint.
	reload_level()
	# Reset the player.
	player_node.reset_player()
	# Call the global score manager to reduce the player's score.
	ScoreManager.death_penalty()
	# Start playing the in-game music again.
	play_music()

# Once a certain amount of score is reached, the game spawns a powerup.
func spawn_powerup():
	# Powerups are based on resources. A pickup scene is instanced and
	# customises itself according to the powerup it "contains".
	var powerup_node = POWERUP_PICKUP.instance()
	# Check the powerup order to provide to correct powerup type.
	var powerup_type = powerup_order[powerup_index]
	# Load the powerup resource based on the type from the order array.
	powerup_node.powerup_resource = load(powerup_list[powerup_type])
	# Set the fixed powerup pickup spawn position.
	powerup_node.position = powerup_spawn_point.position
	# Compensate for level scrolling.
	powerup_node.position -= level_node.global_position
	# Deferredly add the powerup child as a child of the powerups parent node.
	level_node.powerups.call_deferred("add_child", powerup_node)
	# Increment the powerup index for determining powerup spawn order.
	if powerup_index < powerup_order.size() - 1:
		powerup_index += 1
	else:
		powerup_index = 0

# Method for handing checkpoint reaching. Has multiple arguments provided by the signal.
func checkpoint_reached(checkpoint_name: String, display_message: bool, stop_music: bool):
	# Checkpoints are identified by their name.
	current_checkpoint = checkpoint_name
	# Set all the checkpoints as active.
	for checkpoint in level_node.checkpoints:
		level_node.checkpoints[checkpoint].active = true
	# Then revert this current reached checkpoint to inactive.
	level_node.checkpoints[checkpoint_name].active = false
	# Display the checkpoint reached message.
	if display_message:
		gui_node.center_message(tr(CHECKPOINT_MESSAGE))
	# Stop the music if the checkpoint calls for it. Used before the boss fight.
	if stop_music:
		stop_music()
	ScoreManager.score_checkpoint()

# Called when the boss fight starts to trigger the music.
func on_boss_started():
	play_music(true)

# Called when the boss is defeated.
func on_boss_defeated():
	stop_music()
	# Wait a frame for any powerups that the score reward of the boss would
	# give to spawn and then remove them.
	yield(get_tree(), "idle_frame")
	for node in level_node.powerups.get_children():
		node.queue_free()
	# Additional delay for the boss destruction sequence to finish.
	yield(get_tree().create_timer(VICTORY_DELAY), "timeout")
	# Call game over method with the true victory argument.
	game_over(true)

# This method handles playing music. Optional boolean is for playing boss music.
func play_music(boss: bool = false):
	# Determine if playing regular or boss music. Reset volume of any fades.
	if boss:
		tween.remove(music_boss, "volume_db")
		music_boss.play()
		music_boss.volume_db = 0.0
	else:
		tween.remove(music_game, "volume_db")
		music_game.play()
		music_game.volume_db = 0.0

# This method handles stopping music playback.
func stop_music():
	# Check which music is playing and add a tween to fade out volume.
	if music_game.playing:
		tween.interpolate_property(music_game, "volume_db", null, -80.0, MUSIC_FADE)
	if music_boss.playing:
		tween.interpolate_property(music_boss, "volume_db", null, -80.0, MUSIC_FADE)
	tween.start()
	# Wait for the music to fade away, then check if the volume is low enough
	# to safely stop the music audio player.
	yield(get_tree().create_timer(MUSIC_FADE), "timeout")
	if music_game.volume_db < -70.0:
		music_game.stop()
	if music_boss.volume_db < -70.0:
		music_boss.stop()

# This unhandled input callback let's the player pause the game if the player
# ship is controllable currently.
func _unhandled_input(event):
	if game_running and player_node.controllable:
		if event.is_action_pressed("pause"):
			var pause = $GuiLayer/Pause
			if pause.visible == false:
				pause.pause(true)
