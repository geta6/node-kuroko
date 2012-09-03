# くろこ

* node.jsで書かれた超簡易IRCログボット+ビューワーです。
* ビューワも兼ねてるのでHTTPサーバとして起動します。

# ぷろだくしょん実行

## 前提

* git
* nodejs
* npm
* mongodb

## こまんど

```
git clone https://github.com/geta6/node-kuroko
cd kuroko
npm -g install coffee-script forever
npm install
npm start
```

* `bin/kuroko`も使えます、PATH通してください

## ていし・さいきどう

```
npm stop
npm restart
```

# でばっぐ

* testコマンドに割り当てました〜＾O＾ノ
```
npm test
```

# どうやって使うか

## さーば側
* `kuroko --help` してください

## ぼっと側
* 「ログとって」-> ログ開始します
* 「ログ止めろ」-> ログやめます
* noticeはログされません
