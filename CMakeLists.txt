cmake_minimum_required(VERSION 3.0.2 FATAL_ERROR)
project(o2rocksdb LANGUAGES C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fstack-protector-all -ftree-vectorize -msse2 -mavx")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -Wall -Werror -Wno-address-of-packed-member -Wno-format-truncation -fPIC")

# Find dependencies
#find_package(LZ4 REQUIRED)

#SET(OPENSSL_USE_STATIC_LIBS TRUE)
#find_package(OpenSSL REQUIRED)

##############################################################################
# Dependencies
##############################################################################

## ZStd compression
set(ZSTD_BUILD_STATIC ON CACHE BOOL "BUILD STATIC LIBRARIES")
set(ZSTD_BUILD_PROGRAMS OFF CACHE BOOL "BUILD PROGRAMS")
add_subdirectory(third_party/zstd-1.4.4/build/cmake/)

## GTest
set(BUILD_GTEST ON CACHE BOOL "Builds the googletest subproject")
set(BUILD_GMOCK ON CACHE BOOL "Builds the googlemock subproject")
set(gtest_disable_pthreads ON CACHE BOOL "Disable uses of pthreads in gtest.")
add_subdirectory(third_party/googletest-release-1.8.0)

## GFlags
set(GFLAGS_INTTYPES_FORMAT "C99" CACHE STRING "")
set(GFLAGS_BUILD_TESTING OFF CACHE BOOL "gflags tests")
add_subdirectory(third_party/gflags)

## Rocksdb
set(WITH_SNAPPY ON CACHE BOOL "build with SNAPPY")
set(WITH_ZSTD OFF CACHE BOOL "build with ZStandard")
set(WITH_LZ4 OFF CACHE BOOL "build with LZ4")
set(WITH_TESTS OFF CACHE BOOL "build rocksdb tests")
set(WITH_GFLAGS OFF CACHE BOOL "do not request gflags")
set(WITH_BENCHMARK_TOOLS OFF CACHE BOOL "do not request bench")
add_subdirectory(third_party/rocksdb-6.8.1)

## Logging
add_subdirectory(third_party/spdlog-1.8.1)

## Build services
add_subdirectory(src)


