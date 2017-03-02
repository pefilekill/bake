#!/bin/bash -e
#@author ice (1546911121@qq.com)  平安好医生 2016.12.23 更新

if [ "$#" -ne 5 ]
then
    echo "使用帮助(Mac专用):"
    echo "请将本脚本扔到OpenSSL根目录,然后执行脚本,如下:"
    echo "./IceCompileAndroid.sh  <NDK_ROOT_DIR> <ANDROID_TARGET_API> <ANDROID_TARGET_ABI> <TOOLCHAIN_VERSION> <OUTPUT_DIR>"
    echo "                "
    echo "例子:"
    echo "NDK根路径:/Users/wangwenzhe/android-sdk-macosx/ndk-bundle"
    echo "ANDROID_TARGET_API:建议14及以上"
    echo "ANDROID_TARGET_ABI: armeabi, armeabi-v7a, arm64-v8a, x86, x86_64, mips, mips64"
    echo "TOOLCHAIN_VERSION:根据自己安装的ndk设置,可自行去NDK路径下的toolchains下查看   比如 4.9"
    echo "OUTPUT_DIR:输出文件夹，将把头文件和so .a等必备文件生成到该文件夹"
    echo 
    echo 
    echo "./IceCompileAndroid.sh /Users/wangwenzhe/android-sdk-macosx/ndk-bundle 18 armeabi-v7a 4.9 /Users/wangwenzhe/Downloads/openssloutput/armeabi-v7a  "
    echo 
    exit 1
fi

NDK_DIR=$1                      #全局变量：ndk的根目录
OPENSSL_TARGET_API=$2           #全局变量：openssl 编译使用的的API
OPENSSL_TARGET_ABI=$3           #全局变量：openssl 的CPU平台
OPENSSL_TOOLCHAIN_VERSION=$4    #全局变量：工具链版本
OPENSSL_OUTPUT_PATH=$5          #全局变量：输出的文件夹

function build_library {
    #首先执行清理
    make clean  #清理上次openssl生成文件
    rm -rf ${OPENSSL_OUTPUT_PATH} # 清理输出文件夹
    mkdir -p ${OPENSSL_OUTPUT_PATH} #创建输出文件夹
    export PATH=$ANDROID_SYSROOT:$ANDROID_DEV:$TOOLCHAIN_PATH:$PATH  #设置环境变量
    make  #&& make install  不执行安装  应在工程中直接使用
    CopyOpenSSlFiles2OutputDir
    echo "编译完成!检查输出文件夹内容是否正常"
}
# 拷贝生成的文件到输出目录
function CopyOpenSSlFiles2OutputDir {
    #拷贝头文件
    mkdir -p ${OPENSSL_OUTPUT_PATH}/include
    cp -r ./include/* ${OPENSSL_OUTPUT_PATH}/include
    #拷贝.a 
    mkdir -p ${OPENSSL_OUTPUT_PATH}/lib
    cp ./libcrypto.a ${OPENSSL_OUTPUT_PATH}/lib/
    cp ./libssl.a ${OPENSSL_OUTPUT_PATH}/lib/
    #拷贝.so
    mkdir -p ${OPENSSL_OUTPUT_PATH}/binary
    cp ./libcrypto.so ${OPENSSL_OUTPUT_PATH}/binary/
    cp ./libssl.so ${OPENSSL_OUTPUT_PATH}/binary/
} 




if [ "$OPENSSL_TARGET_ABI" == "armeabi-v7a" ]
then
    export TOOL=arm-linux-androideabi
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/${TOOL}-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16"
    export ARCH_LINK="-march=armv7-a -Wl,--fix-cortex-a8"
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-arm"
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure android no-asm   #执行 Configure
    build_library

elif [ "$OPENSSL_TARGET_ABI" == "arm64-v8a" ]
then
    export TOOL=aarch64-linux-android
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/${TOOL}-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS=
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-arm64"  # 可能有误
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure android no-asm   #执行 Configure
    build_library

elif [ "$OPENSSL_TARGET_ABI" == "armeabi" ]
then
    export TOOL=arm-linux-androideabi
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/${TOOL}-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS="-mthumb"
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-arm"
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure android-armeabi no-asm   #执行 Configure   可能有误
    build_library

elif [ "$OPENSSL_TARGET_ABI" == "x86" ]
then
    export TOOL=i686-linux-android
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/x86-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS="-march=i686 -msse3 -mstackrealign -mfpmath=sse"
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-x86"
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure android-x86 no-asm   #执行 Configure
    build_library

elif [ "$OPENSSL_TARGET_ABI" == "x86_64" ]
then
    export TOOL=x86_64-linux-android
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/x86_64-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-x86_64"
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure linux-x86_64 no-asm   #执行 Configure
    build_library

elif [ "$OPENSSL_TARGET_ABI" == "mips" ]
then
    export TOOL=mipsel-linux-android
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/${TOOL}-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS=
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-mips"
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure android-mips no-asm   #执行 Configure
    build_library

elif [ "$OPENSSL_TARGET_ABI" == "mips64" ]
then
    export TOOL=mips64el-linux-android
    export TOOLCHAIN_PATH="$NDK_DIR/toolchains/${TOOL}-${OPENSSL_TOOLCHAIN_VERSION}/prebuilt/darwin-x86_64/bin"   # mac专用，其它平台时更改对应的路径
    export NDK_TOOLCHAIN_BASENAME=${TOOLCHAIN_PATH}/${TOOL}
    export CC=$NDK_TOOLCHAIN_BASENAME-gcc
    export CXX=$NDK_TOOLCHAIN_BASENAME-g++
    export LINK=${CXX}
    export LD=$NDK_TOOLCHAIN_BASENAME-ld
    export AR=$NDK_TOOLCHAIN_BASENAME-ar
    export RANLIB=$NDK_TOOLCHAIN_BASENAME-ranlib
    export STRIP=$NDK_TOOLCHAIN_BASENAME-strip
    export ARCH_FLAGS=
    export ARCH_LINK=
    export CPPFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export CXXFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 -frtti -fexceptions "
    export CFLAGS=" ${ARCH_FLAGS} -fpic -ffunction-sections -funwind-tables -fstack-protector -fno-strict-aliasing -finline-limit=64 "
    export LDFLAGS=" ${ARCH_LINK} "

    export ANDROID_SYSROOT="$NDK_DIR/platforms/android-${OPENSSL_TARGET_API}/arch-mips64"
    export CROSS_SYSROOT="$ANDROID_SYSROOT"
    export NDK_SYSROOT="$ANDROID_SYSROOT"
    export ANDROID_DEV="$ANDROID_SYSROOT/usr"

    # Error checking
    if [ -z "$ANDROID_SYSROOT" ] || [ ! -d "$ANDROID_SYSROOT" ]; 
    then
        echo "Error: ANDROID_SYSROOT 无效:${ANDROID_SYSROOT}"
        exit 1
    fi

    ./Configure android-mips64 no-asm   #执行 Configure    可能有误
    build_library

else
    echo "不支持的 ABI: $OPENSSL_TARGET_ABI"
    exit 1
fi