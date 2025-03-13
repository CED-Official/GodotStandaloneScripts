# ################################ MIT LICENSE ###############################
# Copyright (c) 2025 CED | cedtech.official@gmail.com or ced.official@proton.me
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software to deal in the Software without restriction, including
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# See the MIT License for the full license text:
# https://opensource.org/licenses/MIT

# ############################ FUNCTION METADATA ###########################
# Contributors: CED
# Name: InputBox()
# Description: Creates a popup with a text field and Apply/Cancel buttons.
# Version: 1.0.2 (2025.03.13)
# Compatibility: Godot 4.4.rc2
# → text: The prompt text to display.
# → defaultInput: Default text in the input field.
# → callbackFunction: Function to call when Apply is pressed - receives the input text as parameter.
# ← return: The created popup node (though normally you don't need to store this).

func InputBox(text: String, defaultInput: String, callbackFunction: Callable) -> Popup:
	#SECTION: Theme.
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#222222")
	style.border_color = Color("#444444")
	style.border_width_bottom = 1
	style.border_width_top = 1
	style.border_width_left = 1
	style.border_width_right = 1
	
	var general_focus = style.duplicate()
	general_focus.bg_color = Color("#00000000")
	
	#SECTION: Create flat style for line edit.
	var line_edit_style = style.duplicate()
	line_edit_style.border_color = Color("#00000000")
	line_edit_style.bg_color = Color("#111111")
	
	#SUB-SECTION: Create button styles.
	var button_style = style.duplicate()
	button_style.border_color = Color("#00000000")
	button_style.content_margin_bottom = 6
	button_style.content_margin_top = 6
	button_style.content_margin_left = 10
	button_style.content_margin_right = 10
	var button_style_hover = button_style.duplicate()
	button_style_hover.bg_color = Color("#444444")
	
	#SECTION: Create the popup.
	var popup = PopupPanel.new()
	popup.name = "InputBoxPopup"
	popup.add_theme_stylebox_override("panel", style)
	
	#SECTION: Create the container for all elements with padding.
	var vbox = VBoxContainer.new()
	vbox.set("theme_override_constants/separation", 16)
	vbox.custom_minimum_size = Vector2(300, 0) #NOTE: Height is determined by content.
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER # Don't expand vertically
	
	#SECTION: Add margin container for padding around all edges.
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	
	#SECTION: Add prompt text.
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color("#DDDDDD"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(label)
	
	#SECTION: Add input field.
	var line_edit = LineEdit.new()
	line_edit.text = defaultInput
	line_edit.add_theme_color_override("font_color", Color("#DDDDDD"))
	line_edit.add_theme_stylebox_override("normal", line_edit_style)
	line_edit.add_theme_stylebox_override("focus", general_focus)
	vbox.add_child(line_edit)
	
	#SECTION: Add button container.
	var hbox = HBoxContainer.new()
	hbox.set("theme_override_constants/separation", 10) #PURPOSE: Adds space between buttons.
	hbox.size_flags_horizontal = Control.SIZE_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_END
	hbox.alignment = BoxContainer.ALIGNMENT_END
	
	#SECTION: Add spacer to push buttons to the right.
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND
	hbox.add_child(spacer)
	
	#SECTION: Create Cancel button.
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.add_theme_color_override("font_color", Color("#DDDDDD"))
	cancel_button.add_theme_stylebox_override("normal", button_style)
	cancel_button.add_theme_stylebox_override("hover", button_style_hover)
	cancel_button.add_theme_stylebox_override("focus", general_focus)
	
	#SECTION: Create Apply button.
	var apply_button = Button.new()
	apply_button.text = "Apply"
	apply_button.add_theme_color_override("font_color", Color("#DDDDDD")) 
	apply_button.add_theme_stylebox_override("normal", button_style.duplicate())
	apply_button.add_theme_stylebox_override("hover", button_style_hover)
	apply_button.add_theme_stylebox_override("focus", general_focus)
	
	hbox.add_child(apply_button)
	hbox.add_child(cancel_button)
	vbox.add_child(hbox)
	
	#SECTION: Add vbox to margin container and then to popup.
	margin.add_child(vbox)
	popup.add_child(margin)
	
	#SECTION: Add to scene tree
	get_tree().root.add_child(popup)
	
	#SECTION: Set up signals
	cancel_button.pressed.connect(func(): 
		popup.queue_free()
	)
	apply_button.pressed.connect(func():
		callbackFunction.call(line_edit.text)
		popup.queue_free()
	)
	popup.popup_hide.connect(func(): #PURPOSE: Handle clicking outside the popup.
		popup.queue_free() #NOTE: The popup is usually hidden, but here we delete it.
	)
	
	#SECTION: Make the popup visible at the center of the screen
	popup.popup_centered_clamped(Vector2(300, 0), 0.75)  #INFO: Width of 300, adaptive height, max 75% of screen.
	await RenderingServer.frame_pre_draw #PURPOSE: The popup doesn't appear correctly the first time it is shown.
	popup.popup_centered_clamped(Vector2(300, 0), 0.75) #INFO: Width of 300, adaptive height, max 75% of screen.
	
	line_edit.grab_focus() #PURPOSE: Set focus to the input field.
	
	return popup


