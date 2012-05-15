
#
# http://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/iniscrptact.html
# http://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/iniscrptfunc.html
#
. /lib/lsb/init-functions

status()
{
    if [ ! -f $PIDFILE ]
    then
	    log_failure_msg "$PIDFILE does not exist, redis-server is not running"
	    exit 3
    elif [ ! -x /proc/$(pidofproc -p $PIDFILE) ]
    then
	    log_failure_msg "$PIDFILE exists, process is not running though"
	    exit 1
    else
	    log_success_msg "redis-server is running with PID $(pidofproc -p $PIDFILE)"
	    exit 0
    fi
}

start()
{
    if [ -f $PIDFILE ]
    then
        # TODO: verify that process is running.
        log_success_msg "$PIDFILE exists, process is already running or crashed"
    else
        log_success_msg "Starting Redis server..."
        $EXEC $CONF
    fi
}

stop()
{
    if [ ! -f $PIDFILE ]
    then
        log_success_msg "$PIDFILE does not exist, process is not running"
    else
        PID=$(cat $PIDFILE)
        log_success_msg "Stopping ..."
        $CLIEXEC -p $REDISPORT shutdown
        while [ -x /proc/${PID} ]
        do
            log_success_msg "Waiting for Redis to shutdown ..."
            sleep 1
        done
        log_success_msg "Redis stopped"
    fi
}

restart()
{
    stop
    log_success_msg "Sleeping for 3 seconds..."
    sleep 3
    start
}

try-restart()
{
    # FIXME: properly implement try-restart - don't restart if it is
    #        not running.
    restart
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|force-reload)
        restart
        ;;
    try-restart)
        try-restart
        ;;
    reload)
        # FIXME: print usage!
        exit 3
    status)
        status
        ;;
    *)
        log_failure_msg "Please use start or stop as first argument"
        exit 2
        ;;
esac
