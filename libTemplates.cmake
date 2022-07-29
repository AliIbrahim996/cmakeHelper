cmake_minimum_required(VERSION 3.13)

include(${CMAKE_CURRENT_LIST_DIR}/compileTemplates.cmake)

#
# set_default_lib_target_options(LIB_TARGET)
# Make some basic lib adoptions like setting the folder Property, linking to conan dependency's, natvis files, ....
#
function(set_default_lib_target_options LIB_TARGET)
    # add dependencies to target (add include- & link-directories & Properties of dependencies)
    target_link_libraries(${LIB_TARGET} PUBLIC ${CONAN_TARGETS})

    # Settings for Visual Studio properties by visual_studio generator, required for VS to find DLLs when debugging from IDE
    set_target_properties(${LIB_TARGET} PROPERTIES VS_USER_PROPS "${CMAKE_CURRENT_BINARY_DIR}/conanbuildinfo.props")
    
    set_default_target_options(${LIB_TARGET})
endfunction()

#
# generate_default_lib_target([SHARED] [UseQT] [TARGET TargetName] [SOURCES <src>...])
# Generate a default lib target for the current conanpkg.
# conan_basic_setup(TARGETS) must be called before this macro is used
# CONAN_PACKAGE_NAME is used as name for the target unless TARGET is given 
#   CONAN_PACKAGE_NAME(or TargetName) can be used for further adaptions after this macro.
# If SHARED is specified this will generate a SHARED lib otherwise a STATIC lib is generated.
# UseQT can be used if QT shall be used for the library, all *.ui files and res/*.qrc files will be handled with this option.
# SOURCES use this option if you have non-default source file locations(not (only) all files inside include/ and src/).
#       If you use this option you also have to call target_include_directories and source_group yourself.
#
macro(generate_default_lib_target)
    project(${CONAN_PACKAGE_NAME} LANGUAGES CXX)
    set(_options SHARED UseQT)
    set(_one_value_args TARGET)
    set(_multi_value_args SOURCES)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})

    if(NOT _args_TARGET)
        set(_args_TARGET ${CONAN_PACKAGE_NAME})
    endif()

    if(NOT _args_SOURCES)
        FILE(GLOB_RECURSE _args_SOURCES CONFIGURE_DEPENDS include/*.h include/*.hpp include/*.hxx src/*.cpp src/*.cxx src/*.h src/*.hpp src/*.hxx)

        set(addIncludes ON)

        # settings for IDE-visualisation
        source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${_args_SOURCES})
    endif()

    # settings for IDE-visualisation
    source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${QTRES})

    if(_args_SHARED )
        add_library(${_args_TARGET} SHARED ${_args_SOURCES} ${QTRES})
        set_target_properties(${_args_TARGET} PROPERTIES SUFFIX ".plb")
    else()
        add_library(${_args_TARGET} STATIC ${_args_SOURCES} ${QTRES})
    endif()

    if(addIncludes)
        # include-directories (for usage with '<>')
        target_include_directories(${_args_TARGET} PRIVATE src PUBLIC include)
    endif()

    set_default_lib_target_options(${_args_TARGET})
endmacro()

#
# generate_header_only_lib_target([TARGET TargetName] [SOURCES <src>...])
# Generate a default lib target for the current conanpkg.
# conan_basic_setup(TARGETS) must be called before this macro is used
# CONAN_PACKAGE_NAME is used as name for the target unless TARGET is given 
#   CONAN_PACKAGE_NAME(or TargetName) can be used for further adaptions after this macro.
# SOURCES use this option if you have non-default source file locations(not (only) all files inside include/ and src/).
#       If you use this option you also have to call target_include_directories and source_group yourself.
#
macro(generate_header_only_lib_target)
    project(${CONAN_PACKAGE_NAME} LANGUAGES CXX)
    set(_options)
    set(_one_value_args TARGET)
    set(_multi_value_args SOURCES)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})
    if(NOT _args_TARGET)
        set(_args_TARGET ${CONAN_PACKAGE_NAME})
    endif()
    
    if(NOT _args_SOURCES)
        FILE(GLOB_RECURSE _args_SOURCES CONFIGURE_DEPENDS include/*.h include/*.hpp include/*.hxx)

        set(addIncludes ON)

        # settings for IDE-visualisation
        source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${_args_SOURCES})
    endif()

    add_library(${_args_TARGET} INTERFACE)
    target_sources(${_args_TARGET} INTERFACE ${_args_SOURCES})

    # add custom target to show headers in VS IDE
    add_custom_target(${_args_TARGET}Interface SOURCES ${_args_SOURCES})

    if(addIncludes)
        # include-directories (for usage with '<>')
        target_include_directories(${_args_TARGET} INTERFACE include)
    endif()

    # add dependencies to target (add include- & link-directories & Properties of dependencies)
    target_link_libraries(${_args_TARGET} INTERFACE ${CONAN_TARGETS})

    set_target_properties(${_args_TARGET}Interface PROPERTIES FOLDER ${CONAN_PACKAGE_NAME})
endmacro()