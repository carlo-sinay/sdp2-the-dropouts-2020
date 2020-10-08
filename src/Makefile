PROJECT=php-sreps
GUI_APP=php-sreps-gui
COMPILER=valac
GTK_PKG_FLAG=gtk+-3.0
APP_PKG_FLAG=gio-2.0
COMPILER_FLAGS=--pkg ${GTK_PKG_FLAG}
BUILD_DIR := ../build
SRC_FILES += \
  main.vala \
  items.vala \
  database.vala\

all: mkdir ${PROJECT}
${PROJECT}: main.vala database.vala
	${COMPILER} --pkg ${APP_PKG_FLAG} ${SRC_FILES} -o ${BUILD_DIR}/${PROJECT}

mkdir:
	mkdir -p ../build

gui: mkdir
	${COMPILER} --pkg ${GTK_PKG_FLAG} --pkg gmodule-2.0 GUI.vala -o ${BUILD_DIR}/${GUI_APP}