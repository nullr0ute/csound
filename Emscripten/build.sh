#!/bin/bash

# Use EMSCRIPTEN variable, set in Emscripten SDK's emsdk_set_env.sh
if [ -z "${EMSCRIPTEN+xxx}" ]; then
  echo "EMSCRIPTEN is not set. Please set it and try again."
  exit 1
fi

echo "Using EMSCRIPTEN: $EMSCRIPTEN"

mkdir -p build
cd build
cmake -DUSE_COMPILER_OPTIMIZATIONS=0 -DINIT_STATIC_MODULES=0 -DUSE_DOUBLE=NO -DBUILD_MULTI_CORE=0 -DBUILD_JACK_OPCODES=0 -DEMSCRIPTEN=1 -DCMAKE_TOOLCHAIN_FILE=$EMSCRIPTEN/cmake/Modules/Platform/Emscripten.cmake -DCMAKE_MODULE_PATH=$EMSCRIPTEN/cmake -DCMAKE_BUILD_TYPE=Release -G"Unix Makefiles" -DHAVE_BIG_ENDIAN=0 -DCMAKE_16BIT_TYPE="unsigned short"  -DHAVE_STRTOD_L=0 -DBUILD_STATIC_LIBRARY=YES -DHAVE_ATOMIC_BUILTIN=0 -DHAVE_SPRINTF_L=NO -DUSE_GETTEXT=NO -DLIBSNDFILE_LIBRARY=../deps/libsndfile-1.0.25/libsndfile-wasm.a -DSNDFILE_H_PATH=../deps/libsndfile-1.0.25/src ../..
emmake make csound-static -j6

# build_CsoundObj.sh
emcc -s LINKABLE=1 -s ASSERTIONS=1 ../src/FileList.c -Iinclude -o FileList.bc
emcc -s LINKABLE=1 -s ASSERTIONS=1 ../src/CsoundObj.c -I../../include -Iinclude -o CsoundObj.bc


# build_libcsound.js.sh
emcc -O3 -DINIT_STATIC_MODULES=0 -s ASSERTIONS=1 -s LINKABLE=1 -s RESERVED_FUNCTION_POINTERS=1 -s EXPORTED_FUNCTIONS="['_strlen', '_CsoundObj_closeAudioOut', '_CsoundObj_compileCSD', '_CsoundObj_compileOrc', '_CsoundObj_destroy', '_CsoundObj_evaluateCode', '_CsoundObj_getControlChannel', '_CsoundObj_getInputBuffer', '_CsoundObj_getInputChannelCount', '_CsoundObj_getKsmps', '_CsoundObj_getOutputBuffer', '_CsoundObj_getOutputChannelCount', '_CsoundObj_getTable', '_CsoundObj_getTableLength', '_CsoundObj_getZerodBFS', '_CsoundObj_new', '_CsoundObj_openAudioOut', '_CsoundObj_pause', '_CsoundObj_performKsmps', '_CsoundObj_play', '_CsoundObj_prepareRT', '_CsoundObj_pushMidiMessage', '_CsoundObj_readScore' , '_CsoundObj_inputMessage', '_CsoundObj_render' , '_CsoundObj_reset', '_CsoundObj_setControlChannel', '_CsoundObj_setMidiCallbacks', '_CsoundObj_setOption', '_CsoundObj_setOutputChannelCallback', '_CsoundObj_getScoreTime', '_CsoundObj_setStringChannel', '_CsoundObj_setTable']" CsoundObj.bc FileList.bc libcsound.a ../deps/libsndfile-1.0.25/src/.libs/libsndfile.a -o libcsound.js


cd ..
rm -rf dist
mkdir dist
cp build/libcsound.js dist/
cp src/*.js dist/
cp build/libcsound.js.mem dist/

