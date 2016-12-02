##GemFI Installation Guide on Ubuntu 14.04

Pre-requisites
---------------

There are several pre-requisite software packages required to build and run gem5. 
Please visit http://www.m5sim.org/Dependencies to obtain the list of dependencies. 
Install all dependencies before proceeding with the build.

```
sudo apt-get install build-essential
sudo apt-get install build-essential
sudo apt-get install flex
sudo apt-get install bison
sudo apt-get install libncurses5-dev
sudo apt-get install python-docutils
sudo apt-get install scons
sudo apt-get install swig
sudo apt-get install m4
sudo apt-get install python-dev
sudo apt-get install zlib1g
sudo apt-get install zlib1g-dev
sudo apt-get install protobuf-compiler
sudo apt-get install libprotobuf-dev
```


Install DMTCP
---------------
Get DMTCP from https://github.com/dmtcp/dmtcp/releases

```
./configure
make
sudo make install
```

Building the Simulator:
-----------------------
```
scons build/ALPHA/gem5.opt  
```
You will encounter failures at some point during compilation like the following:
```
build/ALPHA/arch/alpha/generated/atomic_simple_cpu_exec.cc:12793:47: error: too few arguments to function 'void PseudoInst::init_fi_system(ThreadContext*, uint64_t, uint64_t)'
        PseudoInst::init_fi_system(xc->tcBase());
                                               ^
In file included from build/ALPHA/arch/alpha/generated/atomic_simple_cpu_exec.cc:26:0:
build/ALPHA/sim/pseudo_inst.hh:96:6: note: declared here
 void init_fi_system(ThreadContext *tc,uint64_t start, uint64_t stop);
      ^
scons: *** [build/ALPHA/arch/alpha/generated/atomic_simple_cpu_exec.o] Error 1
scons: building terminated because of errors.
```

This is because the original version of gemfi-dsn2015 was built on Ubuntu 12.04 where gcc has a lower version. So on Ubuntu 14.04 with newer version of gcc, some generated C++ files have some missing functio arguments. The remedy is to copy the generated C++ files to the specific location.  

```
rm build/ALPHA/arch/alpha/generated/*
cp util/generated_cpp_files/* build/ALPHA/arch/alpha/generated/
```

And then continue building
```
scons build/ALPHA/gem5.opt
```



Setup Images for Full System Running
-----------------------
```
mkdir dist
cd dist
wget http://www.m5sim.org/dist/current/m5_system_2.0b3.tar.bz2
```

Uncompress at ./dist, and move the two folders (binaries, disks) out to ./dist 

```
wget http://www.cs.utexas.edu/~parsec_m5/linux-parsec-2-1-m5-with-test-inputs.img.bz2
```

Uncompress at ./dist/disks/

In the file ./configs/common/SysPaths.py, chage line 53 to
```
path = [ '/dist/m5/system', 'your_path_to_gemfi/dist' ]
```

Mount your test bench into the image
-----------------------
```
sudo mount -o,loop,offset=32256 ./dist/disk /linux-parsec-2-1-m5-with-test-inputs.img /mnt
sudo cp your_test_program /mnt 
```

