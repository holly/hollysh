source ${HOLLYSH}/src/main.sh

for cmd in git aws terraform docker ; do
    if check_dependency $cmd && [[ -f "${HOLLYSH}/src/${cmd}.sh" ]]; then
        source "${HOLLYSH}/src/${cmd}.sh"
    fi
done

if [[ -z "${HOLLYSH_OVERRIDE_ENV}" ]]  && [[ -f "${HOLLYSH_OVERRIDE_ENV}" ]]; then
    source $HOLLYSH_OVERRIDE_ENV
fi
if [[ -z "${HOLLYSH_OVERRIDE_RC}" ]]  && [[ -f "${HOLLYSH_OVERRIDE_RC}" ]]; then
    source $HOLLYSH_OVERRIDE_RC
fi
