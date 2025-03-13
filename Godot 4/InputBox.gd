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

# ############################# STANDALONE SCRIPT ############################
# Name: InputBox()
# Description: Creates a popup with a text field and Apply/Cancel buttons.
# Version: 1.0 (2025.03.13)
# → text: The prompt text to display.
# → defaultInput: Default text in the input field.
# → callbackFunction: Function to call when Apply is pressed - receives the input text as parameter.
# ← return: The created popup node (though normally you don't need to store this).

func InputBox(text: String, defaultInput: String, callbackFunction: Callable) -> Popup:
	# Create the popup
	var popup = PopupPanel.new()
	popup.name = "InputBoxPopup"

	# Set theme properties for dark theme
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#131313")
	style.border_color = Color("#444444")
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	# Removed corner radius settings to have no rounded borders
	
	popup.add_theme_stylebox_override("panel", style)
	
	# Create the container for all elements with padding
	var vbox = VBoxContainer.new()
	vbox.set("theme_override_constants/separation", 16) # Increased separation
	vbox.custom_minimum_size = Vector2(300, 0) # Let height be determined by content
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER # Don't expand vertically
	
	# Add margin container for padding around all edges
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	
	# Add prompt text
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color("#DDDDDD"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(label)
	
	# Add input field
	var line_edit = LineEdit.new()
	line_edit.text = defaultInput
	line_edit.add_theme_color_override("font_color", Color("#DDDDDD"))
	
	# Create flat style for line edit
	var line_edit_style = style.duplicate()
	vbox.add_child(line_edit)
	line_edit.add_theme_stylebox_override("normal", line_edit_style)
	
	# Add button container
	var hbox = HBoxContainer.new()
	hbox.set("theme_override_constants/separation", 10) # Add space between buttons
	hbox.size_flags_horizontal = Control.SIZE_FILL
	hbox.size_flags_vertical = Control.SIZE_SHRINK_END
	hbox.alignment = BoxContainer.ALIGNMENT_END
	
	# Add spacer to push buttons to the right
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND
	hbox.add_child(spacer)
	
	# Create Cancel button
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.add_theme_color_override("font_color", Color("#DDDDDD"))
	
	# Create flat button style
	var button_style = style.duplicate()
	cancel_button.add_theme_stylebox_override("normal", button_style)
	
	# Create Apply button
	var apply_button = Button.new()
	apply_button.text = "Apply"
	apply_button.add_theme_color_override("font_color", Color("#DDDDDD")) 
	apply_button.add_theme_stylebox_override("normal", button_style.duplicate())
	
	hbox.add_child(cancel_button)
	hbox.add_child(apply_button)
	vbox.add_child(hbox)
	
	# Add vbox to margin container and then to popup
	margin.add_child(vbox)
	popup.add_child(margin)
	
	# Add to scene tree
	get_tree().root.add_child(popup)
	
	# Set up signals
	cancel_button.pressed.connect(func(): 
		popup.queue_free()
	)
	
	apply_button.pressed.connect(func():
		callbackFunction.call(line_edit.text)
		popup.queue_free()
	)
	
	# Handle clicking outside
	popup.popup_hide.connect(func():
		popup.queue_free()
	)
	

	# Make the popup visible at the center of the screen
	popup.popup_centered_clamped(Vector2(300, 0), 0.75)  # Width of 300, adaptive height, max 75% of screen
	await RenderingServer.frame_pre_draw
	popup.size = Vector2(0,0)
	popup.popup_centered_clamped(Vector2(300, 0), 0.75)
	
	# Set focus to the input field
	line_edit.grab_focus()
	
	return popup

