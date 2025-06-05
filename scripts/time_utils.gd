extends Node
class_name TImeUtils

func get_elapsed_seconds(start_timestamp_milliseconds: int):
	return (Time.get_ticks_msec() - start_timestamp_milliseconds)/1000
