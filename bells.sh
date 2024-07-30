#!/bin/zsh

# Set up script.
zmodload zsh/datetime
spaces=$(echo -en " ")
newlines=$(echo -en "\n\b")
samples_path="/Users/$USER/Dropbox/Sounds/Samples"
IFS="$newlines"; set -A start_tones $(find -f $samples_path | grep -P ".*-CLASSstart.*" | sort)
IFS="$newlines"; set -A stop_tones $(find -f $samples_path | grep -P ".*-CLASSstop.*" | sort)
IFS="$spaces"; tone_times=(0905 1000 1005 1100 1105 1200 1235 1330 1335 1430 1435 1500)
num_tones=${#tone_times[@]}

# Get seconds until first tone.
current_time=$(date +"%H%M")
tone_num=0
diff=1
until [[ $diff -le 0 ]]; do
    tone_num=$(($tone_num + 1))
    if [[ $tone_num -gt $num_tones ]]; then exit; fi
    tone_time=${tone_times[$tone_num]}
    diff=$(($current_time - $tone_time))
done
hrs=$((${tone_time:0:2} - $(date +"%H"))); secs_remaining=$(($hrs*3600))
min=$((${tone_time:2:2} - $(date +"%M") - 1)); secs_remaining=$(($secs_remaining + $(($min*60))))
secs_remaining=$(($secs_remaining + $((60 - $(date +"%S")))))
sleep $secs_remaining

# Play first tone and all remaining tones.
until [[ $tone_num -gt $num_tones ]]; do
    osascript -e 'set volume output volume 30'
    if [[ $(($tone_num & 1)) -ne 0 ]]
        then
        afplay ${start_tones[1 + $RANDOM % ${#start_tones[@]} ]}& sleep 3300
        else
        if [[ $(date +%u) -eq 4 ]] # If it's Thursday, play a blues guitar clip ("stop tone").
            then afplay ${stop_tones[1 + $RANDOM % ${#stop_tones[@]} ]}& sleep 300
            else afplay ${start_tones[1 + $RANDOM % ${#start_tones[@]} ]}& sleep 300
        fi
    fi
    tone_num=$(($tone_num + 1))
done
