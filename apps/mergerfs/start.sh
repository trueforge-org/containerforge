if [[ $# -eq 0 ]]; then
	echo "mergerfs ready: no branches/mountpoint args provided; idling"
	exec sleep 999999
fi

exec mergerfs -f "$@"
