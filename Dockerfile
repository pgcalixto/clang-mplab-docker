FROM pgcalixto/mplab-xc32-plib:0.1-pic32mx795f512l
LABEL version="0.1"
MAINTAINER Pedro Calixto - pgcalixto

RUN apt-get update && apt-get install -qq \
    wget \
 && echo 'deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main' >> /etc/apt/sources.list.d/llvm.list \
 && wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 \
 && apt-get update && apt-get install -qq \
    clang-5.0 \
    cmake \
    lldb-5.0 \
    lld-5.0 \
    subversion \
 \
 && mkdir /libc++ \
 && cd /libc++ \
 && svn co http://llvm.org/svn/llvm-project/llvm/tags/RELEASE_500/final llvm \
 && svn co http://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_500/final libcxx \
 && svn co http://llvm.org/svn/llvm-project/libcxxabi/tags/RELEASE_500/final libcxxabi \
 \
 && mkdir /libc++/libcxxabi/build \
 && cd /libc++/libcxxabi/build \
 && CC=clang-5.0 CXX=clang++-5.0 cmake \
    -DLLVM_PATH=/libc++/llvm \
    -DLIBCXXABI_LIBCXX_PATH=/libc++/libcxx \
    /libc++/libcxxabi \
 && make \
 && make install \
 \
 && mkdir /libc++/libcxx/build \
 && cd /libc++/libcxx/build \
 && CC=clang-5.0 CXX=clang++-5.0 cmake \
    -DLLVM_PATH=/libc++/llvm \
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_CXX_ABI_INCLUDE_PATHS=/libc++/libcxxabi/include \
    /libc++/libcxx \
 && make \
 && make install \
 \
 && rm -rf /libc++ \
 && echo '/usr/local/lib' >> /etc/ld.so.conf.d/libc++.conf \
 && ldconfig \
 && apt-get purge --autoremove -qq \
    subversion \
    wget
