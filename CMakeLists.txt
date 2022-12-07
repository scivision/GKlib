cmake_minimum_required(VERSION 3.14...3.25)

project(GKlib LANGUAGES C)

enable_testing()

option(BUILD_TESTING "build self-tests")


include(GKlibSystem.cmake)

add_library(GKlib
b64.c		evaluate.c	gkregex.c	mcore.c		seq.c
blas.c		fkvkselect.c	graph.c		memory.c	sort.c
cache.c		fs.c		htable.c	pqueue.c	string.c
csr.c		getopt.c	io.c		random.c	timers.c
error.c		gk_util.c	itemsets.c	rw.c		tokenizer.c
)
target_link_libraries(GKlib PRIVATE $<$<BOOL:${UNIX}>:m>)
target_include_directories(GKlib PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
$<INSTALL_INTERFACE:include>
)

if(BUILD_TESTING)
  add_subdirectory(test)
endif()

install(TARGETS GKlib)
install(FILES ${GKlib_includes} TYPE INCLUDE)
