#

# add new article - after button press
proc add_article {mode} {
	global article_list internal_article_counter title_list
	set validation_error ""
	set title [.add.entry_title get]
	if {$title == ""} {
		lappend validation_error "Pole 'Tytul' nie moze byc puste!"
	}
	set description [join [lrange [split [.add.entry_description get 0.0 end] "\n"] 0 end-1] "\\n"]
	set segregator [.add.entry_segregator get]
	if {$segregator == ""} {
		lappend validation_error "Pole 'Segregator' nie moze byc puste!"
	}
	set strona [.add.entry_strona get]
	if {$strona == ""} {
		lappend validation_error "Pole 'Strona' nie moze byc puste!"
	}
	set tagi [.add.entry_tagi get]
	set tagi [join [split $tagi ","] ":"]
	if {$validation_error == ""} {
		if {$mode == "add"} {
			incr internal_article_counter
			lappend article_list "${title};${segregator};${strona};${tagi};${description};$internal_article_counter"
		} elseif {$mode == "edit"} {
			set counter [lindex [split [lindex $title_list [.list.listbox curselection]] ";"] end]
			set article_list [lreplace $article_list [get_article_index $counter] [get_article_index $counter] "${title};${segregator};${strona};${tagi};${description};$counter"]
		}
		add_new_segregator $segregator
		set article_list [lsort $article_list]
		destroy .add
		description_populate
	} else {
		tk_messageBox -icon error -type ok -parent .add -title Blad -message [join $validation_error \n]
	}
}

# edit article already placed in list
proc edit_article {} {
	global title_list
	if {[.list.listbox curselection] != ""} {
		add_new_window [get_article_by_number [lindex [split [lindex $title_list [.list.listbox curselection]] ";"] end]]
	}
}

# remove article from list and csv
proc delete_article {} {
	global title_list article_list
	if {[.list.listbox curselection] != ""} {
		set index [get_article_index [lindex [split [lindex $title_list [.list.listbox curselection]] ";"] end]]
		if {[tk_messageBox -icon warning -type yesno -parent . -title "Usun artykul" -message "Czy na pewno chcesz usunac artykul?\nPo usunieciu nie bedzie mozna go przywrocic."] == yes} {
			set article_list [lreplace $article_list $index $index]
			description_populate
		}
	}
}

# generate titles list, save csv
proc article_list_change {varname args} {
	global article_list title_list filepath no_save
	set title_list ""
	.list.listbox delete 0 end
	.search.entry delete 0 end
	foreach article $article_list {
		lappend title_list "[lindex [split $article \;] 0];[lindex [split $article \;] end]"
		.list.listbox insert end [lindex [split $article ";"] 0]
	}
	if !$no_save {
		save_file
	}
	
}

proc add_new_segregator {value} {
	global segregators
	if {[lsearch $segregators $value] == -1} {
		lappend segregators $value
		set segregators [lsort $segregators]
	}
}

proc segregator_list_create {} {
	global article_list
	foreach article $article_list {
		add_new_segregator [lindex [split $article ";"] 1]
	}
}

proc get_article_by_number {number} {
	global article_list
	foreach article $article_list {
		if {[lindex [split $article ";"] end] == $number} {
			return $article
		}
	}
}

proc get_article_index {number} {
	global article_list
	set i 0
	foreach article $article_list {
		if {[lindex [split $article ";"] end] == $number} {
			return $i
		}
		incr i
	}
}
