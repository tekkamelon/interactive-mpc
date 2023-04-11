#!/bin/sh -eu

# ====== ホスト名およびポート番号の設定 ======
# "/tmp/hostname"の有無を確認,あれば真,なければ偽
if [ -e /tmp/hostname ] ; then

	# 真の場合はファイル内を環境変数に代入
	export MPD_HOST=$(cat /tmp/hostname)

else

	# 偽の場合は環境変数にlocalhostを代入
	export MPD_HOST=localhost

fi

if [ -e /tmp/port ] ; then

	# 真の場合はファイル内を環境変数に代入
	export MPD_PORT=$(cat /tmp/port)

# "/tmp/port"の有無を確認,あれば真,なければ偽
else

	# 偽の場合は環境変数に6600を代入
	export MPD_PORT=6600

fi
# ====== ホスト名およびポート番号の設定を終了 ======


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
change_HOST
change_PORT
EOS
)

# スクリプト本体の起動時の引数をdmenuに渡す
dmenu_custom="dmenu $@"
# dmenu_custom="rofi -dmenu"

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

	# change_HOSTの場合,dmneuから受け取った入力を変数に代入
	"change_HOST" ) input_host=$(echo "please Enter hostname or IP adress"  | ${dmenu_custom})
		
		# "input_host"で疎通確認,成功で真,失敗で偽
		if mpc --host="${input_host}" ; then 

			# 真の場合はメッセージを表示
			echo "chagned host:${input_host}" &

			# 一時ファイルに書き込み
			echo "${input_host}" >| /tmp/hostname

		else

			# 偽の場合はメッセージを表示,dmenuに渡す
			echo "failed to resolve hostname!" | ${dmenu_custom}

		fi ;;

	# change_PORTの場合,dmneuから受け取った入力を変数に代入
	"change_PORT" ) input_port=$(echo "please Enter number of port"  | ${dmenu_custom})
		
		# "input_host"で疎通確認,成功で真,失敗で偽
		if mpc --port="${input_port}" ; then 

			# 真の場合はメッセージを表示
			echo "chagned port:${input_port}" &

			# 一時ファイルに書き込み
			echo "${input_port}" >| /tmp/port

		else

			# 偽の場合はメッセージを表示,dmenuに渡す
			echo "failed to resolve number of port!" | ${dmenu_custom}

		fi ;;

	# 上記のいずれでもない場合
	* ) echo "command not found" | ${dmenu_custom} ;;

esac | 

# 各コマンドの結果をdmenuに渡し,選択結果を捨てる
${dmenu_custom} > /dev/null

