touch log_file0.txt
touch log_file1.txt
touch log_file2.txt
touch log_file3.txt
touch log_file4.txt
touch log_file5.txt
touch log_file6.txt
touch log_file7.txt
touch log_file8.txt
cd ../../../
cd verilator
make run TEST=pdp_med3x3_int8
cd ../
cd traces/traceplayer/pdp_med3x3_int8/waves
mkdir $1
cd ../
mv log_file0.txt ./waves/$1
mv log_file1.txt ./waves/$1
mv log_file2.txt ./waves$1
mv log_file3.txt ./waves/$1
mv log_file4.txt ./waves/$1
mv log_file5.txt ./waves$1
mv log_file6.txt ./waves/$1
mv log_file7.txt ./waves/$1
mv log_file8.txt ./waves/$1
