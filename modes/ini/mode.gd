extends TextForgeMode


func _initialize_mode() -> Error:
	syntax_highlighter = CodeHighlighter.new()
	syntax_highlighter.add_color_region(";", "", Color.WEB_GRAY, true)
	syntax_highlighter.function_color = Color.WHITE
	syntax_highlighter.number_color = Color.WHITE
	syntax_highlighter.symbol_color = Color.AQUAMARINE
	syntax_highlighter.member_variable_color = Color.WHITE
	comment_delimiters.append({
		"start_key": ";",
		"end_key": "",
		"line_only": true,
	})
	comment_delimiters.append({
		"start_key": "#",
		"end_key": "",
		"line_only": true,
	})
	string_delimiters.append({
		"start_key": "\"",
		"end_key": "\"",
		"line_only": false,
	})
	string_delimiters.append({
		"start_key": "\'",
		"end_key": "\'",
		"line_only": false,
	})
	_enable_auto_format_feature()
	return OK


func _auto_format(text: String) -> String:
	var config := ConfigFile.new()
	config.parse(text)
	var formatted := config.encode_to_text()
	return formatted


func _generate_outline(text: String) -> Array:
	var outline: Array
	var config = ConfigFile.new()
	config.parse(text)
	for section in config.get_sections():
		var section_array: Array = []

		section_array.append(section)
		section_array.append(_find_section_line(text, section))

		for key in config.get_section_keys(section):
			section_array.append([key, _find_key_line(text, section, key)])

		outline.append(section_array)
	return outline


func _find_section_line(content: String, section: String) -> int:
	var section_pattern := "\\[\\s*" + section + "\\s*\\]"
	var regex := RegEx.new()
	regex.compile(section_pattern)

	for l in content.split("\n").size():
		var line = content.split("\n")[l].strip_edges()
		if line.begins_with(";") or line.begins_with("#") or line == "":
			continue

		if regex.search(line) != null:
			return l

	return -1


func _find_key_line(content: String, section: String, key: String) -> int:
	var section_pattern := "\\[\\s*" + section.c_escape() + "\\s*\\]"
	var key_pattern := "^" + key.c_escape() + "\\s*=.*"
	var section_regex := RegEx.new()
	var key_regex := RegEx.new()
	section_regex.compile(section_pattern)
	key_regex.compile(key_pattern)

	var in_target_section = false

	for l in content.split("\n").size():
		var line = content.split("\n")[l].strip_edges()
		if line.begins_with(";") or line.begins_with("#") or line == "":
			continue

		if section_regex.search(line) != null:
			in_target_section = true
			continue

		if in_target_section:
			if line.begins_with("["):
				break

			if key_regex.search(line) != null:
				return l

	return -1
