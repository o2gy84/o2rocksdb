#include <iostream>

#include "rocksdb/db.h"
#include "rocksdb/slice.h"
#include "rocksdb/options.h"

std::string kDBPath = "/tmp/rocksdb_simple_example";
namespace rocks = ROCKSDB_NAMESPACE;

int main(int argc, char *argv[]) {
    rocks::DB* db;
    rocks::Options options;

    // Optimize RocksDB. This is the easiest way to get RocksDB to perform well
    options.IncreaseParallelism();
    options.OptimizeLevelStyleCompaction();

    // create the DB if it's not already present
    options.create_if_missing = true;

    // open DB
    rocks::Status s = rocks::DB::Open(options, kDBPath, &db);
    assert(s.ok());

    s = db->Put(rocks::WriteOptions(), "key1", "value");
    assert(s.ok());
    std::string value;

    s = db->Get(rocks::ReadOptions(), "key1", &value);

    assert(s.ok());
    assert(value == "value");

    delete db;
    return 0;
}
