# Copyright 2023-2024 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

if(GLD STREQUAL "$ENV{STUDIO}")
    set(mixed_case_packages IlmBase OpenEXR Imath)
    function(componentNames SConscript_COMPONENTS ssl public_libs)
        set(libs_used)
        foreach(lib ${public_libs})
            if(lib STREQUAL Boost::boost)
                list(APPEND libs_used boost_headers)
            elseif(lib MATCHES "Boost::([A-Za-z0-9_]*)")
                list(APPEND libs_used "boost_${CMAKE_MATCH_1}_mt")
            elseif(lib STREQUAL OpenSSL::SSL)
                set(ssl "\n        'ssl'," PARENT_SCOPE)
            elseif(lib STREQUAL Libuuid::Libuuid)
                list(APPEND libs_used uuid)
            elseif(lib STREQUAL Libcurl::Libcurl)
                list(APPEND libs_used curl_no_ldap)
            elseif(lib STREQUAL CUDA::cudart)
                list(APPEND libs_used cuda)
            elseif(lib STREQUAL OpenImageIOMoonray::OpenImageIOMoonray)
                list(APPEND libs_used oiio)
            elseif(lib STREQUAL OpenImageIO::OpenImageIO)
                list(APPEND libs_used OpenImageIO)
            elseif(lib STREQUAL OpenImageDenoise)
                list(APPEND libs_used OpenImageDenoise)
            elseif(lib STREQUAL cgroup)
                # ignore
            else()
                string(REGEX REPLACE
                       "([A-Za-z0-9_]+)::([A-Za-z0-9_]+)" "\\1;\\2" lib_list "${lib}"
                       )
                list(LENGTH lib_list lib_list_len)
                if(lib_list_len LESS 2)
                    set(package "")
                    list(GET lib_list 0 lib)
                else()
                    list(GET lib_list 0 package)
                    list(GET lib_list 1 lib)
                endif()
                if(package IN_LIST mixed_case_packages)
                else()
                    string(TOLOWER ${lib} lib)
                endif()
                list(APPEND libs_used "${lib}")
            endif()
        endforeach()
        list(SORT libs_used)
        set(my_components)
        foreach(lib ${libs_used})
            set(my_components "${my_components}\n        '${lib}',")
        endforeach()
        set(SConscript_COMPONENTS "\n    COMPONENTS = [${my_components}\n        ],"
            PARENT_SCOPE)
    endfunction()

    function(SConscript_Stub name)
        get_target_property(lib_name ${name} OUTPUT_NAME)
        if (lib_name STREQUAL lib_name-NOTFOUND)
            set(lib_name ${name})
        endif()

        set(ssl)
        get_target_property(public_libs ${name} INTERFACE_LINK_LIBRARIES)
        if(public_libs STREQUAL public_libs-NOTFOUND)
            set(SConscript_COMPONENTS)
        else()
            componentNames(SConscript_COMPONENTS ssl "${public_libs}")
        endif()

        get_target_property(srcs ${name} SOURCES)
        if(srcs STREQUAL srcs-NOTFOUND)
            set(SConscript_LIBS)
        else()
            set(SConscript_LIBS
                "\n    LIBS = [\n        folioDir.File('lib64/lib${lib_name}.so'),${ssl}\n        ],")
        endif()

        find_file(SConscript_in NAMES SConscript.in PATHS ${CMAKE_MODULE_PATH})
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${lib_name})
        configure_file(${SConscript_in}
            ${CMAKE_CURRENT_BINARY_DIR}/${lib_name}/SConscript)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${lib_name}/SConscript
            DESTINATION SConscripts/${lib_name}
            PERMISSIONS
              OWNER_READ OWNER_WRITE
              GROUP_READ GROUP_WRITE
              WORLD_READ
        )
    endfunction(SConscript_Stub name)
else()
    function(SConscript_Stub name)
    endfunction()
endif()
