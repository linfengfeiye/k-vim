#!/bin/bash
set -e
#set dirs

VIM_INSTALL_DIR=/home/chao_su/vim74
CLANG_INSTALL_DIR=/home/chao_su/clang34
PYTHON_INSTALL_DIR=/home/chao_su/clang34/python27
if [[ -z $VIM_INSTALL_DIR ]] || [[ -z $CLANG_INSTALL_DIR ]] || [[ -z $PYTHON_INSTALL_DIR ]]
then
    echo "missing global dir"
    exit 1
fi    

rm -rf ./build_temp
mkdir build_temp
cd build_temp

#download vim 7.4 and install vim 7.4
vimver=`vim --version|grep 'IMproved'|awk '{print $5}' |awk -F"." '{printf $1}'`
vimnum=`vim --version|grep 'IMproved'|awk '{print $5}' |awk -F"." '{printf $2}'`
if ([[ $vimver -eq 7 ]] && [[ $vimnum -lt 4 ]]) || [[ $vimver -lt 7 ]]    
then    
    if [[ ! -f vim-7.4.tar.bz2 ]]
    then
        wget http://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
        #wget http://192.87.102.43/pub/vim/unix/vim-7.4.tar.bz2
    fi
    rm -rf vim74
    tar -xjvf vim-7.4.tar.bz2
    cd vim74
    ./configure --prefix=${VIM_INSTALL_DIR} --enable-multibyte --with-features=big --disable-selinux --enable-pythoninterp=yes
    sed -i 's%#STRIP = /bin/true%STRIP = /bin/true%' src/Makefile
    make
    if [[ -d ${VIM_INSTALL_DIR} ]]
    then
        rm -rf ${VIM_INSTALL_DIR}
    fi
    make install
    echo "export PATH=${VIM_INSTALL_DIR}/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
fi    

#download python2.7.6 and install
pyver=`python --version 2>&1 |awk -F"." '{print $2}'`
if [[ $pyver -lt 5 ]]
then    
    if [ ! -f Python-2.7.6.tgz ]
    then    
        wget https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tgz
    fi    
    rm -rf Python-2.7.6
    tar -xzvf Python-2.7.6.tgz
    cd Python-2.7.6
    ./configure --prefix=${PYTHON_INSTALL_DIR}
    make
    make install
    echo "export PATH=${PYTHON_INSTALL_DIR}/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
fi    

#download clang and install clang
if [ ! -f cfe-3.4.1.src.tar.gz ]
then
    wget http://llvm.org/releases/3.4.1/cfe-3.4.1.src.tar.gz
fi
if [ ! -f llvm-3.4.1.src.tar.gz ]
then
    wget http://llvm.org/releases/3.4.1/llvm-3.4.1.src.tar.gz
fi
if [ ! -f clang-tools-extra-3.4.src.tar.gz ]
then
    wget http://llvm.org/releases/3.4/clang-tools-extra-3.4.src.tar.gz
fi
if [ ! -f compiler-rt-3.4.src.tar.gz ]
then
    wget http://llvm.org/releases/3.4/compiler-rt-3.4.src.tar.gz
fi
if [[ -d llvm-3.4.1.src ]]
then 
    rm -rf llvm-3.4.1.src
fi    
tar -xzvf cfe-3.4.1.src.tar.gz
tar -xzvf llvm-3.4.1.src.tar.gz
tar -xzvf clang-tools-extra-3.4.src.tar.gz
tar -xzvf compiler-rt-3.4.src.tar.gz
mv cfe-3.4.1.src clang
mv clang/ llvm-3.4.1.src/tools/
mv clang-tools-extra-3.4 extra
mv extra/ llvm-3.4.1.src/tools/clang/
mv compiler-rt-3.4 compiler-rt
mv compiler-rt llvm-3.4.1.src/projects/
rm -rf clang-build
mkdir clang-build
cd clang-build
../llvm-3.4.1.src/configure --prefix=${CLANG_INSTALL_DIR} --enable-optimized --enable-targets=host-only
cpucore=`cat /proc/cpuinfo |grep 'cpu cores'|tail -n 1|awk -F":" '{print $2}'|tr -d ' '`
if [[ "$cpucore" != "" ]]
then    
    make -j${cpucore}
else
    make 
fi    
if [[ -d ${CLANG_INSTALL_DIR} ]]
then
    rm -rf ${CLANG_INSTALL_DIR}
fi
make install
echo "export PATH=${CLANG_INSTALL_DIR}/bin:$PATH" >> ~/.bashrc

