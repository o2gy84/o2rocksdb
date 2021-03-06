#.rst:
# ECMEnableSanitizers
# -------------------
#
# Enable compiler sanitizer flags.
#
# The following sanitizers are supported:
#
# - Address Sanitizer
# - Memory Sanitizer
# - Thread Sanitizer
# - Leak Sanitizer
# - Undefined Behaviour Sanitizer
#
# All of them are implemented in Clang, depending on your version, and
# there is an work in progress in GCC, where some of them are currently
# implemented.
#
# This module will check your current compiler version to see if it
# supports the sanitizers that you want to enable
#
# Usage
# =====
#
# Simply add::
#
#    include(ECMEnableSanitizers)
#
# to your ``CMakeLists.txt``. Note that this module is included in
# KDECompilerSettings, so projects using that module do not need to also
# include this one.
#
# The sanitizers are not enabled by default. Instead, you must set
# ``ECM_ENABLE_SANITIZERS`` (either in your ``CMakeLists.txt`` or on the
# command line) to a semicolon-separated list of sanitizers you wish to enable.
# The options are:
#
# - address
# - memory
# - thread
# - leak
# - undefined
#
# The sanitizers "address", "memory" and "thread" are mutually exclusive.  You
# cannot enable two of them in the same build.
#
# "leak" requires the  "address" sanitizer.
#
# .. note::
#
#   To reduce the overhead induced by the instrumentation of the sanitizers, it
#   is advised to enable compiler optimizations (``-O1`` or higher).
#
# Example
# =======
#
# This is an example of usage::
#
#   mkdir build
#   cd build
#   cmake -DECM_ENABLE_SANITIZERS='address;leak;undefined' ..
#
# .. note::
#
#   Most of the sanitizers will require Clang. To enable it, use::
#
#     -DCMAKE_CXX_COMPILER=clang++
#
# Since 1.3.0.

#=============================================================================
# Copyright 2014 Mathieu Tarral <mathieu.tarral@gmail.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# MACRO check_compiler_version
#-----------------------------
macro (check_compiler_version gcc_required_version clang_required_version)
    if (
        (
            CMAKE_CXX_COMPILER_ID MATCHES "GNU"
            AND
            CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${gcc_required_version}
        )
        OR
        (
            CMAKE_CXX_COMPILER_ID MATCHES "Clang"
            AND
            CMAKE_CXX_COMPILER_VERSION VERSION_LESS ${clang_required_version}
        )
    )
        # error !
        message(FATAL_ERROR "You ask to enable the sanitizer ${CUR_SANITIZER},
        but your compiler ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}
        does not support it !
        You should use at least GCC ${gcc_required_version} or Clang ${clang_required_version}
        (99.99 means not implemented yet)")
    endif ()
endmacro ()

# MACRO check_compiler_support
#------------------------------
macro (enable_sanitizer_flags sanitize_option)
    if (${sanitize_option} MATCHES "address")
        check_compiler_version("4.8" "3.1")
        set(XSAN_COMPILE_FLAGS "-fsanitize=address -D__SANITIZE_ADDRESS__ -fno-omit-frame-pointer -fno-optimize-sibling-calls")
        set(XSAN_LINKER_FLAGS "-static-libasan")
    elseif (${sanitize_option} MATCHES "thread")
        check_compiler_version("4.8" "3.1")
        set(XSAN_COMPILE_FLAGS "-fsanitize=thread")
        set(XSAN_LINKER_FLAGS "-static-libtsan")
    elseif (${sanitize_option} MATCHES "memory")
        check_compiler_version("99.99" "3.1")
        set(XSAN_COMPILE_FLAGS "-fsanitize=memory")
    elseif (${sanitize_option} MATCHES "leak")
        check_compiler_version("4.9" "3.4")
        set(XSAN_COMPILE_FLAGS "-fsanitize=leak")
        set(XSAN_LINKER_FLAGS "-static-liblsan")
    elseif (${sanitize_option} MATCHES "undefined")
        check_compiler_version("4.9" "3.1")
        set(XSAN_COMPILE_FLAGS "-fsanitize=undefined -fno-omit-frame-pointer -fno-optimize-sibling-calls")
        set(XSAN_LINKER_FLAGS "-static-libubsan")
    else ()
        message(FATAL_ERROR "Compiler sanitizer option \"${sanitize_option}\" not supported.")
    endif ()
endmacro ()

if (ECM_ENABLE_SANITIZERS)
    if (CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # for each element of the ECM_ENABLE_SANITIZERS list
        foreach ( CUR_SANITIZER ${ECM_ENABLE_SANITIZERS} )
            # lowercase filter
            string(TOLOWER ${CUR_SANITIZER} CUR_SANITIZER)
            # check option and enable appropriate flags
            enable_sanitizer_flags ( ${CUR_SANITIZER} )
            # TODO: GCC will not link pthread library if enabled ASan
            if(CMAKE_C_COMPILER_ID MATCHES "Clang")
              set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${XSAN_COMPILE_FLAGS}" )
            endif()
            set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${XSAN_COMPILE_FLAGS}" )
            if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
              link_libraries(${XSAN_LINKER_FLAGS})
            endif()
            if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                string(REPLACE "-Wl,--no-undefined" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
                string(REPLACE "-Wl,--no-undefined" "" CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}")
            endif ()
        endforeach()
    else()
        message(STATUS "Tried to enable sanitizers (-DECM_ENABLE_SANITIZERS=${ECM_ENABLE_SANITIZERS}), \
but compiler (${CMAKE_CXX_COMPILER_ID}) does not have sanitizer support")
    endif()
endif()
