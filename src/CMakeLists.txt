set(SOURCE_FILES
        main.cpp)

add_executable(o2rocksdb ${SOURCE_FILES})
target_link_libraries(o2rocksdb spdlog rocksdb)
