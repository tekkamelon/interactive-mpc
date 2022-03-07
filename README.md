# interactive-mpc
mpcを対話的に扱うシェルスクリプト

## install

```sh
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
