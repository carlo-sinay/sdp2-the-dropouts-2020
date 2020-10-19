# SWE30010 - Software Development Project 2 #
Group: The Dropouts

Tutor: Tanjila Kanij

Team:
* Carlo Sinay (100594804)
* Andrej Mitrevski (100580214)
* Robert Petrella (100585206)
* Devaesh Kaggdas (102014430)

## Directory structure
* src - source files
* data - all database files (to be added later)
    * logs - internal log file the program uses
	* export - all exported data like reports
* glade - glade files for the GUI
    * To use download glade and open the .glade file with it. To add functionality, the file can be used inside Vala to build the UI and construct all the relevant callbacks and objects
* refs - contains sample data to be copied into data/

# Building
* Calling `make` in `/src` will compile the terminal (development) version only.
* Calling `make-gui` in `/src` will compile the GUI version only. Both will compile the database itself
* Executable binaries will be in `/build`. Must run the program from `/src` however, for now. Filepaths are hardcoded and relative to where the executable is called from. Need to fix (maybe?)
  * From `/src` run `../build/php-sreps-gui`

# Notes
* The database keeps track of the newest (last) record ID and only moves the file position indicator to the start of any particular line so we can work with strings easier. Only exception is `add_record()` which has to go to EOF but it too puts back the indicator to the start of the last valid line.
* All file seeking should now be done with `seek_to()`, before any file IO is done.
* GUI is just a front-end for database calls. Only "processing" it does is turn the 4 character price string into a nicer format for displaying.
* Doesn't matter if `/data` or `/export` don't exist, program makes those if it can't find them.
* The python scripts in `/src` are just for generating sample logs we can test the program with