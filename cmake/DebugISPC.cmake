# DebugISPC.cmake

function(dump_ispc_env)
  message(STATUS "=== dump_ispc_env ===")
  foreach(v
    CMAKE_GENERATOR
    CMAKE_BUILD_TYPE
    CMAKE_CONFIGURATION_TYPES
    CMAKE_ISPC_COMPILER
    CMAKE_ISPC_COMPILER_ID
    CMAKE_ISPC_COMPILER_VERSION
    CMAKE_ISPC_COMPILE_OBJECT
    CMAKE_ISPC_CREATE_STATIC_LIBRARY
    CMAKE_ISPC_CREATE_SHARED_LIBRARY
    CMAKE_ISPC_OUTPUT_EXTENSION
  )
    if(DEFINED ${v})
      message(STATUS "  ${v} = ${${v}}")
    else()
      message(STATUS "  ${v} = <UNDEFINED>")
    endif()
  endforeach()
  message(STATUS "=== end dump_ispc_env ===")
endfunction()

function(dump_target t)
  if(NOT TARGET "${t}")
    message(STATUS "[dump_target] '${t}' is not a target")
    return()
  endif()

  message(STATUS "=== dump_target: ${t} ===")
  foreach(p
    TYPE
    SOURCES
    INCLUDE_DIRECTORIES
    INTERFACE_INCLUDE_DIRECTORIES
    COMPILE_DEFINITIONS
    INTERFACE_COMPILE_DEFINITIONS
    COMPILE_OPTIONS
    INTERFACE_COMPILE_OPTIONS
    LINK_LIBRARIES
    INTERFACE_LINK_LIBRARIES
    ISPC_HEADER_SUFFIX
    ISPC_HEADER_DIRECTORY
    ISPC_INSTRUCTION_SETS
    ISPC_ARCH
    ISPC_TARGET_OS
    LINKER_LANGUAGE
  )
    get_target_property(v "${t}" "${p}")
    if(v STREQUAL "v-NOTFOUND")
      set(v "<NOTFOUND>")
    endif()
    message(STATUS "  ${p} = ${v}")
  endforeach()
  message(STATUS "=== end dump_target: ${t} ===")
endfunction()

# Only dump when -DDEBUG_ISPC=ON is passed
set(DEBUG_ISPC OFF CACHE BOOL "Enable ISPC debug logging")

function(dump_if_debug t)
  if(DEBUG_ISPC)
    dump_target("${t}")
  endif()
endfunction()
