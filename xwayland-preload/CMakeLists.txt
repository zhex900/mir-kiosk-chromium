cmake_minimum_required(VERSION 2.8)

project(xwayland-preload)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -std=c99 -Werror -Wall -Wextra -fPIC")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,defs")

add_definitions( -DSNAPPY_LIBNAME="libxwayland-preload.so" )

add_library(xwayland-preload SHARED preload.c)

target_link_libraries(xwayland-preload -ldl)

install(TARGETS xwayland-preload LIBRARY DESTINATION lib)
#install(PROGRAMS miral-xrun DESTINATION bin)
