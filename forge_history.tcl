#!/bin/sh
# \
exec tclsh $0 $@

proc randomInt {max} {
	return [expr {int(rand()*$max) + 1}]
}

proc randomMessage {messages} {
	set message [lindex $messages [randomInt [llength $messages]]]
	if { $message == "" } {
		set message [randomMessage $messages]
	}
	return $message
}

set messagesFile "commit_messages.txt"
if { ! [file exists $messagesFile] } {
	puts "No commit messages file to use, exiting."
	exit 1
}

set fh [open $messagesFile r]
set data [read $fh]
close $fh
# Use a special delimiter since commit messages may be more than one line.
set messages [split $data "$$$"]
if { [llength $messages] < 1 } {
	puts "There are no commit messages in the file, exiting."
	exit 1
}

puts "How many days should be forged?"
set numDays [read -nonewline stdin]
puts "What's the minimum number of commits per day?"
set minCommits [read -nonewline stdin]
puts "What's the maximum number of commits per day?"
set maxCommits [read -nonewline stdin]
set fileName "advice.txt"

for {set i 0} {$i < $numDays} {incr i} {
	set date [exec date -v -[expr $numDays - $i]d]
	set numCommits [exec jot -r 1 $minCommits $maxCommits]
	for {set j 0} {$j < $numCommits} {incr j} {
		set fortune [exec fortune]
		set fh [open $fileName w+]
		puts $fh $fortune
		close $fh
		exec git add $fileName
		set message [randomMessage $messages]
		exec git commit -m "$message" --date "$date"
	}
}
