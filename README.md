# interactive-mpc
mpcを対話的に扱うシェルスクリプト集

## インストール方法 

### 依存するパッケージのインストール(Debian系)

```sh
$ sudo apt install mpc suckless-tools fzf
```

### リポジトリのクローン

```sh
$ git clone https://github.com/tekkamelon/interactive-mpc

$ cd interactive-mpc/

$ chmod 755 install-mpc.sh
```

## コマンド一覧,使用方法

### interactive_mpc

- mpcコマンドをcli上で対話的に使用

起動後にmpdサーバーのホスト名を入力,疎通が確認できればコマンド一覧を表示  
コマンドの入力を待つ,疎通出来ない場合は一時保存したホスト名を削除し終了

### dmenu_mpc

- mpcコマンドをdmenuで対話的に使用

### mf

- fzfとmpcを用いてキュー内の楽曲を再生

### mpf

- fzfとmpcを用いてプレイリストをキューに追加

### mvf

- fzfとmpcを用いて音量を調整

### mdf

- fzfとmpcを用いて楽曲一覧をキューに追加

