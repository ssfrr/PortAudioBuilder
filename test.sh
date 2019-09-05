
target=x68_linux_bar
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
