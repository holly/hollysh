_APP_NAME="holly.sh"
_APP_VERSION="0.1"

_APP_CACHE_DIR="$HOME/.cache/hollysh"

_RANDSTR_LOWER_WORDS="abcdefghijkmnoprstuvwxyz"
_RANDSTR_UPPER_WORDS="ABCDEFGHJKLMNPQRSTUVWXYZ"
_RANDSTR_NUMBERS="23456789"
#_RANDSTR_SYMBOLS='@*[]<>._-+()&%$#!{}:;~=/'
_RANDSTR_SYMBOLS='@[]<>._-+()&%$#!{}:;~=/'

_FG_RED="\e[31m"
_FG_GREEN="\e[32m"
_FG_YELLOW="\e[33m"
_FG_BLUE="\e[34m"
_BG_RED="\e[41m"
_BG_GREEN="\e[42m"
_BG_YELLOW="\e[43m"
_BG_BLUE="\e[44m"
_COLOR_RESET="\e[0m"

_FMT_KB=1024
_FMT_MB=$(($_FMT_KB * 1024))
_FMT_GB=$(($_FMT_MB * 1024))
_FMT_TB=$(($_FMT_GB * 1024))
_FMT_PB=$(($_FMT_TB * 1024))
_FMT_EB=$(($_FMT_PB * 1024))
_FMT_DECPTS=2

_SYUKUJITSU_CSV="https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv"

# 0:no inplace  1:inplace  2:backup and inplace
_DEFAULT_FILE_INPLACE_MODE=0
_DEFAULT_FILE_TAB2SPACE_LENGTH=4

_DEFAULT_RANDSTR_LENGTH=12
_DEFAULT_COMMENT="#"
_DEFAULT_HTTPS_PORT=443

if [[ -d "$_APP_CACHE_DIR" ]]; then
	mkdir -p $_APP_CACHE_DIR

fi
# check functions
function check_dependency() {

    local cmd=$(getdata "$@")
    which $cmd >/dev/null 2>&1
}

function has_bom() {

    if is_stdin; then
        stdin | perl -CSDL -nle 'BEGIN{ $exit = 1 }{ $exit = 0 if /^\x{feff}/; exit $exit }'
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            perl -CSDL -nle 'BEGIN{ $exit = 1} { $exit = 0 if /^\x{feff}/; exit $exit }' $file
        else
            error "argument is not file."
        fi
    fi
}

function is_stdin() {

    if [[ -t 0 ]]; then
        return 1
    else
        return 0
    fi
}

function is_empty_dir() {

    local dir=$1
    if [[ ! -d $dir ]]; then
        return 1
    fi
    local res=$(ls $dir)
    if [[ -z "$res" ]]; then
        return 0
    fi
    return 1
}

function is_sudo_executable() {

    timeout --signal=2 1 sudo -l >/dev/null 2>&1
}

function is_sudo_root() {

    if [[ -n "$SUDO_USER" ]] && [[ -n "$SUDO_UID" ]] && [[ -n "$SUDO_GID" ]] && [[ -n "$SUDO_COMMAND" ]] && [[ $USER = "root" ]]; then
        return 0
    else
        return 1
    fi
}

function is_leap_year() {

    local year=$1
    year=${year:-$(date "+%Y")}

    if  [[ $(($year % 400)) -eq 0 ]]  || ( [[ $(($year % 4)) -eq 0 ]] && [[ $(($year % 100)) -ne 0 ]] )  ; then
        return 0
    else
        return 1
    fi
}



# utility functions
function abs2rel() {
    local file=$1
    echo $(cd $(dirname $file) && pwd)/$(basename $file)
}


function stdin() {
    cat 
}

