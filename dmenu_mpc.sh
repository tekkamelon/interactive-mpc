#!/bin/sh -eu

# コマンド一覧
command=$(cat << EOS
status
toggle
next
prev
random
repeat
stop
clear
listplaylist
playlist
listall
EOS
)

# dmenuの設定
dmenu_custom="dmenu $@"

# コマンド一覧を${dmenu_custom}で表示,選択されたコマンドを代入
selected_command=$(echo "${command}" | ${dmenu_custom})

# 選択されたコマンドに応じて処理を分岐
case "${selected_command}" in

	# ステータスの表示
	"status" ) mpc status | ${dmenu_custom} ;;

	# toggle,next,prev,random,repeat,stop,clearの処理
	"toggle" | "next" | "prev" | "random" | "repeat" | "stop" | "clear" ) echo "${selected_command}" | xargs mpc ;;

	# playlistの処理
	"playlist" ) mpc playlist | nl -s":" | ${dmenu_custom} | cut -d":" -f1 | xargs mpc play ;;

	# listallの処理
	"listall" ) mpc listall | ${dmenu_custom} | mpc insert && mpc next ;;

	# lsplaylistの処理
	"listplaylist" ) mpc lsplaylist | ${dmenu_custom} | xargs mpc load ;;

esac

