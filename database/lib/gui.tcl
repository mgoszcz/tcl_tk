#

# procedure to populate description objects when any listbox element is selected (e.g after listbox selection), or to clear descrpition when nothing selected
proc description_populate {} {
	global title_list
	.description.text configure -state normal
	if {[.list.listbox curselection] != ""} {
		set internal_number [lindex [split [lindex $title_list [.list.listbox curselection]] ";"] end]
		set selected_article [get_article_by_number $internal_number]
		.description.text delete 0.0 end
		.description.text insert end [regsub -all {\\n} [lindex [split $selected_article ";"] 4] \n]
		.description.segregator configure -text "Segregator: [lindex [split $selected_article ";"] 1]"
		.description.strona configure -text "Strona: [lindex [split $selected_article ";"] 2]"
		.description.tagi configure -text "Tagi: [join [split [lindex [split $selected_article ";"] 3] ":"] ","]"
	} else {
		.description.text delete 0.0 end
		.description.segregator configure -text "Segregator:"
		.description.strona configure -text "Strona:"
		.description.tagi configure -text "Tagi:"
	}
	.description.text configure -state disabled
}

# main window
proc main_window {} {
	wm title . "Zagle"
	ttk::labelframe .search -text "Wyszukaj"
	ttk::labelframe .list -text "Lista artykulow"
	ttk::labelframe .description -text "Opis"
	
	ttk::entry .search.entry -width 94
	ttk::button .search.go -text "Szukaj" -command search
	ttk::button .search.clear -text "Wyczysc" -command clear_search
	ttk::frame .search.checkbuttons
	checkbutton .search.checkbuttons.title -text "Tytul" -variable title_search
	checkbutton .search.checkbuttons.tag -text "Tagi" -variable tag_search
	checkbutton .search.checkbuttons.description -text "Opis" -variable desc_search
	.search.checkbuttons.title select
	.search.checkbuttons.tag select
	.search.checkbuttons.description select
	
	listbox .list.listbox -width 104 -height 15 -exportselection 0
	ttk::scrollbar .list.scroll -command ".list.listbox yview"
	.list.listbox configure -yscrollcommand ".list.scroll set"
	ttk::frame .list.buttons
	ttk::button .list.buttons.add -text "Dodaj" -command add_new_window
	ttk::button .list.buttons.delete -text "Usun" -command delete_article
	ttk::button .list.buttons.edit -text "Edytuj" -command edit_article
	
	text .description.text -state disabled
	ttk::label .description.segregator -text "Segregator:"
	ttk::label .description.strona -text "Strona:"
	ttk::label .description.tagi -text "Tagi:"
	
	grid .search -row 0 -column 0 -sticky wen
	grid .search.entry .search.go -sticky wen
	grid .search.checkbuttons -row 1 -column 0 -sticky w
	grid .search.clear -row 1 -column 1
	grid .search.checkbuttons.title .search.checkbuttons.tag .search.checkbuttons.description
	grid .list -row 1 -column 0 -sticky wen
	grid .list.listbox -row 0 -column 0 -sticky wen
	grid .list.scroll -row 0 -column 1 -sticky ns
	grid .list.buttons -row 1 -column 0
	grid .list.buttons.add .list.buttons.delete .list.buttons.edit
	grid .description -row 2 -column 0 -sticky wen
	grid .description.text -row 0 -column 0 -sticky wen
	grid .description.segregator -row 1 -column 0 -sticky w
	grid .description.strona -row 2 -column 0 -sticky w
	grid .description.tagi -row 3 -column 0 -sticky w
	
	grid columnconfigure . 0 -weight 1
	grid rowconfigure . 0 -weight 1
	grid columnconfigure .search 0 -weight 1
	grid rowconfigure .search 0 -weight 1
	grid columnconfigure .list 0 -weight 1
	grid rowconfigure .list 0 -weight 1
	grid columnconfigure .description 0 -weight 1
	grid rowconfigure .description 0 -weight 1
	grid rowconfigure .description 1 -weight 1
	grid rowconfigure .description 2 -weight 1
	
	bind .list.listbox <<ListboxSelect>> "description_populate"
	bind .search.entry <Return> "search"
}

# populate segregator combobox
proc segregator_combo_update {} {
	global segregators
	.add.entry_segregator configure -values $segregators
}

# Add new article window
proc add_new_window args {
	if {$args == ""} {
		set title ""
		set description ""
		set segregator ""
		set strona ""
		set tagi ""
		set mode add
		set window_title "Dodaj nowy artykul"
	} else {
		set title [lindex [split [lindex $args 0] ";"] 0]
		set segregator [lindex [split [lindex $args 0] ";"] 1]
		set strona [lindex [split [lindex $args 0] ";"] 2]
		set tagi [join [split [lindex [split [lindex $args 0] ";"] 3] ":"] ","]
		set description [lindex [split [lindex $args 0] ";"] 4]
		set mode edit
		set window_title "Edytuj artykul"
	}
	toplevel .add
	wm transient .add .
	wm title .add $window_title
	wm attributes . -disabled 1
	wm geometry .add "+[expr [winfo x .] + [winfo x .]/2]+[expr [winfo y .] + [winfo y .]/2]"
	ttk::label .add.label_title -text "Tytul:"
	ttk::entry .add.entry_title -width 90
	.add.entry_title insert end $title
	ttk::label .add.label_description -text "Opis:"
	text .add.entry_description -width 68 -height 10
	.add.entry_description insert end [regsub -all {\\n} $description \n]
	ttk::label .add.label_segregator -text "Segregator:"
	ttk::combobox .add.entry_segregator -width 87
	segregator_combo_update
	.add.entry_segregator insert end $segregator
	ttk::label .add.label_strona -text "Strona:"
	ttk::entry .add.entry_strona -width 90
	.add.entry_strona insert end $strona
	ttk::label .add.label_tagi -text "Tagi (np. tag1,tag2):"
	ttk::entry .add.entry_tagi -width 90
	.add.entry_tagi insert end $tagi
	ttk::frame .add.buttons
	ttk::button .add.buttons.dodaj -text "OK" -command "add_article $mode"
	ttk::button .add.buttons.cancel -text "Cancel" -command "destroy .add"
	
	grid .add.label_title -row 0 -column 0 -sticky e
	grid .add.entry_title -row 0 -column 1
	grid .add.label_description -row 1 -column 0 -sticky e
	grid .add.entry_description -row 1 -column 1
	grid .add.label_segregator -row 2 -column 0 -sticky e
	grid .add.entry_segregator -row 2 -column 1
	grid .add.label_strona -row 3 -column 0 -sticky e
	grid .add.entry_strona -row 3 -column 1
	grid .add.label_tagi -row 4 -column 0 -sticky e
	grid .add.entry_tagi -row 4 -column 1
	grid .add.buttons -row 5 -column 1 -sticky e
	grid .add.buttons.dodaj .add.buttons.cancel
	bind .add <Escape> "destroy .add"
	bind .add <Destroy> "wm attributes . -disabled 0"
	
	focus -force .add.entry_title
}