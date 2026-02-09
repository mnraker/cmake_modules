# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# Find jsoncpp
#
# Imported targets
# ----------------
# This module defines the following imported targets:
#
# ``JsonCpp::JsonCpp``
#   The jsoncpp library, if found
#
# Result variables
# ----------------
# ``JsonCpp_INCLUDE_DIRS``
#   where to find json.h etc...
# ``JsonCpp_LIBRARIES``
#   the libraries to link against to use jsoncpp
# ``JsonCpp_DLLS``
#   the DLLs (on windows) to ensure it copies over for executables during the
#   build process.
#
find_path(JsonCpp_INCLUDE_DIR
  NAMES json.h
  PATH_SUFFIXES json jsoncpp/json
  HINTS $ENV{JSONCPP_ROOT}/include $ENV{JsonCpp_ROOT}/include /usr/local/include)

# need to find <json/json.h>
set(JsonCpp_INCLUDE_DIRS ${JsonCpp_INCLUDE_DIR}/..)

if(JSONCPP_USE_STATIC_LIBS)
  set(_jsoncpp_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
  set(CMAKE_FIND_LIBRARY_SUFFIXES .a .lib)
  if(NOT IsWindowsPlatform)
    set(_JSONCPP_STATIC_NAMES json jsoncpp)
  else()
    set(_JSONCPP_STATIC_NAMES jsoncpp_static)
  endif()
  find_library(JsonCpp_LIBRARIES
    NAMES ${_JSONCPP_STATIC_NAMES}
    HINTS $ENV{JSONCPP_ROOT}/lib $ENV{JsonCpp_ROOT}/lib /usr/local/lib)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${_jsoncpp_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})
else()
  find_library(JsonCpp_LIBRARIES
    NAMES json jsoncpp
    HINTS $ENV{JSONCPP_ROOT}/lib $ENV{JsonCpp_ROOT}/lib /usr/local/lib)
  find_file(JsonCpp_DLLS
    NAMES json.dll jsoncpp.dll
    HINTS $ENV{JSONCPP_ROOT}/lib $ENV{JsonCpp_ROOT}/lib $ENV{JSONCPP_ROOT}/bin $ENV{JsonCpp_ROOT}/bin)
  if(NOT IsWindowsPlatform)
    set(JsonCpp_DLLS ${JsonCpp_LIBRARIES})
  endif()
endif()

mark_as_advanced(JsonCpp_INCLUDE_DIR JsonCpp_INCLUDE_DIRS JsonCpp_LIBRARIES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(JsonCpp
  REQUIRED_VARS JsonCpp_LIBRARIES JsonCpp_INCLUDE_DIRS
)

if (JsonCpp_FOUND AND NOT TARGET JsonCpp::JsonCpp)
  if(JSONCPP_USE_STATIC_LIBS)
    add_library(JsonCpp::JsonCpp STATIC IMPORTED)
    set_target_properties(JsonCpp::JsonCpp PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_IMPLIB "${JsonCpp_LIBRARIES}"
      IMPORTED_LOCATION "${JsonCpp_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${JsonCpp_INCLUDE_DIRS}")
  else()
    add_library(JsonCpp::JsonCpp SHARED IMPORTED)
    set_target_properties(JsonCpp::JsonCpp PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_IMPLIB "${JsonCpp_LIBRARIES}"
      IMPORTED_LOCATION "${JsonCpp_DLLS}"
      INTERFACE_INCLUDE_DIRECTORIES "${JsonCpp_INCLUDE_DIRS}")
  endif()
endif()


