cmake_minimum_required(VERSION 3.21...4.3)

if(NOT CMAKE_BUILD_TYPE AND NOT DEFINED ENV{CMAKE_BUILD_TYPE})
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type")
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.3)
  set(_spdx_license SPDX_LICENSE "Apache-2.0 AND LGPL-2.1-or-later AND BSD-3-Clause")
endif()

project(GKlib LANGUAGES C
VERSION 1.0.0
${_spdx_license}
)

include(GNUInstallDirs)

option(GKlib_BUILD_TESTING "Build tests")

option(BUILD_SHARED_LIBS "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND GKlib_IS_TOP_LEVEL)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/local" CACHE PATH "install prefix" FORCE)
endif()

set(CMAKE_C_STANDARD 99)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} CMake ${CMAKE_VERSION} Arch: ${CMAKE_SYSTEM_PROCESSOR} install prefix: ${CMAKE_INSTALL_PREFIX}")

set(GKLIB_PATH ${PROJECT_SOURCE_DIR})

include(GKlibSystem.cmake)

set(GKlib_sources src/b64.c	src/evaluate.c src/mcore.c src/seq.c
src/blas.c src/fkvkselect.c	src/graph.c src/memory.c src/sort.c
src/cache.c src/fs.c src/htable.c	src/pqueue.c src/string.c
src/csr.c	src/io.c src/random.c src/timers.c
src/error.c src/gk_util.c	src/itemsets.c src/rw.c src/tokenizer.c
)

add_library(GKlib ${GKlib_sources})
target_include_directories(GKlib PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_link_libraries(GKlib
PUBLIC $<$<BOOL:${UNIX}>:m>
PRIVATE $<$<BOOL:${OPENMP}>:OpenMP::OpenMP_C>
)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.1)
  set_target_properties(GKlib PROPERTIES SPDX_LICENSE "Apache-2.0 AND LGPL-2.1-or-later AND BSD-3-Clause")
endif()

add_library(GKlib::GKlib ALIAS GKlib)

## LGPL library

add_library(GKlib_vendor include/gk_mksort.h src/getopt.c $<$<BOOL:${GKREGEX}>:src/gkregex.c>)
target_include_directories(GKlib_vendor PRIVATE include)
target_link_libraries(GKlib PUBLIC GKlib_vendor)
if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.1)
  set_target_properties(GKlib_vendor PROPERTIES SPDX_LICENSE "LGPL-2.1-or-later")
endif()

if(GKlib_BUILD_TESTING)
  enable_testing()
endif()

add_subdirectory(apps)

install(TARGETS GKlib GKlib_vendor EXPORT ${PROJECT_NAME}-targets)

install(FILES include/GKlib.h TYPE INCLUDE)
# must have trailing slash or it makes a vestigial subdir
install(DIRECTORY include/ TYPE INCLUDE FILES_MATCHING PATTERN "gk_*.h")

include(cmake/install.cmake)
