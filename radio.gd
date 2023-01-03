extends AudioStreamPlayer2D

const songs_dir : String = "res://assets/songs/"
var songs : Array = []

var song_index : int = -1
var time : float = 0 

func _ready() -> void:
	yield(self, "ready")
	_load_songs()
	switch_song()
	print(songs)
	

func _process(delta : float) -> void:
	time += delta
	if Input.is_action_just_pressed("switch_song") and !$Static.playing:
		switch_song()
	
	
func switch_song() -> void:
	stop()
	
	song_index = (song_index + 1) % songs.size()
	var cur_song : AudioStream = songs[song_index]
	stream = cur_song
	
	$Static.play()
	yield($Static, "finished")
	play(time as int % cur_song.get_length() as int)
	
	
func _load_songs() -> void:
	var dir : Directory = Directory.new()
	dir.open(songs_dir)
	dir.list_dir_begin()
	var file_name : String = dir.get_next()

	while file_name != "": 
		if dir.current_is_dir() or file_name.ends_with(".import"):
			pass
		else:
			songs.append(load(songs_dir + file_name))
			
		file_name = dir.get_next()
