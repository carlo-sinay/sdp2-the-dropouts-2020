# Sources
* `GTKExample.vala` right now is just an example GTK from the wiki. Later on we'll modify this into our program. Will probably use Glade as well

# Building
* Might need a higher level build system later on (?) but I doubt. Makefile will be enough for now.
* Calling `make` and `make gui` here works on Linux and should on mingw as well provided you have GTK, valac and of course make installed. It'll put the executable in a build dir, dont need to push that but it will be ignored anyway
* makefile will also improve over time, this is just temporary

# Notes
* The database keeps track of the newest (last) record ID and only moves the file position indicator to the start of any particular line so we can work with strings easier. Only exception is `add_record()` which has to go to EOF but it too puts back the indicator to the start of the last valid line.
* All file seeking should now be done with `seek_to()`, before any file IO is done.
* The user input menu in main is easy to extend with other testing functionality. Eventually this will be replaced by the GUI. Hopefully having this crude menu here should help in understanding how the Databse should be used.
* No reading input from `stdin` in database code.