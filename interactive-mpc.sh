#!/bin/sh

# ====== 関数の定義 ======
# キーボードの入力を読み取りホスト名またはIPアドレスを設定
read_hostname () {

	# 環境変数の有無を確認,あれば真,無ければ偽
	if [ -n "${MPD_HOST}" ] ; then

		# 真の場合は環境変数を一時ファイルに書き込み
		echo "${MPD_HOST}" >| /tmp/hostname

	else

		# 偽の場合はプロンプトの表示
		printf "http://<<hostname or IP_adress>> or localhost\nhostname > "

		# 入力を読み取り一時ファイルに保存
		read hostname ; echo "${hostname}" >| /tmp/hostname && echo ""

		# 環境変数に代入
		export MPD_HOST=$(cat /tmp/hostname)

	fi

}

# キーボードの入力を読み取りポート番号を設定
read_port () {

	# 環境変数の有無を確認,あれば真,無ければ偽
	if [ -n "${MPD_PORT}" ] ; then

		# 真の場合は環境変数を一時ファイルに書き込み
		echo "${MPD_PORT}" >| /tmp/port

	else

		# 偽の場合はプロンプトの表示
		printf "port number(default: 6600)\nnumber of port > "

		# 入力を読み取り一時ファイルに保存
		read port ; echo "$port" >| /tmp/port && echo ""

		# 環境変数に代入
		export MPD_PORT=$(cat /tmp/port)

	fi

}
# ====== 関数の定義の終了 ======

# "/tmp/hostname"が無い場合にホスト名を設定
test -e /tmp/hostname || read_hostname && 

# "/tmp/port"が無い場合にポート番号を設定
test -e /tmp/port || read_port 

# 一時ファイルを環境変数に代入,mpcで疎通確認,成功した場合は真,失敗した場合は偽
if export MPD_HOST=$(cat /tmp/hostname) && export MPD_PORT=$(cat /tmp/port) && mpc status ; then

# ====== ヒアドキュメントでコマンド一覧を表示 ======
commands_list () {
	cat << EOS
	$(echo "MPD_HOST:${MPD_HOST}")
	$(echo "MPD_PORT:${MPD_PORT}")
	command list
	  queued        -> [0]
	  status        -> [s]
	  play/pause    -> [1]
	  stop          -> [2]
	  previous      -> [3]
	  next          -> [4]
	  repeat ON/OFF -> [5]
	  random ON/OFF -> [6]
	  searchplay    -> [7]
	  volume        -> [8]
	  update        -> [9]
	  help          -> [H]
	  change host   -> [C]
	  change port   -> [P]
	  clear         -> [c]
	  exit          -> [Q]
EOS
}
# ====== ヒアドキュメントここまで ======
	
	# 真の場合はステータス,コマンド一覧を表示
	echo "" && commands_list

	# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
	while :

	do

		echo ""
		echo "${MPD_HOST}:${MPD_PORT} > " | tr "\n" " " && read command
	
			# コマンドの処理
			case "${command}" in
	
				# キュー内の曲をページャで表示
				[0])
					mpc playlist | less
				;;
		
				# ステータスを表示
				[s])
					echo "" && mpc status
				;;
	
				# 再生/一時停止
				[1])
					echo "" && mpc toggle
				;;
		
				# 停止
				[2])
					echo "" && 	mpc stop
				;;
		
				# 前の曲
				[3])
					echo "" && mpc prev 
				;;
		
				# 次の曲
				[4])
					echo "" && mpc next
				;;
	
				# リピート 
				[5])
					echo "" && mpc repeat
				;;
	
				# ランダム
				[6])
					echo "" && mpc random
				;;
	
				# 検索
				[7])
					
					# プロンプトの表示
					printf "format keywords > "
	
					# 入力を読み取り,"format","search_keywords"に代入
					read format search_keywords
	
					# 読み取った入力をmpcに渡し検索
					echo "" && mpc search "${format}" "${search_keywords}" |
	
					# 検索結果をキューに追加して再生
					mpc insert && mpc next
	
				;;
	
				# 音量の調整
				[8])
	
					# プロンプトの表示
					printf "volume? > "

					# 入力を読み取り,"sound_vol"に代入
					read sound_vol 
	
					# 入力をmpcに渡す
					echo "" && mpc volume "${sound_vol}"
	
				;;
	
				# アップデート
				[9])
	
					# メッセージを表示
					printf "\nnow updating..."
	
					mpc update --wait
	
				;;
	
				# コマンド一覧の表示
				[H])
	
					echo "" && commands_list
				;;
	
				# ホスト名の再設定
				[C])
	
					# メッセージを出力
					printf "http://<<hostname or IP_adress>> or localhost > "
	
					# キーボードからの入力を読み取り,"host"に代入,"MPD_HOST"に"port"を代入
					read host ; export MPD_HOST=${host} && 
	
					# ホスト名が有効であれば真,無効であれば偽
					if mpc status -q "${MPD_HOST}" "${MPD_PORT}" ; then
	
						# 真の場合は入力を一時ファイルに書き込み
						echo "${MPD_HOST}" | tee /tmp/host && echo "" &
	
						# メッセージを表示
						echo "connection success!"
	
					else
	
						# 偽であればメッセージを表示
						echo "connection refused!"
	
						# 改行を出力
						echo "" &
						
						# 元の環境変数を代入
						export MPD_HOST=$(cat /tmp/hostname)
					
					fi
	
					# ステータスを表示
					mpc status && echo ""
				;;
	
				# ポート番号の再設定
				[P])
					
					# メッセージを出力
					printf "number of port? > " &&
	
					# キーボードからの入力を読み取り,"port"に代入,"MPD_PORT"に"port"を代入
					read port ; export MPD_PORT=${port} && 
	
					# ポート番号が有効であれば真,無効であれば偽
					if mpc status -q "${MPD_HOST}" "${MPD_PORT}" ; then
	
						# 真の場合は入力を一時ファイルに書き込み
						echo "${MPD_PORT}" | tee /tmp/port &&
	
						# メッセージを表示
						echo "connection success!"
	
					else
	
						# 偽であればメッセージを表示
						echo "connection refused!" &
						
						# 元の環境変数を代入
						export MPD_PORT=$(cat /tmp/port)
					
					fi
	
					# ステータスを表示
					mpc status
				;;
	
				# 端末をクリアしコマンドリストを表示
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

	# 偽の場合は一時ファイルを削除
	rm /tmp/hostname /tmp/port

fi

