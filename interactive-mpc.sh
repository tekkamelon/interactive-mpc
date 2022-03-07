#!/bin/sh

# "/tmp/hostname"が無い場合にホスト名を設定
if ! cat /tmp/hostname 2> /dev/null ; then
	echo "http://<<hostname>>.local" && echo 'hostname > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname
else
	: # 何もしない
fi

# pingで疎通確認,成功時のみ入力を待つ
if ping -c 2 $(cat /tmp/hostname).local | grep ttl > /dev/null ; then

	# mpcコマンドをホスト名を指定して実行
	mpc_host () {
		mpc --host=$(cat /tmp/hostname).local
	}

# コマンド一覧を表示
commands_list () {
	echo ""
	cat << EOS
	command list
	  playlist        -> [0]
	  play/pause      -> [1]
	  stop            -> [2]
	  previous        -> [3]
	  next            -> [4]
	  repeat ON/OFF   -> [5]
	  random ON/OFF   -> [6]
	  volume          -> [7]
	  help            -> [H]
	  change host     -> [C]
	  exit            -> [Q]
EOS
	echo ""
}

commands_list

# "shift+q"キーを入力で終了,それ以外で一覧に表示されたコマンドを入力で実行
while :
do
	# read -p "command? > " "command"
	echo 'command? > ' | tr "\n" " " && read command
		case "$command" in

			# プレイリスト一覧を表示
			[0])
				mpc --host=$(cat /tmp/hostname).local playlist | $PAGER || 
				mpc --host=$(cat /tmp/hostname).local playlist
			;;
	
			# 再生/一時停止
			[1])
				mpc --host=$(cat /tmp/hostname).local toggle
			;;
	
			# 停止
			[2])
				mpc --host=$(cat /tmp/hostname).local stop
			;;
	
			# 前の曲
			[3])
				mpc --host=$(cat /tmp/hostname).local prev
			;;
	
			# 次の曲
			[4])
				mpc --host=$(cat /tmp/hostname).local next
			;;

			# リピート 
			[5])
				mpc --host=$(cat /tmp/hostname).local repeat
			;;

			# ランダム
			[6])
				mpc --host=$(cat /tmp/hostname).local random
			;;

			# 音量の調整
			[7])
				echo "" && echo 'volume? > ' | tr "\n" " " && read sound_vol

				mpc --host=$(cat /tmp/hostname).local volume $sound_vol 
			;;

			[H])
				echo "" && commands_list
			;;
			# ホスト名の再設定
			[C])
				echo "http://<<hostname>>.local" && echo 'hostname? > ' | tr "\n" " " && read hostname ; echo "$hostname" > /tmp/hostname && exit 0
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
