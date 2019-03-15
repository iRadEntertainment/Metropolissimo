#==============================#
#          UTILITIES           #
#==============================#

extends Node

func arr_min_max(arr):
	var arr_sort = []
	for val in arr:
		arr_sort.push_back(val)
	arr_sort.sort()
	return Vector2(arr_sort[0], arr_sort[arr_sort.size()-1])

func n_base():
	var root=get_tree().get_root()
	return root.get_child(root.get_child_count()-1)

func count_files(path, extention):
	var dir = Directory.new()
	var count = 0
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir(): pass
			else:
				if extention in file_name:
					count += 1
			file_name = dir.get_next()
	else:
		print("UTL: Count_files -> An error occurred when trying to access the path.")
		print(dir.open(path))
	return count

#-------------- Time format from Xrayez
#----(https://godotengine.org/qa/32785/is-there-simple-way-convert-seconds-to-hh-mm-ss-format-in-godot)
enum  {
	FORMAT_HOURS   = 1 << 0,
	FORMAT_MINUTES = 1 << 1,
	FORMAT_SECONDS = 1 << 2
}

func format_time(time, format = FORMAT_MINUTES | FORMAT_SECONDS, digit_format = "%02d"):
	var digits = []
	if format & FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)
	
	if format & FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)
	
	if format & FORMAT_SECONDS:
		var seconds = digit_format % [int(ceil(time)) % 60]
		digits.append(seconds)
	
	var formatted = String()
	var colon = " : "
	
	for idx in digits.size():
		formatted += digits[idx]
		if idx != digits.size() - 1:
			formatted += colon
	
	return formatted