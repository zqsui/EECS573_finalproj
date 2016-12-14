# EECS573 Final Project - Extract useful features for detecting transient faults

##GemFI Installation Guide
[README](https://github.com/zqsui/EECS573_finalproj/blob/master/gemfi-dsn2015/README.md)


##Test Program Compilation Guide
[MiBench](http://vhosts.eecs.umich.edu/mibench/)

In MiBench, for each sub-category, run script make_and_add_to_test_bench.sh
```
./make_and_add_to_test_bench.sh
```
This will make ALPHA binaries for each test application and append them to the ALPHA linux image

## Generate test program inputs
```
```


## Create checkpoint for a target test application
Before running the following command, make sure your test bench has the command: /sbin/m5 checkpoint 1 5000000 
```
dmtcp_launch build/ALPHA/gem5.opt -re -d ./checkpoints/qsort_small --debug-flags=FaultInjection configs/example/fs.py --cpu-type=detailed --caches --l2cache -b your_test_bench
```


## Run the test bench by restoring from a checkpoint
```
dmtcp_launch build/ALPHA/gem5.opt -re -d ./fi_output/qsort_small_f1 --debug-flags=FaultInjection configs/example/fs.py --cpu-type=detailed --caches --l2cache -b qsort_small1 --checkpoint-restore 1 --checkpoint-dir ./checkpoints/qsort_small 
```
## Run our machine learning analysis module
See README.md file in machine_learning folder
