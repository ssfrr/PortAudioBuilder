# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libportaudio"
version = v"19.6.0"


# Collection of sources required to build libportaudio. Not all of these
# are used for all platforms.
sources = [
    "http://portaudio.com/archives/pa_stable_v190600_20161030.tgz" =>
        "f5a21d7dcd6ee84397446fa1fa1a0675bb2e8a4a6dceb4305a8404698d8d1513",

    "https://github.com/jackaudio/jack2/releases/download/v1.9.12/jack2-1.9.12.tar.gz" =>
        "deefe2f936dc32f59ad3cef7e37276c2035ef8a024ca92118f35c9a292272e33",

    "ftp://ftp.alsa-project.org/pub/lib/alsa-lib-1.1.6.tar.bz2" =>
        "5f2cd274b272cae0d0d111e8a9e363f08783329157e8dd68b3de0c096de6d724",

    "http://www.steinberg.net/sdk_downloads/ASIOSDK2.3.1.zip" =>
        "31074764475059448a9b7a56f103f4723ed60465e0e9d1a9446ca03dcf840f04"
        ]

# Bash recipe for building across all platforms
script = raw"""
set -e
cd $WORKSPACE/srcdir
# set up our platform-specific switches
case "$target" in
    *linux*)
        jack_platform=linux
        build_alsa=true
        build_jack=true
    ;;
    *freebsd*)
        jack_platform=linux
        build_alsa=true
        build_jack=true
    ;;
    *darwin*)
        jack_platform=darwin
        build_alsa=false
        build_jack=true
    ;;
    *mingw32*)
        jack_platform=msys
        build_alsa=false
        build_jack=true
    ;;
esac
build_jack=false
if [[ "$build_alsa" == "true" ]]; then
    cd alsa-lib-1.1.6/
    ./configure --prefix=$prefix --host=$target
    make
    make install
    cd ..
fi
if [[ "$build_jack" == "true" ]]; then
    cd jack2-1.9.12/
    ./waf configure --prefix=$prefix --platform=$jack_platform
    ./waf build
    ./waf install
    cd ..
fi

# move the ASIO SDK to where CMake can find it
mv "asiosdk2.3.1 svnrev312937/ASIOSDK2.3.1" asiosdk2.3.1
rmdir "asiosdk2.3.1 svnrev312937"

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain -DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON ../portaudio/
make
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc)
    Linux(:x86_64, libc=:glibc)
    Linux(:aarch64, libc=:glibc)
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf)
    Linux(:powerpc64le, libc=:glibc)
    MacOS(:x86_64)
    Windows(:i686)
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libportaudio", :libportaudio)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://s3.us-east-2.amazonaws.com/ringbuffersbuilder/build_pa_ringbuffer.v19.6.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
