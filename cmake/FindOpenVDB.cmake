# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

# Find OpenVDB
#
# Imported targets
# ----------------
# This module defines the following imported targets:
#
# ``OpenVDB::OpenVDB``
#   The OpenVDB library, if found
#
# Result variables
# ----------------
# ``OpenVDB_INCLUDE_DIRS``
#   where to find openvdb.h etc...
# ``OpenVDB_LIBRARIES``
#   the libraries to link against to use OpenVDB
#
find_path(OpenVDB_INCLUDE_DIR
  NAMES openvdb.h
  PATH_SUFFIXES openvdb
  HINTS $ENV{OPENVDB_ROOT}/include $ENV{OpenVDB_ROOT}/include /usr/local/include)

# need to find <openvdb/openvdb.h>
set(OpenVDB_INCLUDE_DIRS ${OpenVDB_INCLUDE_DIR}/..)

if( OPENVDB_INCLUDE_DIR )
    file( STRINGS "${OPENVDB_INCLUDE_DIR}/openvdb/version.h" TMP REGEX "^#define OPENVDB_LIBRARY_MAJOR_VERSION_NUMBER .*$" )
    string( REGEX MATCHALL "[0-9]+" OPENVDB_VERSION_MAJOR ${TMP} )
    file( STRINGS "${OPENVDB_INCLUDE_DIR}/openvdb/version.h" TMP REGEX "^#define OPENVDB_LIBRARY_MINOR_VERSION_NUMBER .*$" )
    string( REGEX MATCHALL "[0-9]+" OPENVDB_VERSION_MINOR ${TMP} )
    file( STRINGS "${OPENVDB_INCLUDE_DIR}/openvdb/version.h" TMP REGEX "^#define OPENVDB_LIBRARY_PATCH_VERSION_NUMBER .*$" )
    string( REGEX MATCHALL "[0-9]+" OPENVDB_VERSION_PATCH ${TMP} )
    set( OPENVDB_VERSION "${OPENVDB_VERSION_MAJOR}.${OPENVDB_VERSION_MINOR}.${OPENVDB_VERSION_PATCH}" )
endif()

find_library(OpenVDB_LIBRARIES
  NAMES openvdb openvdb-${OPENVDB_VERSION_MAJOR} openvdb-${OPENVDB_VERSION_MAJOR}_${OPENVDB_VERSION_MINOR}
  HINTS $ENV{OPENVDB_ROOT}/lib $ENV{OpenVDB_ROOT}/lib /usr/local/lib)
mark_as_advanced(OpenVDB_INCLUDE_DIR OpenVDB_INCLUDE_DIRS OpenVDB_LIBRARIES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenVDB
  REQUIRED_VARS OpenVDB_LIBRARIES OpenVDB_INCLUDE_DIRS
)

if (OpenVDB_FOUND AND NOT TARGET OpenVDB::OpenVDB)
    add_library(OpenVDB::OpenVDB UNKNOWN IMPORTED)
    set_target_properties(OpenVDB::OpenVDB PROPERTIES
      IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
      IMPORTED_LOCATION "${OpenVDB_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${OpenVDB_INCLUDE_DIRS}")
endif()

