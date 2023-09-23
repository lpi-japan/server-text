# Webサーバーの構築
ホームページやWebシステムを公開するためのWebサービスを設定します。基本としては、アクセス制限をかける設定と動作を確認します。応用としては、サーバーとして広く使われているバーチャルホスト機能にも触れてもらいます。

## 用語集
#### HTML(HyperText Markup Language)
Webサーバー用のドキュメントを書くためのタグを使って文章を構造的に記述できるマークアップ言語です。他ドキュメントへのハイパーリンクを書いたり、画像利用したり、リストや表などの高度な表現も可能です。

#### HTTP(HyperText Transfer Protocol)
WebブラウザーとWebサーバーの間でHTMLなどのコンテンツ(データ)送受信に使われる通信手順です。ファイルのリクエスト(要求)とファイルのレスポンス(返送)が組でセッションになります。

#### Apache Webサーバー
世界中でもっとも使われているWebサーバーであり、大規模な商用サイトから自宅サーバーまで幅広く利用されています。Apacheソフトウェア財団のApache HTTPサーバープロジェクトで行われている、オープンソースソフトウェアです。

#### URL(Uniform Resource Locator)
インターネット上のリソースを指定するための記述方法で、ホームページのアドレスやメールのアドレスなどを指定できます。リソースを特定するスキーム名とアドレスを://でつないで書きます。

## Webサーバーの仕組み
Webシステムとは、インターネット環境で最も代表的なクライアントサーバーシステムで、クライアントのWebブラウザーとWebサーバーから構成されます。Webサーバーは要求されたファイルをWebクライアントに提供し、クライアントは受け取ったファイルを表示します。提供される情報はテキストから画像や動画と幅広く、クライアントが対応しているデータならば広く扱えます。Webシステムの文章データとしてはXML ベースの規格であるXHTMLや従来のHTMLなどが一般的に使われています。WebサーバーとしてApacheが使われている割合はかなり高いでしょう。


# パッケージのインストール
## パッケージとは

## dnfコマンド

## dnfコマンドが参照するパッケージリポジトリ

## dnfコマンドに関する関連事項
### sudoコマンドによるroot権限の取得
dnfコマンドによるパッケージのインストールは、システムの変更を伴うため管理者であるrootの権限が必要になります。コマンド実行時にroot権限を取得するには、sudoコマンドを使用します。

### 依存関係の解消

## dnf installコマンドによるパッケージのインストール

sudo dnf install httpd


# Webサーバーの起動
## systemctlコマンド


## Webサーバーの起動

sudo systemctl start httpd

# Webサーバーの動作確認
## systemctlコマンドによる動作状態の確認

sudo systemctl status httpd


## curlコマンドによる接続確認

curl localhost

## ゲストOSのWebブラウザによる接続確認

localhost

## ホストOSのWebブラウザによる接続確認

sudo firewall-cmd --add-service=http --zone=public --permanent

設定の再読込を行います。

sudo firewall-cmd --reload


http://192.168.56.101

# Webサーバーの停止
## systemctlコマンドによる停止

sudo systemctl stop httpd

## systemctlコマンドによる動作状態の確認

sudo systemctl status httpd


## curlコマンドによる接続確認

curl localhost

## ゲストOSのWebブラウザによる接続確認

localhost


# ログの確認
## Webサーバーのログファイルの確認

/var/log/httpd

sudo ls /var/log/httpd

access_log

error_log


## アクセスログの確認

sudo cat /var/log/httpd/access_log


## エラーログの確認

sudo cat /var/log/httpd/error_log

# HTMLファイルを配置する

## index.htmlの作成

sudo sh -c "echo 'Hello,World' > /var/www/html/index.html"

## Webブラウザからのアクセス




