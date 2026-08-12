cmake_minimum_required(VERSION 3.17.5)
project(koreader-lfs LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LuaJIT luajit REQUIRED IMPORTED_TARGET)

if(BUILD_SHARED_LIBS)
    add_library(koreader-lfs MODULE)
else()
    add_library(koreader-lfs STATIC)
endif()
# Koreader installs/loads Lua C modules as *.so even on MinGW.
if(BUILD_SHARED_LIBS)
    set_target_properties(koreader-lfs PROPERTIES SUFFIX ".so")
endif()
set_target_properties(koreader-lfs PROPERTIES C_VISIBILITY_PRESET hidden)
target_link_libraries(koreader-lfs PRIVATE PkgConfig::LuaJIT)
target_sources(koreader-lfs PRIVATE src/lfs.c)
