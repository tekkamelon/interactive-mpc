#!/bin/sh

# キーボードの入力を読み取りホスト名またはIPアドレスを設定
read_hostname () {
	echo "http://<<hostname or IP_adress>>" && echo 'hostname > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && echo ""
}

# "/tmp/hostname"が無い場合にホスト名を設定
test -e /tmp/hostname || read_hostname

# pingで疎通確認,成功時のみ入力を待つ
if ping -c 2 $(cat /tmp/hostname) | grep ttl > /dev/null ; then

# コマンド一覧を表示
commands_list () {
	cat << EOS
	$(mpc --host=$(cat /tmp/hostname) version)
	command list
	  playlist        -> [0]
	  play/pause      -> [1]
	  stop            -> [2]
	  previous        -> [3]
	  next            -> [4]
	  repeat ON/OFF   -> [5]
	  random ON/OFF   -> [6]
	  searchplay      -> [7]
	  volume          -> [8]
	  update          -> [9]
	  help            -> [H]
	  change host     -> [C]
	  exit            -> [Q]
EOS
	echo ""
}

# コマンド一覧を表示
commands_list

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	echo 'command? > ' | tr "\n" " " && read command
		case "$command" in

			# プレイリスト一覧を環境変数で設定されたページャで表示
			[0])
				mpc --host=$(cat /tmp/hostname) playlist | less
			;;
	
			# 再生/一時停止
			[1])
				echo "" && mpc --host=$(cat /tmp/hostname) toggle && echo ""
			;;
	
			# 停止
			[2])
			echo "" && 	mpc --host=$(cat /tmp/hostname) stop && echo ""
			;;
	
			# 前の曲
			[3])
				echo "" && mpc --host=$(cat /tmp/hostname) prev && echo "" 
			;;
	
			# 次の曲
			[4])
				echo "" && mpc --host=$(cat /tmp/hostname) next && echo ""
			;;

			# リピート 
			[5])
				echo "" && mpc --host=$(cat /tmp/hostname) repeat && echo ""
			;;

			# ランダム
			[6])
				echo "" && mpc --host=$(cat /tmp/hostname) random && echo ""
			;;

			# 検索
			[7])
				echo "" && echo 'title? > ' | tr "\n" " " && read music_title

				echo "" && echo \"$music_title\" | xargs -I{} mpc --host=$(cat /tmp/hostname) searchplay {} && echo ""
			;;

			# 音量の調整
			[8])
				echo "" && echo 'volume? > ' | tr "\n" " " && read sound_vol 

				echo "" && mpc --host=$(cat /tmp/hostname) volume $sound_vol && echo ""
			;;

			# アップデート
			[9])
				echo "" && echo "now updating..." && mpc --host=$(cat /tmp/hostname) update --wait && echo ""
			;;

			[H])
				echo "" && commands_list && echo ""
			;;

			# ホスト名の再設定
			[C])
				echo "http://<<hostname>>" && echo 'hostname? > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && exit 0
			;;

			# 終了
			[Q])
				exit 0
			;;
		esac
done
else
	# ホストが見つからない場合は"/tmp/hostname"を削除
	rm /tmp/hostname
fi
