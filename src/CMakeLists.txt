set(SOURCE_FILES
        main.cpp)

include_directories(${PROJECT_SOURCE_DIR}/third_party/rocksdb-6.8.1/include)

add_executable(o2rocksdb ${SOURCE_FILES})
target_link_libraries(o2rocksdb spdlog rocksdb)
