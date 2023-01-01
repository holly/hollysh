_APP_NAME="holly.sh"
_APP_VERSION="1.0"

_RANDSTR_LOWER_WORDS="abcdefghijkmnoprstuvwxyz"
_RANDSTR_UPPER_WORDS="ABCDEFGHJKMNPQRSTUVWXYZ"
_RANDSTR_NUMBERS="23456789"
_RANDSTR_SYMBOLS='@*[]<>._-+()&%$#!{}:;~=/'

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

_DEFAULT_RANDSTR_LENGTH=12
_DEFAULT_COMMENT="#"
_DEFAULT_HTTPS_PORT=443

# utility functions
abs2rel() {
    local file=$1
    echo $(cd $(dirname $file) && pwd)/$(basename $file)
}


stdin() {
	cat 
}

get_param() {
    if is_stdin; then
       stdin
    elif [ $# -ne 0 ]; then
        echo $1
    fi
}

slice() {

    local str=$1
    local offset=$2
    local length=$3
    echo ${str:$offset:$length}
}

len() {
    local str=$(get_param "$@")
    echo ${#str}
}

error() {

    local str=$1
    fg_red $str
    exit 1
}
error2() {

    local str=$1
    bg_red $str
    exit 1
}

vartype() {

    local var=$(get_param "$@")
	if [[ -z "$var" ]]; then
		echo "null"
	elif [[ "$var" =~ ^\-?[0-9]+$ ]]; then
		echo "number"
	elif [[ "$var" =~ ^\-?[0-9]+\.[0-9]+$ ]]; then
		echo "float"
	else
		echo "string"
	fi
}

# check functions
is_stdin() {

    if [[ -t 0 ]]; then
        return 1
    else
        return 0
    fi
}

is_empty_dir() {

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

is_executable_sudo() {

    timeout --signal=2 1 sudo -l >/dev/null 2>&1
}

is_sudoed() {

    if [[ -n "$SUDO_USER" ]]; then
        return 0
    else
        return 1
    fi
}

is_leap_year() {

    local year=$1
    year=${year:-$(date "+%Y")}

    if  [[ $(($year % 400)) -eq 0 ]]  || ( [[ $(($year % 4)) -eq 0 ]] && [[ $(($year % 100)) -ne 0 ]] )  ; then
        return 0
    else
        return 1
    fi
}

# convert/format functions
fmt_comma() {

    local number=$(get_param "$@")
    perl -le '$_ = shift @ARGV; 1 while s/(.*\d)(\d\d\d)/$1,$2/; print' $number
}

fmt_human_readable_size() {

    local number=$(get_param "$@")
    number=${number:-0}

    [[ $number -lt $_FMT_KB ]] && echo "$number B" && return 0
    [[ $number -lt $_FMT_MB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_KB" | bc) KB" && return 0
    [[ $number -lt $_FMT_GB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_MB" | bc) MB" && return 0
    [[ $number -lt $_FMT_TB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_GB" | bc) GB" && return 0
    [[ $number -lt $_FMT_PB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_TB" | bc) TB" && return 0
    [[ $number -lt $_FMT_EB ]] && echo "$(echo "scale=$_FMT_DECPTS; $number/$_FMT_PB" | bc) PB" && return 0
}

lower() {

    local str=$(get_param "$@")
	echo "$str" | tr "[:upper:]" "[:lower:]" 
}

upper() {

    local str=$(get_param "$@")
	echo "$str" | tr "[:lower:]" "[:upper:]"
}

urlencode() {

    local str=$(get_param "$@")
	perl -le '$_ = shift @ARGV; s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg; print' "$str"
}

urldecode() {

    local str=$(get_param "$@")
	perl -le '$_ = shift @ARGV;  s/%([0-9a-f]{2})/sprintf("%s", pack("H2", $1))/eig; print' "$str"
}

trim() {

    local str=$(get_param "$@")
    echo "$str" | rtrim | ltrim
}

rtrim() {

    local str=$(get_param "$@")
    echo "$str" | sed -e "s/\s+$//"
}

ltrim() {

    local str=$(get_param "$@")
    echo "$str" | sed -e "s/^\s+//"
}

del_empty_lines() {

    if is_stdin; then
        stdin | sed "/^$/d"
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            sed "/^$/d" $file
        else
            error "argument is not file."
        fi
    fi
}

del_comment_lines() {

    if is_stdin; then
        stdin | sed -e "s/^${_DEFAULT_COMMENT}.*$//g" 
    else
        if [[ -f $1 ]]; then
            # for file
            local file=$1
            sed -e "s/^${_DEFAULT_COMMENT}.*$//g" $file
        else
            error "argument is not file."
        fi
    fi

}


# date functions
today() {
    datetime
}

yesterday() {
    datetime -d "1 day ago"
}

tomorrow() {
    datetime -d "1 day"
}

firstday_on_current_month() {
    date "+%Y-%m-01"
}

lastday_on_current_month() {
    date "+%Y-%m-%d" -d "$(date +%Y-%m-01) 1 month 1 days ago"
}

firstday_on_previous_month() {
    date "+%Y-%m-01" -d "1 month ago"
}

lastday_on_previous_month() {
    date "+%Y-%m-%d" -d "$(date +%Y-%m-01) 1 days ago"
}

firstday_on_next_month() {
    date "+%Y-%m-01" -d "1 month"
}

lastday_on_next_month() {
    date "+%Y-%m-%d" -d "$(date +%Y-%m-01) 2 month 1 days ago"
}



# string functions
http_auth_string() {

    local user=$1
    local password=$2
    echo -n "${user}:${password}" | openssl enc -e -base64
}

http_auth_header() {

    local user=$1
    local password=$2
    echo Authorization: Basic $(make_basic_auth_string $user $password)
}

http_ua_string() {

    echo "$_APP_NAME/$_APP_VERSION ($(uname -srp))"
}

http_ua_header() {

    echo "User-Agent: $(http_ua_string)"
}

rand_string() {

    local length=$1
    length=${length:-$_DEFAULT_RANDSTR_LENGTH}
    rand_string_from_list "${_RANDSTR_LOWER_WORDS}${_RANDSTR_UPPER_WORDS}${_RANDSTR_NUMBERS}" $length
}

rand_string_with_syms() {

    local length=$1
    length=${length:-$_DEFAULT_RANDSTR_LENGTH}
    rand_string_from_list "${_RANDSTR_LOWER_WORDS}${_RANDSTR_UPPER_WORDS}${_RANDSTR_NUMBERS}${_RANDSTR_SYMBOLS}" $length
}

rand_string_from_list() {

    local list=$1
    local length=$2
    local str=""
    for i in $(seq 0 $((length - 1))); do
        local offset=$(($RANDOM % $(len $list)))
        str="${str}$(slice $list $offset 1)"
    done
    echo $str
}

## openssl functions
expires_cert() {

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

expires_https_cert() {

    local https_host=$(get_param "$@")
	openssl s_client -connect ${https_host}:${_DEFAULT_HTTPS_PORT} -servername ${https_host} -showcerts -tls1_2 </dev/null 2>/dev/null | expires_cert
}

## color function
bg_color() {

    local color=$1
    shift
    bg_${color} $*
}

bg_blue () {

    echo -e "${_BG_BLUE}$*${_COLOR_RESET}"
}

bg_green () {

    echo -e "${_BG_GREEN}$*${_COLOR_RESET}"
}

bg_red () {

    echo -e "${_BG_RED}$*${_COLOR_RESET}"
}
bg_yellow () {

    echo -e "${_BG_YELLOW}$*${_COLOR_RESET}"
}

fg_color() {

    local color=$1
    shift
    fg_${color} $*
}

fg_blue () {

    echo -e "${_FG_BLUE}$*${_COLOR_RESET}"
}

fg_green () {

    echo -e "${_FG_GREEN}$*${_COLOR_RESET}"
}

fg_red () {

    echo -e "${_FG_RED}$*${_COLOR_RESET}"
}
fg_yellow () {

    echo -e "${_FG_YELLOW}$*${_COLOR_RESET}"
}

################################################

if which yum >/dev/null && is_executable_sudo; then
    yum () {
        bg_yellow "override yum by $_APP_NAME. auto sudo execution..."
        sudo yum $@
    }
fi
if which apt >/dev/null && is_executable_sudo; then
    apt () {
        bg_yellow "override apt by $_APP_NAME. auto sudo execution..."
        sudo apt $@
    }
fi

if which aws >/dev/null ; then
    alias s3="aws s3"
fi

if which tmux >/dev/null ; then
    alias tmux='tmux -u'
    alias ta='tmux attach'
fi

alias ..='cd ..'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias od='od -tcx1'
alias grep='grep --color=auto -I'
alias strace="strace -s 1024 -tt -f -T"
alias tz="tar --exclude-backups --exclude=\"*.swp\" --exclude=\"*.tmp\" --exclude=\"*.org\" --exclude=\"*.pid\" --exclude=\"lock\" --exclude=\"*~\" --ignore-failed-read --one-file-system -pcvzf"
alias tx="tar --ignore-failed-read -pxvzf"
alias g="git"
alias epoch="date +%s"
alias datetime="date --iso-8601=seconds"
alias curl="curl -H \"$(http_ua_header)\""
alias get="curl -XGET "
alias post="curl -XPOST "
alias put="curl -XPUT "

