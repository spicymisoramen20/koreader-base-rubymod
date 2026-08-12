cmake_minimum_required(VERSION 3.17.5)
project(lpeg LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LuaJIT luajit REQUIRED IMPORTED_TARGET)

if(BUILD_SHARED_LIBS)
    add_library(lpeg MODULE)
    set_target_properties(lpeg PROPERTIES
        C_STANDARD 99
        PREFIX ""
        # Koreader installs/loads Lua C modules as *.so even on MinGW.
        SUFFIX ".so"
    )
else()
    # MONOLIBTIC (Android): install expects lpeg.a.
    add_library(lpeg STATIC)
    set_target_properties(lpeg PROPERTIES
        C_STANDARD 99
        PREFIX ""
    )
endif()
target_link_libraries(lpeg PRIVATE PkgConfig::LuaJIT)
target_sources(lpeg PRIVATE
    lpcap.c
    lpcode.c
    lpcset.c
    lpprint.c
    lptree.c
    lpvm.c
)
