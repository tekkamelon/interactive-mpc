#!/bin/sh -eu

# コマンドの一覧
command=$(cat << EOS
toggle
next
prev
random
repeat
stop
clear
lsplaylist 
playlist
listall
EOS
)

# change_HOST
# change_PORT

# コマンド一覧をdmenuで表示,選択されたコマンドを代入
selected_command=$(echo "${command}" | dmenu)

# 選択されたコマンドに応じて処理を分岐
case "${selected_command}" in

	"toggle" | "next" | "prev" | "random" | "repeat" | "stop" | "clear" ) echo "${selected_command}" | xargs mpc ;;

	"lsplaylist" ) echo "${selected_command}" | xargs mpc | dmenu | xargs mpc load ;;

	"playlist" ) echo "${selected_command}" | xargs mpc | nl -s":" | dmenu | cut -d":" -f1 | xargs mpc play ;;

	"listall" ) echo "${selected_command}" | xargs mpc | dmenu | mpc insert && mpc next ;;

	# "change_HOST" ) echo "please Enter hostname or IP adress" | dmenu | xargs -I{} mpc -q --host={} || echo "error!" | dmenu

esac

