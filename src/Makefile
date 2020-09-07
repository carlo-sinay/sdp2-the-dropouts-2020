PROJECT=php-ereps
VC=valac
GTK_PKG_FLAG=gtk+-3.0
CFLAGS=--pkg ${GTK_PKG_FLAG}

${PROJECT}: main.vala database.vala
	${VC} main.vala database.vala -o ${PROJECT}

gui: GTKExample.vala
	${VC} --pkg ${GTK_PKG_FLAG} GTKExample.vala -o GUIExample
