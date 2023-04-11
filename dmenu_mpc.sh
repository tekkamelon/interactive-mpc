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

# スクリプト本体の起動時の引数をdmenuに渡す
dmenu_custom="dmenu $@"

# コマンド一覧を${dmenu_custom}で表示,選択されたコマンドを代入
selected_command=$(echo "${command}" | ${dmenu_custom})

# 選択されたコマンドに応じて処理を分岐
case "${selected_command}" in

	# ステータスの表示
	"status" ) mpc status ;;

	# toggle,next,prev,random,repeat,stop,clearの場合,選択結果をmpcに渡し出力を抑制
	"toggle" | "next" | "prev" | "random" | "repeat" | "stop" | "clear" ) mpc "${selected_command}" ;;

	# playlistの場合,キュー内の曲に行番号を付与して出力,dmenuへ渡し,選択結果の行番号のみmpcに渡す
	"playlist" ) mpc playlist | grep -n . | ${dmenu_custom} | cut -d":" -f1 | xargs mpc play ;;

	# listallの場合,曲一覧をdmenuに渡し,選択結果をmpcに渡す
	"listall" ) mpc listall | ${dmenu_custom} | mpc insert && mpc next ;;

	# lsplaylistの場合,プレイリスト一覧をdmenuに渡し,選択結果をmpcに渡す
	"listplaylist" ) mpc lsplaylist | ${dmenu_custom} | xargs mpc load ;;

	# 上記のいずれでもない場合
	* ) echo "command not found" | ${dmenu_custom} ;;

esac | 

# 各コマンドの結果をdmenuに渡し,選択結果を捨てる
${dmenu_custom} > /dev/null

