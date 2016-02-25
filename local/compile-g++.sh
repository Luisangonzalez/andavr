export TEMP=/sdcard/Android/data/com.n0n3m4.droidc/files/gcc/tmpdir
/sdcard/Android/data/com.n0n3m4.droidc/files/gcc/bin/arm-linux-androideabi-g++ -msoft-float -I/sdcard/Android/data/com.n0n3m4.droidc/files/gcc/arm-linux-androideabi/c++/include -lm -ldl -llog -lz -lGLESv1_CM -lEGL -Wl,-allow-shlib-undefined -Wfatal-errors $*
echo "errorcode:$?"