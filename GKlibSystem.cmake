# Helper modules.
include(CheckFunctionExists)
include(CheckIncludeFile)

# Setup options.
option(GDB "enable use of GDB" OFF)
option(ASSERT "turn asserts on" OFF)
option(ASSERT2 "additional assertions" OFF)
option(DEBUG "add debugging support" OFF)
option(GPROF "add gprof support" OFF)
option(VALGRIND "add valgrind support" OFF)
option(OPENMP "enable OpenMP support" OFF)
option(PCRE "enable PCRE support" OFF)
option(GKREGEX "enable GKREGEX support" OFF)
option(GKRAND "enable GKRAND support" OFF)
option(NO_X86 "enable NO_X86 support")

set(CMAKE_C_STANDARD 99)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|ARM")
  # reportedly not every x86 system defines so in CMAKE_SYSTEM_PROCESSOR
  set(NO_X86 true)
endif()

# Add compiler flags.
if(MSVC)
  add_compile_options(/Ox)
  add_compile_definitions(WIN32 MSC _CRT_SECURE_NO_DEPRECATE USE_GKREGEX)
elseif(MINGW)
  add_compile_definitions(USE_GKREGEX)
else()
  add_compile_definitions(LINUX _FILE_OFFSET_BITS=64)
endif()

if(CYGWIN)
  add_compile_definitions(CYGWIN)
endif(CYGWIN)

if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  add_compile_options(-fno-strict-aliasing)
  if(VALGRIND)
    add_compile_options(-mtune=generic)
  else()
    # add_compile_options(-march=native)
  endif(VALGRIND)
  if(NOT MINGW)
    set(CMAKE_POSITION_INDEPENDENT_CODE true)
  endif(NOT MINGW)
# GCC warnings.
  add_compile_options(-Werror -Wall -pedantic -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unknown-pragmas -Wno-unused-label)
elseif(CMAKE_C_COMPILER_ID STREQUAL "Sun")
# Sun insists on -xc99.
  add_compile_options(-xc99)
endif()

# Intel compiler
if(CMAKE_C_COMPILER_ID MATCHES "^Intel")

endif()

# Find OpenMP if it is requested.
if(OPENMP)
  find_package(OpenMP)
  if(OpenMP_FOUND)
    add_compile_definitions(__OPENMP__)
    add_compile_options(${OpenMP_C_FLAGS})
  else()
    message(WARNING "OpenMP was requested but support was not found")
  endif()
endif(OPENMP)

# Set the CPU type
if(NO_X86)
  add_compile_definitions(NO_X86=${NO_X86})
endif(NO_X86)

# Add various definitions.
if(GDB)
  add_compile_options(-g -Werror)
endif(GDB)

if(GPROF)
  add_compile_options(-pg)
endif(GPROF)

if(NOT ASSERT)
  add_compile_definitions(NDEBUG)
endif(NOT ASSERT)

if(NOT ASSERT2)
  add_compile_definitions(NDEBUG2)
endif(NOT ASSERT2)


# Add various options
if(PCRE)
  add_compile_definitions(__WITHPCRE__)
endif(PCRE)

if(GKREGEX)
  add_compile_definitions(USE_GKREGEX)
endif(GKREGEX)

if(GKRAND)
  add_compile_definitions(USE_GKRAND)
endif(GKRAND)


# Check for features.
check_include_file(execinfo.h HAVE_EXECINFO_H)
if(HAVE_EXECINFO_H)
  add_compile_definitions(HAVE_EXECINFO_H)
endif(HAVE_EXECINFO_H)

check_function_exists(getline HAVE_GETLINE)
if(HAVE_GETLINE)
  add_compile_definitions(HAVE_GETLINE)
endif(HAVE_GETLINE)


# Custom check for TLS.
if(MSVC)
  add_compile_definitions(__thread=__declspec(thread))

  # This if checks if that value is cached or not.
  if(NOT DEFINED HAVE_THREADLOCALSTORAGE)
    message(CHECK_START "checking for thread-local storage")
    try_compile(HAVE_THREADLOCALSTORAGE
      ${CMAKE_BINARY_DIR}
      ${GKLIB_PATH}/conf/check_thread_storage.c)
    if(HAVE_THREADLOCALSTORAGE)
      message(CHECK_PASS "found")
    else()
      message(CHECK_FAIL "not found")
    endif()
  endif()
  if(NOT HAVE_THREADLOCALSTORAGE)
    add_compile_definitions(__thread=)
  endif()
endif()
