#!/bin/sh

# キーボードの入力を読み取りホスト名またはIPアドレスを設定
read_hostname () {
	if echo $MPD_HOST | grep . ; then

		echo $MPD_HOST > /tmp/hostname

	else

		echo "http://<<hostname or IP_adress>> or localhost" && echo 'hostname > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && echo "" && export MPD_HOST=$(cat /tmp/hostname)

	fi
}

# "/tmp/hostname"が無い場合にホスト名を設定
test -e /tmp/hostname || read_hostname 

# 一時ファイルを環境変数に代入,mpcで疎通確認,成功時のみ入力を待つ
if export MPD_HOST=$(cat /tmp/hostname) && mpc status ; then

# コマンド一覧を表示
commands_list () {
	cat << EOS
	$(echo "HOST:$MPD_HOST")
	command list
	  playlist        -> [0]
	  status          -> [s]
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
	  clear           -> [c]
	  exit            -> [Q]

EOS
}

# ステータス,コマンド一覧を表示
echo "" && commands_list

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	echo 'command? > ' | tr "\n" " " && read command
		case "$command" in

			# プレイリスト一覧をページャで表示
			[0])
				mpc playlist | less && echo ""
			;;
	
			# プレイリスト一覧を環境変数で設定されたページャで表示
			[s])
				echo "" && mpc status && echo ""
			;;

			# 再生/一時停止
			[1])
				echo "" && mpc toggle && echo ""
			;;
	
			# 停止
			[2])
				echo "" && 	mpc stop && echo ""
			;;
	
			# 前の曲
			[3])
				echo "" && mpc prev && echo "" 
			;;
	
			# 次の曲
			[4])
				echo "" && mpc next && echo ""
			;;

			# リピート 
			[5])
				echo "" && mpc repeat && echo ""
			;;

			# ランダム
			[6])
				echo "" && mpc random && echo ""
			;;

			# 検索
			[7])
				echo "" && echo '"format" "keywords" > ' | tr "\n" " " && read format search_keywords

					echo "" && mpc search $format $search_keywords | mpc add && mpc searchplay $search_keywords && echo ""
			;;

			# 音量の調整
			[8])
				echo "" && echo 'volume? > ' | tr "\n" " " && read sound_vol 

					echo "" && mpc volume $sound_vol && echo ""
			;;

			# アップデート
			[9])
				echo "" && echo "now updating..." && mpc update --wait && echo ""
			;;

			# コマンド一覧の表示
			[H])
				echo "" && commands_list && echo ""
			;;

			# ホスト名の再設定
			[C])
				echo "http://<<hostname or IP_adress>> or localhost" && echo 'hostname? > ' | tr "\n" " " && read hostname ; export MPD_HOST=$hostname && echo "$MPD_HOST" | tee /tmp/hostname && echo ""
				mpc && echo ""
			;;

			[c])
				clear && commands_list	
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

