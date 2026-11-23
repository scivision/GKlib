# Build programs.

set(GKLIB_PROGRAMS strings gksort fis gkrw gkgraph csrcnv grKx m2mnbrs cmpnbrs
                   splatt2svd gkuniq)

foreach(prog IN LISTS GKLIB_PROGRAMS)
  add_executable(${prog} ${prog}.c)
  target_link_libraries(${prog} PRIVATE GKlib)

  if(NOT prog MATCHES "m2mnbrs|cmpnbrs|splatt2svd")
    add_test(NAME ${prog} COMMAND ${prog})
    set_tests_properties(${prog} PROPERTIES ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:$<TARGET_FILE_DIR:GKlib>")
  endif()
endforeach()

if("$ENV{CI}")
  set_tests_properties(strings PROPERTIES DISABLED true)
  # macOS: subprocess aborted
  # Windows: 0xc0000374
endif()

install(TARGETS csrcnv)
