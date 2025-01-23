# Helper Log Functions
# Named as hlog (instead of hlog_info) for ergonomic purposes
#   Easier to type and most calls for hlog will be for an INFO message
function hlog() { 
    hlog_print "INFO" "$1"
}
function hlog_error() { 
    hlog_print "ERROR" "$1"
}
function hlog_print() {
    __timestamp=$(date "+%Y-%m-%d %H:%M:%S.%3N")
    __log_level="$1"
    __message="$2"
    echo "${__timestamp} - ${__log_level} : ${__message}"    
}

