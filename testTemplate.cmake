cmake_minimum_required(VERSION 3.13)

include(${CMAKE_CURRENT_LIST_DIR}/compileTemplates.cmake)

#
# set_default_test_target_options(TEST_TARGET)
# Make some basic test adoptions like setting the folder Property, Add the test to BUILD_ALL_TESTS, ....
#
function(set_default_test_target_options TEST_TARGET)
    if(NOT TARGET BUILD_ALL_TESTS)
        add_custom_target(BUILD_ALL_TESTS)
        set_target_properties(BUILD_ALL_TESTS PROPERTIES FOLDER "META_TARGETS")
    endif()
    add_dependencies(BUILD_ALL_TESTS ${TEST_TARGET})

    set_default_target_options(${TEST_TARGET})
endfunction()
#
# generate_default_test_target([MAIN_DEPENDENCY <BaseTarget>][SOURCES <test>...])
# Add a default test target for the current conanpkg, that uses all files in the test dir and where the Lib-target name is equal to the CONAN_PACKAGE_NAME.
# For further addaptions to the test target the variable TEST_TARGET could be used in the calling function/scope.
# SOURCES use this option if you have non-default test file locations(not (only) all files inside test/).
#       If you use this option you also have to call target_include_directories and source_group yourself.
# The TEST_TARGET variable can be used afterwards to further addapt the targt.
#
macro(generate_default_test_target)
    set(_options)
    set(_one_value_args MAIN_DEPENDENCY)
    set(_multi_value_args SOURCES)
    cmake_parse_arguments(_args
                          "${_options}"
                          "${_one_value_args}"
                          "${_multi_value_args}"
                          ${ARGN})
    if(NOT _args_SOURCES)
        FILE(GLOB_RECURSE _args_SOURCES CONFIGURE_DEPENDS test/*.cpp test/*.h test/*.hpp)

        set(addIncludes ON)

        source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${_args_SOURCES})
    endif()
    if(NOT _args_MAIN_DEPENDENCY)
        set(_args_MAIN_DEPENDENCY ${CONAN_PACKAGE_NAME})
    endif()
    set(TEST_TARGET ${_args_MAIN_DEPENDENCY}Tests)

    include(CTest)

    if(BUILD_ALL_WITHOUT_TESTS)
        add_executable(${TEST_TARGET} EXCLUDE_FROM_ALL ${_args_SOURCES})
    else()
        add_executable(${TEST_TARGET} ${_args_SOURCES})
    endif()

    if(addIncludes)
        # include-directories (for usage with '<>')
        target_include_directories(${TEST_TARGET} PRIVATE src include test)
    endif()

    # add dependencies to target (add include- & link-directories & Properties of dependencies)
    target_link_libraries(${TEST_TARGET} ${_args_MAIN_DEPENDENCY})

    set(TEST_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin_test)
    set_target_properties(${TEST_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${TEST_RUNTIME_OUTPUT_DIRECTORY})
    set_target_properties(${TEST_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${TEST_RUNTIME_OUTPUT_DIRECTORY})
    set_target_properties(${TEST_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${TEST_RUNTIME_OUTPUT_DIRECTORY})
    set_target_properties(${TEST_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${TEST_RUNTIME_OUTPUT_DIRECTORY})
    set_target_properties(${TEST_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${TEST_RUNTIME_OUTPUT_DIRECTORY})

    add_test(NAME ${TEST_TARGET} COMMAND ${TEST_TARGET} --gtest_output=xml:${TEST_RUNTIME_OUTPUT_DIRECTORY}/${TEST_TARGET}_results.xml)

    # Settings for Visual Studio properties by visual_studio generator, required for VS to find DLLs when debugging from IDE
    set_target_properties(${TEST_TARGET} PROPERTIES VS_USER_PROPS "${CMAKE_CURRENT_BINARY_DIR}/conanbuildinfo.props")
    # Setting environment path needed if tests are executed outside of visual studio
    if(CONAN_ENV)
        string(REPLACE ";" "\\\\;" Patched_Env ${CONAN_ENV})
        set_property(TEST ${TEST_TARGET} PROPERTY ENVIRONMENT ${Patched_Env})
    endif()

    set_default_test_target_options(${TEST_TARGET})
endmacro()