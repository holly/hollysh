source ${HOLLYSH}/src/main.sh

#for cmd in aws terraform docker ; do
#    if check_dependency $cmd; then
#        source "${HOLLYSH}/src/${cmd}.sh"
#    fi
#done

if [ -z "${HOLLYSH_OVERRIDE_ENV}" && -f "${HOLLYSH_OVERRIDE_ENV}" ]; then
    source $HOLLYSH_OVERRIDE_ENV
fi
