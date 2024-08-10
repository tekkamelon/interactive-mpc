# interactive-mpc
mpcを対話的に扱うシェルスクリプト

## install

```sh
# mpcのインストール
# debian系
$ sudo apt install mpc

# githubよりclone
$ git clone https://github.com/tekkamelon/interactive-mpc

# スクリプトのあるディレクトリへ移動
$ cd interactive-mpc/

# 実行権限を付与
$ chmod 755 install-mpc.sh
```

## hot to use

```sh
# スクリプトを起動
$ ./interactive-mpc.sh
```

起動後にmpdサーバーのホスト名を入力,疎通が確認できればコマンド一覧を表示  
コマンドの入力を待つ,疎通がなければ一時保存したホスト名を削除し終了

# dmenu_mpc
mpdをdmenuから操作するシェルスクリプト

## install

```sh
# mpc,fzfのインストール
# debian系
$ sudo apt install mpc fzf -y

# githubよりclone
$ git clone https://github.com/tekkamelon/interactive-mpc

# スクリプトのあるディレクトリへ移動
$ cd interactive-mpc/bin

# 実行権限を付与
$ chmod 755 *
```

## interactive_mpc

- mpcコマンドをcli上で対話的に使用

## dmenu_mpc

- mpcコマンドをdmenuで対話的に使用

## mf

- fzfとmpcを用いてキュー内の楽曲を再生

## mpf

- fzfとmpcを用いてプレイリストをキューに追加

## mvf

- fzfとmpcを用いて音量を調整

## mdf

- fzfとmpcを用いて楽曲一覧をキューに追加

