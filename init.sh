source ${HOLLYSH}/rc/main

for cmd in aws terraform docker ; do
    if check_dependency $cmd && [[ -f "${HOLLYSH}/rc/${cmd}rc" ]]; then
        source "${HOLLYSH}/rc/${cmd}rc"
    fi
done

if [[ -z "${HOLLYSH_OVERRIDE_ENV}" ]]  && [[ -f "${HOLLYSH_OVERRIDE_ENV}" ]]; then
    source $HOLLYSH_OVERRIDE_ENV
fi
if [[ -z "${HOLLYSH_OVERRIDE_RC}" ]]  && [[ -f "${HOLLYSH_OVERRIDE_RC}" ]]; then
    source $HOLLYSH_OVERRIDE_RC
fi
