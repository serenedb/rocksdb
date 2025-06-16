# -*- mode: CMAKE; -*-

set(FAIL_ON_WARNINGS OFF CACHE BOOL "do not enable -Werror")

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-suggest-override")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-suggest-override")
endif()

# we want the following definitions to be in effect for both rocksdb and serenedb
add_definitions("-DNROCKSDB_THREAD_STATUS")
add_definitions("-DROCKSDB_SUPPORT_THREAD_LOCAL")

# IPO_ENABLED is set by the top-level CMakeLists.txt file
if (IPO_ENABLED)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION True)
endif()

# jemalloc settings
if ("${SDB_ALLOC}" MATCHES "JE")
  if (WIN32)
    set(USE_JEMALLOC_DEFAULT 1                                  CACHE BOOL "enable jemalloc")
    set(JEMALLOC_INCLUDE     ${JEMALLOC_HOME}/include           CACHE PATH "include path")
    set(JEMALLOC_LIB_DEBUG   ${JEMALLOC_HOME}/lib/libjemalloc.a CACHE FILEPATH "debug library")
    set(JEMALLOC_LIB_RELEASE ${JEMALLOC_HOME}/lib/libjemalloc.a CACHE FILEPATH "release library")
  else ()
    set(WITH_JEMALLOC        ON                                 CACHE BOOL "enable jemalloc")
    set(JEMALLOC_INCLUDE     ${JEMALLOC_HOME}/include           CACHE PATH "include path")
    set(JEMALLOC_LIBRARIES   jemalloc CACHE PATH "library file")
    set(THIRDPARTY_LIBS      jemalloc)
  endif ()
else ()
  set(WITH_JEMALLOC OFF CACHE BOOL "enable jemalloc" FORCE)
endif ()

if (WIN32)
  set(WITH_MD_LIBRARY OFF CACHE BOOL "override option in rocksdb lib" FORCE) #libraries should not touch this (/MD /MT) at all!
endif ()

set(PORTABLE ON CACHE BOOL "enable portable rocksdb build (disabling might yield better performance but break portability)" FORCE)
if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
  set(FORCE_SSE42 ON CACHE BOOL "force building with SSE4.2, even when PORTABLE=ON" FORCE)
  set(FORCE_AVX ON CACHE BOOL "force building with AVX, even when PORTABLE=ON" FORCE)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "arm64|aarch64|AARCH64")
  set(FORCE_SSE42 OFF CACHE BOOL "force building with SSE4.2, even when PORTABLE=ON" FORCE)
  set(FORCE_AVX OFF CACHE BOOL "force building with AVX, even when PORTABLE=ON" FORCE)
endif ()

set(ROCKSDB_BUILD_SHARED OFF CACHE BOOL "build shared libraries")
set(WITH_TOOLS OFF CACHE BOOL "disable tools")
set(WITH_BENCHMARK_TOOLS OFF CACHE BOOL "disable benchmark tools")
set(WITH_CORE_TOOLS OFF CACHE BOOL "disable core tools")
set(WITH_TESTS OFF CACHE BOOL "disable tests")
set(WITH_ALL_TESTS OFF CACHE BOOL "disable all tests")
set(WITH_EXAMPLES OFF CACHE BOOL "disable all examples")
set(WITH_LIBURING ON CACHE BOOL "enable io_uring" FORCE)
set(WITH_LZ4 ON CACHE BOOL "force enable lz4")
set(WITH_SNAPPY OFF CACHE BOOL "force enable snappy")
set(SNAPPY_INCLUDE_DIR "${SNAPPY_SOURCE_DIR};${SNAPPY_BUILD_DIR}" CACHE PATH "relation to snappy")
if (MSVC) 
  set(SNAPPY_ROOT_DIR "${SNAPPY_SOURCE_DIR}" CACHE PATH "snappy source")
  set(SNAPPY_HOME "${SNAPPY_SOURCE_DIR}" CACHE PATH "snappy source")
  set(SNAPPY_INCLUDE "${SNAPPY_INCLUDE_DIR}" CACHE PATH "where the wintendo should look for the snappy libs")
  set(SNAPPY_LIB_DEBUG "${CMAKE_BINARY_DIR}/bin/Debug/${SNAPPY_LIB}.lib")
  set(SNAPPY_LIB_RELEASE "${CMAKE_BINARY_DIR}/bin/RelWithDebInfo/${SNAPPY_LIB}.lib")
  set(WITH_WINDOWS_UTF8_FILENAMES ON CACHE BOOL "we want to provide utf8 filenames")
endif ()
set(USE_RTTI ON CACHE BOOL "enable RTTI")

# note: the actual timestamp does not matter here. we only want it to be
# a fixed value, so that building at different timestamps produces the same
# binary executable and build id. 
# the build date of RocksDB is not used by SereneDB at all.
set(BUILD_DATE "2020-11-11 11:11:11" CACHE STRING "the time we first built rocksdb")
