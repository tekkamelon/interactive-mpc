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
		printf "http://<<hostname or IP_adress>> or localhost(default: localhost)\nhostname > "

		# 入力を読み取り一時ファイルに保存
		read -r hostname ;

			# "hostname"の有無を確認,あれば真,無ければ偽
			if [ -n "${hostname}" ] ; then

				# 真の場合は"hostname"を出力
				echo "${hostname}"

			else

				# 偽の場合は"localhost"を出力
				echo "localhost"

			# 出力を一時ファイルに書き込み
			fi >| /tmp/hostname && echo ""

		# 環境変数に代入
		host="$(cat /tmp/hostname)"
		export MPD_HOST="${host}"

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
		read -r port ; echo "${port}" >| /tmp/port && echo ""

		# 環境変数に代入
		port="$(cat /tmp/port)"
		export MPD_PORT="${port}"

	fi

}
# ====== 関数の定義ここまで ======


# "/tmp/hostname","/tmp/port"が無い場合にホスト名及びポート番号を設定
test -e /tmp/hostname || read_hostname
test -e /tmp/port || read_port 

# 一時ファイルを環境変数に代入,mpcで疎通確認,成功した場合は真,失敗した場合は偽
host="$(cat /tmp/hostname)"
port="$(cat /tmp/port)"

if { export MPD_HOST="${host}" ; export MPD_PORT="${port}" ; } && mpc status ; then


# ====== ヒアドキュメントでコマンド一覧を表示 ======
commands_list () {
	cat << EOS
	"MPD_HOST:${MPD_HOST}"
	"MPD_PORT:${MPD_PORT}"
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

		# 空白行を出力
		echo ""

		# プロンプトの表示
		printf "${MPD_HOST}"":""${MPD_PORT} %s>%s " && read -r command
	
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
					printf "keywords > "
	
					# 入力を読み取り,"format","search_keywords"に代入
					read -r search_keywords
	
					# 読み取った入力をmpcに渡し検索
					echo "" && mpc searchplay "${search_keywords}"
	
				;;
	
				# 音量の調整
				[8])
	
					# プロンプトの表示
					printf "volume? > "

					# 入力を読み取り,"sound_vol"に代入
					read -r sound_vol 
	
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
	
					# プロンプトを表示
					printf "http://<<hostname or IP_adress>> or localhost\nhostname > "
	
					# キーボードからの入力を読み取り,"host"に代入
					read -r host ;
	
					# "host"が無ければ真,あれば偽
					if [ -z "${host}" ] ; then
	
						# 真の場合は"localhost"を一時ファイルに書き込み
						echo "localhost" | tee /tmp/hostneme & echo ""

						echo "connection success!"

					# 偽の場合は"host"で疎通確認できれば真,できなければ偽
					elif mpc status -q "${host}" "${MPD_PORT}" ; then
	
						# 真の場合は環境変数に"host"を代入
						export MPD_HOST="${host}"

						# 環境変数一時ファイルに書き込み
						echo "${MPD_HOST}" | tee /tmp/hostname & echo ""

						echo "connection success!"

					else 
	
						# 偽であればメッセージを表示
						printf "connection refused!\n\n" &
						
						# 元の環境変数を代入
						host="$(cat /tmp/hostname)"
						export MPD_HOST="${host}"

					fi
	
					# ステータスを表示
					mpc status

				;;
	
				# ポート番号の再設定
				[P])
					
					# メッセージを出力
					printf "number of port? > " &&
	
					# キーボードからの入力を読み取り,"port"に代入,"MPD_PORT"に"port"を代入
					read -r port ; export MPD_PORT="${port}" && 
	
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
						port="$(cat /tmp/port)"
						export MPD_PORT="${port}"
					
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

