cmake_minimum_required(VERSION 3.13)

function(set_default_target_options TARGET)
    set_target_properties(${TARGET} PROPERTIES FOLDER ${CONAN_PACKAGE_NAME})

    if(MSVC)
        # /bigobj: needed for larger libraries with many symbols
        # /MP: allow multiprocessor build
        # /WX: enable warnings as errors
        # enable compiler warnings:
        #    /W4: enable all level 4 warnings
        #    /w44062: The enumerator has no associated case handler in a switch statement, and there's no default label that can catch it.
        # disable compiler warnings:
        #    /wd4324: 'struct_name' : structure was padded due to __declspec(align()) [legacy for toolset 14.15]
        target_compile_options(${TARGET} PRIVATE /bigobj /MP /WX /W4 /w44062 /wd4324 /GR /EHsc)

        # /WX: enable warnings as errors
        # /ignore:4099: "PDB 'filename' was not found with 'object/library' or at 'path'; linking object as if no debug info" The mixin.plb is missing in the 'adtf_display_toolbox'
        target_link_options(${TARGET} PRIVATE /WX /ignore:4099)
    else(MSVC)
        # enable warnings as errors
        # enable all compiler warnings
        target_compile_options(${TARGET} PRIVATE -Werror -Wextra -Wall -Wpedantic)

        # --fatal-warnings: treat linker errors as warnings
        target_link_options(${TARGET} PRIVATE -Wl,--fatal-warnings)
    endif(MSVC)

    target_sources(${TARGET} PRIVATE ${NatvisFiles})
    source_group(NatvisFiles FILES ${NatvisFiles})

endfunction()