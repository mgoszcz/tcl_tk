#

array set char_map {
	261 a
	263 c
	281 e
	322 l
	324 n
	243 o
	347 s
	378 z
	380 z
}

proc normalize_chars {str} {
	global char_map
	for {set i 0} {$i < [string length $str]} {incr i} {
		foreach key [array names char_map] {
			scan [string index $str $i] %c ascii
			if {$ascii == $key} {
				set str [string replace $str $i $i [lindex [array get char_map $key] 1]]
			}
		}
	}
	return $str
}

proc clear_search {} {
	global article_list title_list
	set title_list ""
	.list.listbox delete 0 end
	.search.entry delete 0 end
	foreach article $article_list {
		lappend title_list "[lindex [split $article \;] 0];[lindex [split $article \;] end]"
		.list.listbox insert end [lindex [split $article ";"] 0]
	}
	update
}

proc populate_listbox {} {
	global title_list
	#puts $title_list
	.list.listbox delete 0 end
	foreach title $title_list {
		.list.listbox insert end [lindex [split $title ";"] 0]
	}
	update
}

proc is_item_already_found {item} {
	global title_list
	foreach title $title_list {
		if {[lindex [split $title ";"] end] == $item} {
			return 1
		}
	}
	return 0
}

proc search {} {
	global article_list title_list title_search tag_search desc_search
	if {[.search.entry get] == ""} {
		clear_search
	} else {
		set pattern [normalize_chars [.search.entry get]]
		set title_list ""
		if $title_search {
			foreach article $article_list {
				if [string match -nocase "*$pattern*" [normalize_chars [lindex [split $article ";"] 0]]] {
					if ![is_item_already_found [lindex [split $article ";"] end]] {
						lappend title_list "[lindex [split $article \;] 0];[lindex [split $article \;] end]"
					}
				}
			}
		}
		if $tag_search {
			foreach article $article_list {
				foreach tag [normalize_chars [split [lindex [split $article ";"] 3] ":"]] {
					if {[string match -nocase "*$tag*" $pattern*] && $tag != ""} {
						#puts $tag
						if ![is_item_already_found [lindex [split $article ";"] end]] {
							lappend title_list "[lindex [split $article \;] 0];[lindex [split $article \;] end]"
						}
						break
					}
				}
			}
		}
		if $desc_search {
			foreach article $article_list {
				if [string match -nocase "*$pattern*" [normalize_chars [lindex [split $article ";"] 4]]] {
					if ![is_item_already_found [lindex [split $article ";"] end]] {
						lappend title_list "[lindex [split $article \;] 0];[lindex [split $article \;] end]"
					}
				}
			}
		}
		populate_listbox 
	}
	description_populate
}