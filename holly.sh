source ${HOLLYSH}/src/main.sh

if check_dependency aws; then
    source ${HOLLYSH}/src/aws.sh
fi
