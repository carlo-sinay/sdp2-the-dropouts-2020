# Sources
* `GTKExample.vala` right now is just an example GTK from the wiki. Later on we'll modify this into our program. Will probably use Glade as well

# Building
* Might need a higher level build system later on (?) but I doubt. Makefile will be enough for now.
* Calling `make` and `make gui` here works on Linux and should on mingw as well provided you have GTK, valac and of course make installed. It'll put the executable in a build dir, dont need to push that but it will be ignored anyway
* makefile will also improve over time, this is just temporary
