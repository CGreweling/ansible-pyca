#!/bin/bash

TIME=$1
DIR=$2
NAME=$3

[ $# -eq 3 ] || ( echo "Usage: $0 TIME RECDIR RECNAME" && exit )
printf '%i' "${TIME}" &> /dev/null || echo 'Time must be a positive integer'

START=`date '+%s'`

# Make sure RPi CPU frequency scaling is set to performance
sudo su -c 'echo -n performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'

# Set Audio Input
#amixer -c 1 sset 'PCM Capture Source' Line
#pactl set-source-port alsa_input.usb-0d8c_USB_Sound_Device-00-Device.analog-stereo analog-input-linein
#pactl set-source-mute alsa_input.usb-0d8c_USB_Sound_Device-00-Device.analog-stereo no
#pactl set-source-volume alsa_input.usb-0d8c_USB_Sound_Device-00-Device.analog-stereo 25%

#( AUDIODEV=hw:1,0 rec ${DIR}/${NAME}.flac trim 0 ${TIME} )&
#( arecord -f cd -D plughw:1,0 -t wav --disable-resample -d ${TIME} ${DIR}/${NAME}.wav )&
(arecord -r 48k -f S16_LE -c 2 -D hw:1,0 -d ${TIME} ${DIR}/${NAME}.wav)&
#( avconv -f pulse -i alsa_input.usb-0d8c_USB_Sound_Device-00-Device.analog-stereo -t ${TIME} ${DIR}/${NAME}.wav )&
AREC=$!

# -b 3000000 -fps 30 -n -awb fluorescent -sa -15 -br 65 -co 60 -ex backlight -o - > ${START}.h264
( raspivid -rot 180 -awb auto -ex backlight -sa -15 -br 60 -co 50 -hf -vf  -t ${TIME}000 -w 1280 -h 720 -fps 25 -n -o ${DIR}/${NAME}.h264 )&
VREC=$!

echo ${AREC} ${VREC}
wait ${AREC} ${VREC}