function getdata() {
    if is_stdin; then
       stdin
    elif [ $# -ne 0 ]; then
        echo $1
    fi
}

function slice() {

    local str=$1
    local offset=$2
    local length=$3
    echo ${str:$offset:$length}
}

function len() {
    local str=$(getdata "$@")
    echo ${#str}
}

function error() {

    local str=$1
    fg_red $str
    return 1
}

function error2() {

    local str=$1
    bg_red $str
    return 1
}

function vartype() {

    local var=$(getdata "$@")
    if [[ -z "$var" ]]; then
        echo "null"
    elif [[ "$var" =~ ^\-?[0-9]+$ ]]; then
        echo "int"
    elif [[ "$var" =~ ^\-?[0-9]+\.[0-9]+$ ]]; then
        echo "float"
    else
        echo "string"
    fi
}

# convert/format functions
function comma() {

    local number=$(getdata "$@")
    perl -lE '$_ = $ARGV[0]; 1 while s/(.*\d)(\d\d\d)/$1,$2/; say' $number
}

function human_readable_size() {

    local number=$(getdata "$@")
    number=${number:-0}

    [[ $number -lt $_FMT_KB ]] && echo "$number B" && return 0
    [[ $number -lt $_FMT_MB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_KB" | bc) KB" && return 0
    [[ $number -lt $_FMT_GB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_MB" | bc) MB" && return 0
    [[ $number -lt $_FMT_TB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_GB" | bc) GB" && return 0
    [[ $number -lt $_FMT_PB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_TB" | bc) TB" && return 0
    [[ $number -lt $_FMT_EB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_PB" | bc) PB" && return 0
}

function lower() {

    local str=$(getdata "$@")
    echo "$str" | tr "[:upper:]" "[:lower:]" 
}

function upper() {

    local str=$(getdata "$@")
    echo "$str" | tr "[:lower:]" "[:upper:]"
}

function trim() {

    local str=$(getdata "$@")
    echo "$str" | rtrim | ltrim
}

function rtrim() {

    local str=$(getdata "$@")
    echo "$str" | sed -e "s/\s+$//"
}

function ltrim() {

    local str=$(getdata "$@")
    echo "$str" | sed -e "s/^\s+//"
}

function arrayjoin() {

    local sep=$1
    shift;
    local arr=("$@")
    (local IFS=$sep; echo "${arr[*]}")
}

# file functions
function guess() {
    if is_stdin; then
        stdin | perl -MEncode::Guess=euc-jp,shiftjis,7bit-jis -0777 -nlE '$ref = guess_encoding($_); $guess = ref($ref) ? $ref->name : $ref; say $guess'
    else
        if [[ -f $1 ]]; then
            local file=$1
            perl -MEncode::Guess=euc-jp,shiftjis,7bit-jis -0777 -nlE '$ref = guess_encoding($_); $guess = ref($ref) ? $ref->name : $ref; say $guess' $file
        else
            error "argument is not file."
        fi
    fi

}

function del_empty_lines() {

    if is_stdin; then
        stdin | sed "/^$/d"
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            local inplace_opt=""
            if [[ $_DEFAULT_FILE_INPLACE_MODE -eq 1  ]]; then
                inplace_opt="-i"
            elif [[ $_DEFAUKT_FILE_INPLACE_MODE -eq 2 ]]; then
                inplace_opt="-i.$(date +%Y$m%d)"
            fi
            sed $inplace_opt "/^$/d" $file
        else
            error "argument is not file."
        fi
    fi
}

function del_comment_lines() {

    if is_stdin; then
        stdin | sed -e "s/^${_DEFAULT_COMMENT}.*$//g"
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            local inplace_opt=""
            if [[ $_DEFAULT_FILE_INPLACE_MODE -eq 1  ]]; then
                inplace_opt="-i"
            elif [[ $_DEFAULT_FILE_INPLACE_MODE -eq 2 ]]; then
                inplace_opt="-i.$(date +%Y$m%d)"
            fi
            sed $inplace_opt -e "s/^${_DEFAULT_COMMENT}.*$//g" $file
        else
            error "argument is not file."
        fi
    fi

}

function del_bom() {

    if is_stdin; then
        # -0777 is slurp mode
        # -CSDL is https://pointoht.ti-da.net/e8367529.html
        stdin | perl -0777 -CSDL -nlpe "s/^\x{feff}//"
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            local inplace_opt=""
            if [[ $_DEFAULT_FILE_INPLACE_MODE -eq 1  ]]; then
                inplace_opt="-i"
            elif [[ $_DEFAULT_FILE_INPLACE_MODE -eq 2 ]]; then
                inplace_opt="-i.$(date +%Y%m%d)"
            fi
            perl $inplace_opt -CSDL -nlpe 's/^\x{feff}//' $file
        else
            error "argument is not file."
        fi
    fi
}

function align_linefeed() {

    if is_stdin; then
        stdin | perl $inplace_opt -nlpe 's/\x0d\x0a/\n/g; s/\x0d/\n/g'
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            local inplace_opt=""
            if [[ $_FILE_INPLACE_MODE -eq 1  ]]; then
                inplace_opt="-i"
            elif [[ $_FILE_INPLACE_MODE -eq 2 ]]; then
                inplace_opt="-i.$(date +%Y%m%d)"
            fi
            perl $inplace_opt -nlpe 's/\x0d\x0a/\n/g; s/\x0d/\n/g' $file
        else
            error "argument is not file."
        fi
    fi
}

function to_utf8() {

    if is_stdin; then
        stdin | perl -MEncode -MEncode::Guess=euc-jp,shiftjis,7bit-jis -0777 -nlpe '$ref = guess_encoding($_); Encode::from_to($_, $ref->name, "utf8")'
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            local inplace_opt=""
            if [[ $_DEFAULT_FILE_INPLACE_MODE -eq 1  ]]; then
                inplace_opt="-i"
            elif [[ $_DEFAULT_FILE_INPLACE_MODE -eq 2 ]]; then
                inplace_opt="-i.$(date +%Y%m%d)"
            fi
            perl $inplace_opt -MEncode  -MEncode::Guess=euc-jp,shiftjis,7bit-jis -0777 -nlpe '$ref = guess_encoding($_); Encode::from_to($_, $ref->name, "utf8")' $file
        else
            error "argument is not file."
        fi
    fi
}

function to_sjis() {

    if is_stdin; then
        stdin | perl -MEncode -MEncode::Guess=euc-jp,shiftjis,7bit-jis -0777 -nlpe '$ref = guess_encoding($_); Encode::from_to($_, $ref->name, "shiftjis")'
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            local inplace_opt=""
            if [[ $_DEFAULT_FILE_INPLACE_MODE -eq 1  ]]; then
                inplace_opt="-i"
            elif [[ $_DEFAULT_FILE_INPLACE_MODE -eq 2 ]]; then
                inplace_opt="-i.$(date +%Y%m%d)"
            fi
            perl $inplace_opt -MEncode  -MEncode::Guess=euc-jp,shiftjis,7bit-jis -0777 -nlpe '$ref = guess_encoding($_); Encode::from_to($_, $ref->name, "shiftjis")' $file
        else
            error "argument is not file."
        fi
    fi
}




# date functions
function today() {
    datetime
}

function yesterday() {
    datetime -d "1 day ago"
}

function tomorrow() {
    datetime -d "1 day"
}

function firstday_on_current_month() {
    date "+%Y-%m-01"
}

function lastday_on_current_month() {
    date "+%Y-%m-%d" -d "$(date +%Y-%m-01) 1 month 1 days ago"
}

function firstday_on_previous_month() {
    date "+%Y-%m-01" -d "1 month ago"
}

function lastday_on_previous_month() {
    date "+%Y-%m-%d" -d "$(date +%Y-%m-01) 1 days ago"
}

function firstday_on_next_month() {
    date "+%Y-%m-01" -d "1 month"
}

function lastday_on_next_month() {
    date "+%Y-%m-%d" -d "$(date +%Y-%m-01) 2 month 1 days ago"
}

# string functions
function rand_string() {

    local length=$1
    length=${length:-$_DEFAULT_RANDSTR_LENGTH}
    _rand_string_from_list "${_RANDSTR_LOWER_WORDS}${_RANDSTR_UPPER_WORDS}${_RANDSTR_NUMBERS}" $length
}

function rand_string_with_syms() {

    local length=$1
    length=${length:-$_DEFAULT_RANDSTR_LENGTH}
    _rand_string_from_list "${_RANDSTR_LOWER_WORDS}${_RANDSTR_UPPER_WORDS}${_RANDSTR_NUMBERS}${_RANDSTR_SYMBOLS}" $length
}

function _rand_string_from_list() {

    local list=$1
    local length=$2
    local str=""
    while [[ $length -ne $(len $str) ]]; do
        local offset=$(($RANDOM % $(len $list)))
        local char=$(slice $list $offset 1)
        local pattern="${char}+"
        if [[ "$str" =~ $pattern ]]; then
            continue
        fi
        str="${str}${char}"
    done
    echo $str
}


# http functions
function urlencode() {

    local str=$(getdata "$@")
    perl -lE '$_ = $ARGV[0]; s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg; say' "$str"
}

function urldecode() {

    local str=$(getdata "$@")
    perl -lE '$_ = $ARGV[0];  s/%([0-9a-f]{2})/sprintf("%s", pack("H2", $1))/eig; say' "$str"
}

function querystring() {

    local k=""
    local pairs=()
    local i=0
    for a in "$@"; do
        if [[ $i -eq 0 ]]; then
            k=$a
            i=$(($i + 1))
        elif [[ $i -eq 1 ]]; then
            local v=$(urlencode "$a")
            pairs+=("${k}=$v")
            k=""
            i=0
        fi
    done
    arrayjoin "&" "${pairs[@]}"
}

function http_auth_string() {

    local user=$1
    local password=$2
    echo -n "${user}:${password}" | openssl enc -e -base64
}

function http_auth_header() {

    local user=$1
    local password=$2
    echo Authorization: Basic $(make_basic_auth_string $user $password)
}

function http_ua_string() {

    echo "$_APP_NAME/$_APP_VERSION ($(uname -srp))"
}

function http_ua_header() {

    echo "User-Agent: $(http_ua_string)"
}

function http_perf() {
    local url=$1
    json=$(_curlw $url | jq "." )
    (
    for k in remote_ip http_code size_download size_upload speed_download speed_upload time_namelookup time_connect time_appconnect time_redirect time_pretransfer time_starttransfer time_total; do
        echo "$k" $(echo $json | jq -r ".$k")
    done
    ) | column --table --table-columns WRITE-OUT,VALUE
}

## openssl functions
function expires_cert() {

    local enddate=""
    if is_stdin; then
        enddate=$(stdin | openssl x509 -noout -enddate | cut -d"=" -f2)
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            enddate=$(openssl x509 -in $file -noout -enddate | cut -d"=" -f2)
        else
            error "argument is not file."
        fi
    fi
    local enddate_unixtime=$(epoch -d "$enddate")
    local current_unixtime=$(epoch)
    echo $(( ($enddate_unixtime - $current_unixtime) / 60 / 60 / 24 ))
}

function expires_https_cert() {

    local https_host=$(getdata "$@")
    openssl s_client -connect ${https_host}:${_DEFAULT_HTTPS_PORT} -servername ${https_host} -showcerts -tls1_2 </dev/null 2>/dev/null | expires_cert
}

## color function
function bg_color() {

    local color=$1
    shift
    bg_${color} $*
}

function bg_blue () {

    echo -e "${_BG_BLUE}$*${_COLOR_RESET}"
}

function bg_green () {

    echo -e "${_BG_GREEN}$*${_COLOR_RESET}"
}

function bg_red () {

    echo -e "${_BG_RED}$*${_COLOR_RESET}"
}
function bg_yellow () {

    echo -e "${_BG_YELLOW}$*${_COLOR_RESET}"
}

function fg_color() {

    local color=$1
    shift
    fg_${color} $*
}

function fg_blue () {

    echo -e "${_FG_BLUE}$*${_COLOR_RESET}"
}

function fg_green () {

    echo -e "${_FG_GREEN}$*${_COLOR_RESET}"
}

function fg_red () {

    echo -e "${_FG_RED}$*${_COLOR_RESET}"
}
function fg_yellow () {

    echo -e "${_FG_YELLOW}$*${_COLOR_RESET}"
}

################################################

if check_dependency yum && is_sudo_executable; then
    function yum() {
        bg_yellow "override yum by $_APP_NAME. auto sudo execution..."
        sudo yum $@
    }
fi

if check_dependency apt && is_sudo_executable; then
    function apt() {
        bg_yellow "override apt by $_APP_NAME. auto sudo execution..."
        sudo apt $@
    }
fi

alias ..='cd ..'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias od='od -tcx1'
alias grep='grep --color=auto -I'
alias strace="strace -s 1024 -tt -f -T"
alias tcf="tar --exclude-backups --exclude=\"*.swp\" --exclude=\"*.tmp\" --exclude=\"*.org\" --exclude=\"*.pid\" --exclude=\"lock\" --exclude=\"*~\" --ignore-failed-read --one-file-system -pcvf"
alias txf="tar --ignore-failed-read -pxvf"
alias g="git"
alias epoch="date +%s"
alias datetime="date --iso-8601=seconds"
alias curl="curl -H \"$(http_ua_header)\""
alias get="curl -XGET "
alias post="curl -XPOST "
alias put="curl -XPUT "
alias _curlw="curl -sfL -o /dev/null -w '%{json}'"
alias tmux='tmux -u'
alias ta='tmux attach'