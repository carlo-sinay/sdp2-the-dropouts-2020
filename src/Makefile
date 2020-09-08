PROJECT=php-sreps
COMPILER=valac
GTK_PKG_FLAG=gtk+-3.0
APP_PKG_FLAG=gio-2.0
COMPILER_FLAGS=--pkg ${GTK_PKG_FLAG}
BUILD_DIR := ../build
SRC_FILES += \
  main.vala \
  database.vala\

${PROJECT}: main.vala database.vala
	${COMPILER} --pkg ${APP_PKG_FLAG} ${SRC_FILES} -o ${BUILD_DIR}/${PROJECT}

gui: GTKExample.vala
	${COMPILER} --pkg ${GTK_PKG_FLAG} GTKExample.vala -o GUIExample
