extends Node2D

var songs : Array = []
var song_index : int = -1
var time : float = 0 

onready var static_sound : AudioStreamPlayer2D = $Static

func _ready() -> void:
	songs = get_children()
	songs.erase(static_sound)
	
	switch_song()
	

func _process(delta : float) -> void:
	time += delta
	if Input.is_action_just_pressed("switch_song") and !static_sound.playing:
		switch_song()
	
	
func switch_song() -> void:
	# goes up one song
	song_index = (song_index + 1) % (songs.size() - 1)
	var cur_song : AudioStreamPlayer2D = songs[song_index]
	
	# pauses all other songs
	for song in songs:
		song.playing = false
	
	# plays static to transition
	static_sound.play()
	yield(static_sound, "finished")
	
	cur_song.play(time as int % cur_song.stream.get_length() as int)
