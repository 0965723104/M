#!/system/bin/sh

BB=/res/busybox;

case "$1" in
	CPUFrequencyList)
		for CPUFREQ in `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`; do
		LABEL=$((CPUFREQ / 1000));
			$BB echo "$CPUFREQ:\"${LABEL} MHz\", ";
		done;
	;;
	CPUGovernorList)
		for CPUGOV in `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`; do
			$BB echo "\"$CPUGOV\",";
		done;
	;;
	DebugPVS)
		$BB echo "PVS bin";
	;;
	DebugSPEED)
		$BB echo "Speed bin";
	;;
	DefaultCPUGovernor)
		$BB echo `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
	;;
	DefaultCPUMaxFrequency)
		while read FREQ TIME; do
			if [ $FREQ -le "2260000" ]; then
				MAXCPU=$FREQ;
			fi;
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;

		$BB echo $MAXCPU;
	;;
	DefaultCPUMinFrequency)
		S=0;
		while read FREQ TIME; do
			if [ $FREQ -ge "300000" ] && [ $S -eq "0" ]; then
				S=1;
				MINCPU=$FREQ;
			fi;
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;

		$BB echo $MINCPU;
	;;
	DirCPUMaxFrequency)
		$BB echo "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq";
	;;
	DirCPUMinFrequency)
		$BB echo "/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq";
	;;
	DirIOScheduler)
		$BB echo "/sys/block/mmcblk0/queue/scheduler";
	;;
    DirKRYOIOScheduler)
		$BB echo "/sys/block/sda/queue/scheduler";
	;;
	DirIOSchedulerTree)
		$BB echo "/sys/block/mmcblk0/queue/iosched";
	;;
    DirKRYOIOSchedulerTree)
		$BB echo "/sys/block/sda/queue/iosched";
	;;
	DirTCPCongestion)
		$BB echo "/proc/sys/net/ipv4/tcp_congestion_control";
	;;
	IOSchedulerList)
		for IOSCHED in `$BB cat /sys/block/mmcblk0/queue/scheduler | $BB sed -e 's/\]//;s/\[//'`; do
			$BB echo "\"$IOSCHED\",";
		done;
	;;
	KRYOIOSchedulerList)
		for IOSCHED in `$BB cat /sys/block/sda/queue/scheduler | $BB sed -e 's/\]//;s/\[//'`; do
			$BB echo "\"$IOSCHED\",";
		done;
	;;
	LiveBatteryTemperature)
		BAT_C=`$BB awk '{ print $1 / 10 }' /sys/class/power_supply/battery/temp`;
		BAT_H=`$BB cat /sys/class/power_supply/battery/health`;

		$BB echo "$BAT_C°C@nHealth: $BAT_H";
	;;
	LiveCPUFrequency)
		CPU0=`$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2> /dev/null`;
		CPU1=`$BB cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq 2> /dev/null`;
		CPU2=`$BB cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq 2> /dev/null`;
		CPU3=`$BB cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq 2> /dev/null`;
		
		if [ -z "$CPU0" ]; then CPU0="Offline"; else CPU0="$((CPU0 / 1000)) MHz"; fi;
		if [ -z "$CPU1" ]; then CPU1="Offline"; else CPU1="$((CPU1 / 1000)) MHz"; fi;
		if [ -z "$CPU2" ]; then CPU2="Offline"; else CPU2="$((CPU2 / 1000)) MHz"; fi;
		if [ -z "$CPU3" ]; then CPU3="Offline"; else CPU3="$((CPU3 / 1000)) MHz"; fi;
		
		$BB echo "Core 0: $CPU0@nCore 1: $CPU1@nCore 2: $CPU2@nCore 3: $CPU3";
	;;
	LiveKRYOOnlineOffline)
		CPU0=`$BB cat /sys/devices/system/cpu/cpu0/online 2> /dev/null`;
		CPU1=`$BB cat /sys/devices/system/cpu/cpu1/online 2> /dev/null`;
		CPU2=`$BB cat /sys/devices/system/cpu/cpu2/online 2> /dev/null`;
		CPU3=`$BB cat /sys/devices/system/cpu/cpu3/online 2> /dev/null`;

		if [ $CPU0 == 0 ]; then CPU0="Off"; else CPU0="On"; fi;
		if [ $CPU1 == 0 ]; then CPU1="Off"; else CPU1="On"; fi;
		if [ $CPU2 == 0 ]; then CPU2="Off"; else CPU2="On"; fi;
		if [ $CPU3 == 0 ]; then CPU3="Off"; else CPU3="On"; fi;

		$BB echo "Kyro 1.6 Cpu Status@n";
		$BB echo "0:$CPU0 ~ 1:$CPU1@n";
		$BB echo "@nKyro 2.2 Cpu	Status@n";
		$BB echo "4:$CPU2 ~ 3:$CPU3";
	;;
	LiveMemory)
		while read TYPE MEM KB; do
			if [ "$TYPE" = "MemTotal:" ]; then
				TOTAL="$((MEM / 1024)) MB";
			elif [ "$TYPE" = "MemFree:" ]; then
				CACHED=$((MEM / 1024));
			elif [ "$TYPE" = "Cached:" ]; then
				FREE=$((MEM / 1024));
			fi;
		done < /proc/meminfo;
		
		FREE="$((FREE + CACHED)) MB";
		$BB echo "Total: $TOTAL@nFree: $FREE";
	;;
	LiveTime)
		STATE="";
		CNT=0;
		SUM=`$BB awk '{s+=$2} END {print s}' /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state`;
		
		while read FREQ TIME; do
			if [ "$CNT" -ge $2 ] && [ "$CNT" -le $3 ]; then
				FREQ="$((FREQ / 1000)) MHz:";
				if [ $TIME -ge "100" ]; then
					PERC=`$BB awk "BEGIN { print ( ($TIME / $SUM) * 100) }"`;
					PERC="`$BB printf "%0.1f\n" $PERC`%";
					TIME=$((TIME / 100));
					STATE="$STATE $FREQ `$BB echo - | $BB awk -v "S=$TIME" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'` ($PERC)@n";
				fi;
			fi;
			CNT=$((CNT+1));
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;
		
		STATE=${STATE%??};
		$BB echo "$STATE";
	;;
	LiveUpTime)
		TOTAL=`$BB awk '{ print $1 }' /proc/uptime`;
		AWAKE=$((`$BB awk '{s+=$2} END {print s}' /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state` / 100));
		SLEEP=`$BB awk "BEGIN { print ($TOTAL - $AWAKE) }"`;
		
		PERC_A=`$BB awk "BEGIN { print ( ($AWAKE / $TOTAL) * 100) }"`;
		PERC_A="`$BB printf "%0.1f\n" $PERC_A`%";
		PERC_S=`$BB awk "BEGIN { print ( ($SLEEP / $TOTAL) * 100) }"`;
		PERC_S="`$BB printf "%0.1f\n" $PERC_S`%";
		
		TOTAL=`$BB echo - | $BB awk -v "S=$TOTAL" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
		AWAKE=`$BB echo - | $BB awk -v "S=$AWAKE" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
		SLEEP=`$BB echo - | $BB awk -v "S=$SLEEP" '{printf "%dh:%dm:%ds",S/(60*60),S%(60*60)/60,S%60}'`;
		$BB echo "Total: $TOTAL (100.0%)@nSleep: $SLEEP ($PERC_S)@nAwake: $AWAKE ($PERC_A)";
	;;
	LiveUnUsed)
		UNUSED="";
		while read FREQ TIME; do
			FREQ="$((FREQ / 1000)) MHz";
			if [ $TIME -lt "100" ]; then
				UNUSED="$UNUSED$FREQ, ";
			fi;
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;
		
		UNUSED=${UNUSED%??};
		$BB echo "$UNUSED";
	;;
	MaxCPU)
		MAXCPU=/sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq;
		
		
		if [ -f "$MAXCPU" ]; then
			$BB echo "8"
		else
			$BB echo "4"
		fi;
	;;
	MinFreqIndex)
		ID=0;
		MAXID=8;
		while read FREQ TIME; do
			LABEL=$((FREQ / 1000));
			if [ $FREQ -gt "384000" ] && [ $ID -le $MAXID ]; then
				MFIT="$MFIT $ID:\"${LABEL} MHz\", ";
			fi;
			ID=$((ID + 1));
		done < /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state;

		$BB echo $MFIT;
	;;
	SetCPUGovernor)
		for CPU in /sys/devices/system/cpu/cpu[0-3]; do
			$BB echo 1 > $CPU/online 2> /dev/null;
			$BB echo $2 > $CPU/cpufreq/scaling_governor 2> /dev/null;
		done;
	;;
	SetCPUMaxFrequency)
		for CPU in /sys/devices/system/cpu/cpu[1-3]; do
			$BB echo 1 > $CPU/online 2> /dev/null;
			$BB echo $2 > $CPU/cpufreq/scaling_max_freq 2> /dev/null;
		done;
	;;
	SetCPUMinFrequency)
		for CPU in /sys/devices/system/cpu/cpu[1-3]; do
			$BB echo 1 > $CPU/online 2> /dev/null;
			$BB echo $2 > $CPU/cpufreq/scaling_min_freq 2> /dev/null;
		done;
	;;
	TCPCongestionList)
		for TCPCC in `$BB cat /proc/sys/net/ipv4/tcp_available_congestion_control` ; do
			$BB echo "\"$TCPCC\",";
		done;
	;;
esac;
