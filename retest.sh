# arg1 = dbpostfix
# arg2 = load / run
# arg3 = workload

db=$1
test_type=$2
workload=${3:-"e"}

rocksdb_dir=./rocksdb_$db
db_file_dir=/home/gjr/projects/db2_$db

sudo rm -rf rocksdb

# exit if test_type is not load or run
if [ "$test_type" != "load" ] && [ "$test_type" != "run" ]; then
    echo "Invalid test type. Use 'load' or 'run'."
    exit 1
fi

# if db_file_dir exists, delete it if test_type is load
if [ -d "$db_file_dir" ]; then
    if [ "$test_type" == "load" ]; then
        echo "Directory $db_file_dir already exists. Load job deleting it."
        sudo rm -rf $db_file_dir
    else
        echo "Directory $db_file_dir already exists. Run job not deleting it."
    fi
fi

# create db_file_dir if it does not exist
if [ ! -d "$db_file_dir" ]; then
    mkdir -p $db_file_dir
fi

if [ ! -d "$rocksdb_dir" ]; then
    echo "Directory $rocksdb_dir does not exist."
    exit 1
fi

cp -r $rocksdb_dir rocksdb
sudo mvn -e clean package -pl rocksdb -am -DskipTests

sudo ./bin/ycsb $test_type rocksdb -s -P workloads/workload${workload} \
    -p rocksdb.dir=${db_file_dir} \
    -p rocksdb.optionsfile=rocksdb/src/test/resources/dboption.ini

sudo rm -rf rocksdb