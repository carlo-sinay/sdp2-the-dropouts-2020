#!/bin/sh
valac --pkg gtk+-3.0 --pkg gee-0.8 --library=Caroline -H Caroline.h ../src/Caroline.vala ../src/types/Bar.vala ../src/types/Line.vala ../src/types/Scatter.vala ../src/types/LineSmooth.vala ../src/types/Pie.vala -X -fPIC -X -shared -o Caroline.so
valac --pkg gtk+-3.0 --pkg gee-0.8 Caroline.vapi ../src/Sample.vala -X Caroline.so -X -I. -o demo
sudo cp Caroline.so /usr/lib/
./demo
