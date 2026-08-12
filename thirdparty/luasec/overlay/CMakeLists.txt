cmake_minimum_required(VERSION 3.17.5)
project(luasec LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(LuaJIT luajit REQUIRED IMPORTED_TARGET)
pkg_check_modules(OpenSSL openssl REQUIRED IMPORTED_TARGET)

if(BUILD_SHARED_LIBS)
    add_library(ssl MODULE)
    # Koreader installs/loads Lua C modules as *.so even on MinGW.
    set_target_properties(ssl PROPERTIES C_VISIBILITY_PRESET hidden PREFIX "" SUFFIX ".so")
else()
    # MONOLIBTIC (Android): install expects ssl.a.
    add_library(ssl STATIC)
    set_target_properties(ssl PROPERTIES C_VISIBILITY_PRESET hidden PREFIX "")
endif()
target_compile_definitions(ssl PRIVATE -DWITH_LUASOCKET)
target_include_directories(ssl PRIVATE ${CMAKE_INSTALL_PREFIX}/include)
target_link_libraries(ssl PRIVATE
    ${CMAKE_INSTALL_PREFIX}/lib/libluasocket.a
    PkgConfig::LuaJIT
    PkgConfig::OpenSSL
)
if(WIN32)
    # Plain path to libluasocket.a does not propagate its PUBLIC ws2_32;
    # ssl.c/x509.c also call WSAGetLastError/inet_ntop directly.
    target_link_libraries(ssl PRIVATE ws2_32)
endif()
target_sources(ssl PRIVATE
    src/options.c
    src/x509.c
    src/context.c
    src/ssl.c
    src/config.c
    src/ec.c
)
