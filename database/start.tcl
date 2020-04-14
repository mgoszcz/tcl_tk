#

package require Tk
package require Ttk


source [pwd]/lib/gui.tcl
source [pwd]/lib/list.tcl
source [pwd]/lib/search.tcl


set filepath [pwd]/databases/zagle.csv
set article_list ""
set script_directory [pwd]
set segregators ""
set internal_article_counter 0
set no_save 0

trace variable article_list w "article_list_change article_list"

if ![file isdirectory [pwd]/databases] {file mkdir [pwd]/databases}

proc save_file {} {
	global filepath article_list
	set ch [open $filepath w]
	foreach article $article_list {
		puts $ch [join [lrange [split $article ";"] 0 end-1] ";"]
	}
	close $ch
}

proc read_file {} {
	global filepath article_list internal_article_counter no_save
	set no_save 1
	if [file exists $filepath] {
		set ch [open $filepath r]
		while {![eof $ch]} {
			gets $ch line
			if {$line != ""} {
				lappend article_list "$line;$internal_article_counter"
				incr internal_article_counter
			}
		}
		close $ch
		segregator_list_create
	}
	set no_save 0
}

main_window

read_file





bind . <Control-k> "console show"