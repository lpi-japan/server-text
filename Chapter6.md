# とりあえずVer3の原稿をはめこみ

# メールサーバーの構築
メールのやり取りが行えるよう、メールサーバーを設定します。まずはPostfixを使って、メールサーバー同士でメールのやり取りが行えるように設定します。さらにPOP/IMAPサーバーとメールクライアントを使って、より実践的なメール環境を構築します。

## 用語集
### メールサーバー
電子メールのサービスを行います。クライアントよりメールを受け取り、バケツリレーの方式で相手先のメールサーバーまで送ります。また、受信用のメールサーバーでは、送ってきたメールを蓄積しておいて、クライアントの要求に応じて応答します。

### MTA（Mail Transfer Agent）
メールの転送を行うプログラムです。SendmailやPostfixなどが代表例です。

### SMTP(Simple Mail Transfer Protocol)
電子メールの送信、転送のときに利用されるプロトコルのことです。

### SMTP認証
SMTPでのメールを送信する際に認証を行う機構です。迷惑メール対策としてのメール中継の制限を、この認証機能で許可する、といった利用方法があります。

### Postfix
MTAとして動作するサーバープログラムです。LinuxやUnixのシステムで古くから使われてきたSendmailよりもセキュリティが高く、高速に動作すると言われています。

### POP3(Post Office Protocol version3)
クライアントが電子メールを取り寄せるときに利用されるプロトコルです。シンプルな設計で、IMAP4と比べて機能が少ないです。

### IMAP4（Internet Message Access Protocol 4）
クライアントが電子メールを取り寄せるときに利用されるプロトコルです。メールのフォルダ機能サポート等、多機能です。

### Dovecot
POP3やIMAP4のサーバー機能を提供するプログラムです。

### Thunderbird
Mozilla Projectが配布している、高機能なメールクライアントソフトウェアです。Windows, Mac OS X, Linux等と、動作環境は多岐に渡っており、各国語版も用意されております。機能も必要十分な内容がそろっています。


## メールのやり取りの仕組み
インターネット上で沢山の人が電子メールを利用していますが、電子メールは以下の手順でやり取りされています。括弧内はそれぞれの手順に関わるプログラムや動作、プロトコルです。

1. 送信者のメールクライアントから送信用メールサーバーにメールを送信します（SMTP認証）
2. 送信用メールサーバーは受信用メールサーバーにメールを転送します（MTAとSMTP）
3. 受信用メールサーバーは宛先アドレスのメールボックスにメールを配送します（メール配送）
4. 受信者のメールクライアントでメールボックスのあるメールサーバーに接続します（POP3やIMAP4）
5. 受信者のメールクライアントがメールを受信して、メールを見ることができます

## メールの送信
メールの送信は、メールサーバーを介してやり取りが行われます。メールサーバーがメールを受け取ると、宛先のメールアドレスを担当しているメールサーバーに転送され、最終的に宛先のメールボックスに入れられます。ThunderbirdやOutlookのようなメールクライアントから送信したメールでも、GmailのようなWebメールから送信したメールでも、動作原理は同じです。

メールの送信に関わるプログラムやプロトコルについて解説します。

### MTA(Mail Transfer Agent)
メールクライアントから送信されたメールは、送信用メールサーバーから宛先の受信用メールサーバーに転送されます。このメールの転送を行うプログラムをMTAと呼びます。本教科書ではPostfixというMTAを利用します。他に有名なMTAとしてSendmailがあります。

### MDA(Mail Delivery Agent)
受信用メールサーバーが受信したメールを宛先アドレスのメールボックスに配送するプログラムをMDAと呼びます。MTAであるPostfixがMDAの機能も受け持ちます。他にMDAとしてProcmailがあります。

### MUA(Mail User Agent)
メールの利用者が、メールの送信や受信を行うプログラムをMUAと呼びます。本教科書ではThunderbirdを利用します。WebメールもMUAの一種となります。

### SMTP(Simple Mail Transfer Protocol)の拡張
メールクライアントからのメール送信や、メールサーバー間のメールの転送は、SMTPというプロトコルでやり取りされています。SMTPはかなり昔に設計、定義されたプロトコルのため、認証やアクセス制限などが無く、勝手にメールサーバーを利用されて迷惑メールを送られてしまう問題がありました。このような問題を解決するためにESMTP（拡張SMTP）が定義されました。SMTPと呼ぶ場合、このESMTPで定義された機能も含んでいることがあります。

#### SMTP認証(SMTP Authentication)とリレー
SMTP認証はESMTPの機能のうちの1つです。通常のSMTPには認証機能が無いため、送信元のIPアドレスを制限するなど適切に設定されていないと迷惑メール送信の踏み台とされてしまう問題があります。SMTP認証は、メールの送信時に認証を行い、認証が行われた場合のみメールの送信を受け付けます。受け付けたメールを宛先の受信用メールサーバーに転送することをリレーと呼びます。

## メールの受信
送信されたメールが宛先のメールボックスに配送されると、受信者はメールを受信して読むことができます。メールの受信に関係するいくつかの事項について解説します。

### メールの配送
受信用メールサーバーが送信用メールサーバーからメールを受け取り、宛先アドレスのメールボックスにメールを届けることを配送と呼びます。メールボックスが無い場合、宛先不明として送信用メールサーバーにエラーを返します。メールの配送を行うソフトウェアをMDA(Mail Delivery Agent)と呼びます。

#### ローカル配送
送信側と受信側が同じメールサーバーを使用している場合、メールは外部のメールサーバーに転送する必要がなく、すぐに宛先アドレスのメールボックスに配送されます。これをローカル配送と呼びます。

### POP3(Post Office Protocol version 3)
POP3は電子メールを受信するときに利用するプロトコルです。非常にシンプルなプロトコルで、ユーザー名、パスワードを利用して接続し、メールの内容を受信します。

### IMAP4
IMAP4もPOP3同様、メールを受信するときに利用するプロトコルです。IMAP4はPOP3に比べて機能が豊富で、大きな特徴としてフォルダ機能をサポートしていることが挙げられます。メールをIMAPサーバーに残しておくことができるので、メールクライアントとWebメールを併用したりすることもできますが、その分だけメールサーバーのストレージを消費するので容量管理が必要になります。

## メールサーバーの構築
メールサーバーの構築は、送信用メールサーバーと受信用メールサーバーの2台を構築します。それぞれのサーバーを以下のように設定します。

- 1台のマシンで、メールサーバーとメールクライアントの1台2役とします
- MTAとしてPostfixをインストールし、送信用メールサーバーおよび受信用メールサーバーとして設定します
- POP3/IMAP4サーバーとしてDovecotをインストールし、設定します
- それぞれのメールサーバーにメールアカウントを作成します
- メールクライアントとしてThunderbirdをインストールし、サーバー自身を送受信用サーバーとして設定します

通常、メールサーバーとメールクライアントは別々のマシンを用意し、その間をSMTPやPOP3、IMAP4などで接続しますが、演習では同じマシンで行います。

構築は、Postfixの設定とmailコマンドによるメールの送受信、DovecotとThunderbirdの設定とメールの送受信の2段階に分けて行います。

### mailコマンドを利用したメールの送受信
MTAの設定ができたら、mailコマンドを使ってメールのやり取りを行います。メールクライアントの設定を必要としないので、MTAが正しく設定されていることを確認するのに適しています。

### Thunderbirdを利用したメールの送受信
Thunderbirdをメールクライアントとして設定し、SMTP認証によるメール送信や、DovecotによるIMAPサーバーからのメール受信を行います。

## Postfixのインストール
Postfixをdnfコマンドでインストールをします。また、SMTP認証で使用するCyrus-SASLも一緒にインストールしておきます。

dnf install postfix cyrus-sasl
Last metadata expiration check: 3:46:14 ago on Sun Oct 22 19:14:35 2023.
Dependencies resolved.
================================================================================
 Package           Architecture   Version                Repository        Size
================================================================================
Installing:
 cyrus-sasl        aarch64        2.1.27-21.el9          baseos            72 k
 postfix           aarch64        2:3.5.9-19.el9         appstream        1.4 M
Installing dependencies:
 libicu            aarch64        67.1-9.el9             baseos           9.5 M

Transaction Summary
================================================================================
Install  3 Packages

Total download size: 11 M
Installed size: 39 M
Is this ok [y/N]: y
Downloading Packages:
(1/3): cyrus-sasl-2.1.27-21.el9.aarch64.rpm     221 kB/s |  72 kB     00:00
(2/3): postfix-3.5.9-19.el9.aarch64.rpm         1.2 MB/s | 1.4 MB     00:01
(3/3): libicu-67.1-9.el9.aarch64.rpm            1.2 MB/s | 9.5 MB     00:08
--------------------------------------------------------------------------------
Total                                           1.1 MB/s |  11 MB     00:09
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                        1/1
  Installing       : libicu-67.1-9.el9.aarch64                              1/3
  Running scriptlet: postfix-2:3.5.9-19.el9.aarch64                         2/3
  Installing       : postfix-2:3.5.9-19.el9.aarch64                         2/3
  Running scriptlet: postfix-2:3.5.9-19.el9.aarch64                         2/3
  Running scriptlet: cyrus-sasl-2.1.27-21.el9.aarch64                       3/3
  Installing       : cyrus-sasl-2.1.27-21.el9.aarch64                       3/3
  Running scriptlet: cyrus-sasl-2.1.27-21.el9.aarch64                       3/3
  Verifying        : postfix-2:3.5.9-19.el9.aarch64                         1/3
  Verifying        : cyrus-sasl-2.1.27-21.el9.aarch64                       2/3
  Verifying        : libicu-67.1-9.el9.aarch64                              3/3

Installed:
  cyrus-sasl-2.1.27-21.el9.aarch64           libicu-67.1-9.el9.aarch64
  postfix-2:3.5.9-19.el9.aarch64

Complete!

### main.cfの設定
Postfixの設定ファイルは、/etc/postfix/main.cfです。次のパラメータを探して設定します。

パラメータによっては、コメントアウトされた形で記述されているので、コメントアウトを外して設定を有効にします。smtpd_sasl_auth_enableとsmtpd_recipient_restrictionsは、main.cfに記述されていないので、ファイルの最後に追加しておきます。

#### myhostname
メールサーバーのホスト名を設定します。

myhostname = mail.alpha.jp

#### mydomain
メールサーバーのドメイン名を設定します。

mydomain = alpha.jp

#### inet_interfaces
メールを受け付けるネットワークインターフェースのIPアドレスを設定します。

inet_interfaces = localhost, 192.168.56.101

#### mydestination
メールを受信するドメイン名を設定します。このドメイン名宛以外のメール転送は受け付けません。

mydestination = alpha.jp

#### mynetworks
信頼するクライアントのIPアドレスを設定します。このIPアドレスからのメール送信は、認証無しでリレーして宛先の受信用メールサーバーに転送されます。

mynetworks = 192.168.56.101

#### smtpd_sasl_auth_enable
SMTP認証用のSASL認証連携を有効にします。

smtpd_sasl_auth_enable = yes

#### smtpd_recipient_restrictions
SMTP認証でSASL認証されたクライアントからのメール送信を許可するように設定します。

smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destinaition

### 書式のチェック
/etc/postfix/main.cfの修正ができたら、書式チェックを行っておきます。

# postfix check

書式が正しい場合には、何も表示されません。エラーが表示された場合には、エラー内容をよく見て修正します。

## ファイアウォールの設定
Postfixの再起動の前に、メールサーバーでメールの受信ができるようにファイアウォールのサービス許可設定を行います。

# firewall-cmd --add-service=smtp

さらに、設定を保存しておきます。

# firewall-cmd --runtime-to-permanent

### Postfixの再起動
postfixサービスを再起動します。

# systemctl restart postfix.service

### Postfixの自動起動の設定


postfixサービスの自動起動を設定します。

# systemctl enable postfix.service
Created symlink /etc/systemd/system/multi-user.target.wants/postfix.service → /usr/lib/systemd/system/postfix.service.

自動起動の設定を確認します。

# systemctl is-enabled postfix.service
enabled

#### SASL認証連携の設定
PostfixはSMTP認証をSASL認証と連携して行います。Postfixの設定ファイルであるmain.cfでSASL認証を有効にし、SMTP認証の
SASL認証は、SMTP認証の認証機構です。Postfixは設定ファイルでSMTP認証の機能を有効にできますが、Postfix自体は認証の機能を持っていません。設定ファイルでSMTP認証の機能を有効にすると、Postfixはsaslauthdに認証を依頼してその結果を受け取ります。


### saslauthdサービスの起動
SMTP 認証用のsaslauthdサービスを起動します。

# systemctl start saslauthd.service

sasluauthdの自動起動設定も行っておきます。

# systemctl enable saslauthd.service
Created symlink from /etc/systemd/system/multi-user.target.wants/saslauthd.service to /usr/lib/systemd/system/saslauthd.service.

## アカウントの作成
それでは、実際にメールを送信する前に、宛先となるアカウントを作成します。

### host1.alpha.jpにuseraを作成
host1.alpha.jpでuseraというアカウントを作成します。このアカウントはusera@alpha.jpというメールアドレスになります。ユーザーは、mailグループに参加させるように設定します。

[root@host1 postfix]# useradd -G mail usera
[root@host1 postfix]# passwd usera
ユーザー usera のパスワードを変更。
新しいパスワード: userapass	← 入力文字は非表示
新しいパスワードを再入力してください: userapass	← 入力文字は非表示
passwd: すべての認証トークンが正しく更新できました。

### host2.beta.jpにuserbを作成
host2.beta.jpでuserbというアカウントを作成します。このアカウントはuserb@beta.jpというメールアドレスになります。ユーザーは、mailグループに参加させるように設定します。

[root@host2 postfix]# useradd -G mail userb
[root@host2 postfix]# passwd userb
ユーザー userb のパスワードを変更。
新しいパスワード: userbpass	← 入力文字は非表示
新しいパスワードを再入力してください: userbpass	← 入力文字は非表示
passwd: すべての認証トークンが正しく更新できました。

## メールの送受信
次にメールを送信します。メールの送受信は作成した一般ユーザーで行います。一般ユーザーで操作できるよう別の端末を起動し、suコマンドを使ってユーザーを切り替えます。メールの送信はmailコマンドを使用します。

### ログの確認用端末の設定

1. 「端末」を起動します
1. tailコマンドを実行して、/var/log/maillogを表示します。-fオプションを付けて実行すると、ログが書き込まれる毎に再読み込みされて最新のログを閲覧できます。

# tail -f /var/log/maillog

### メール送受信用端末の起動とユーザー切り替え
メール送受信用の端末を起動し、suコマンドでユーザーの切り替えを行います。

1. 「端末」を起動します
2. suコマンドでユーザーを切り替えます

#### host1.alpha.jpでuseraに切り替え

[root@host1 ~]# su - usera
[usera@host1 ~]$  id
uid=1003(usera) gid=1003(usera) groups=1003(usera),12(mail) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

#### host2.beta.jpでuserbに切り替え

# su - userb
[userb@host2 ~]$  id
uid=1001(userb) gid=1001(userb) groups=1001(userb),12(mail) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023

### usera@alpha.jpからuserb@beta.jpへメール送信
mailコマンドを使って、host1.alpha.jpのuseraからuserb@beta.jpへメールを送信します。


[usera@host1 ~]$ mail userb@beta.jp	← mailコマンドの引数に宛先のアドレスを指定
Subject: Test mail from usera		← Subjectを入力
This is Test Mail from usera		← メッセージ本文を入力
.	← メッセージ本文の入力が終わったらピリオドを入力
EOT

### userbのメール着信確認
mailコマンドを使って、host2.beta.jpのuserbにメールが届いているかを確認します。

[userb@host2 ~]$ mail
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/userb": 1 message 1 new
>N  1 usera@mail.alpha.jp   Tue Feb 19 13:38  21/751   "Test mail from usera"
& 1	← 1を入力
Message  1:
From usera@mail.alpha.jp  Tue Feb 19 13:38:31 2019
Return-Path: <usera@mail.alpha.jp>
X-Original-To: userb@beta.jp
Delivered-To: userb@beta.jp
Date: Tue, 19 Feb 2019 13:38:31 +0900
To: userb@beta.jp
Subject: Test mail from usera
User-Agent: Heirloom mailx 12.5 7/5/10
Content-Type: text/plain; charset=us-ascii
From: usera@mail.alpha.jp
Status: R

This is Test Mail from usera

& q	← qを入力
Held 1 message in /var/spool/mail/userb

このように、host1.alpha.jpからhost2.beta.jpにメールが送られていることがわかります。
以上で、Aさんによる演習が終了です。次に、今度はBさんがAさんに対してメールを送ってみましょう。

## メールクライアントソフトでのメールの送受信
通常のメールサーバーの運用では、メールの利用者はメールクライアントを使用してメールの送受信を行います。送信はSMTP、受信はIMAPやPOP3をプロトコルとして使用します。
IMAPサーバーを利用してメールを受信できるよう、IMAPサーバーであるDevecotと、メールクライアントとしてThunderbirdをインストールしてメールを送受信してみます。


### Dovecotパッケージの追加
それでは早速、必要なパッケージを追加して、クライアントでメールを送受信できるように設定してみましょう。まずはIMAPサーバーであるDovecotをインストールします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。

# yum install dovecot
読み込んだプラグイン:fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: ftp.riken.jp
依存性の解決をしています
--> トランザクションの確認を実行しています。
---> パッケージ dovecot.x86_64 1:2.2.36-3.el7 を インストール
--> 依存性の処理をしています: libclucene-shared.so.1()(64bit) のパッケージ: 1:dovecot-2.2.36-3.el7.x86_64
--> 依存性の処理をしています: libclucene-core.so.1()(64bit) のパッケージ: 1:dovecot-2.2.36-3.el7.x86_64
--> トランザクションの確認を実行しています。
---> パッケージ clucene-core.x86_64 0:2.3.3.4-11.el7 を インストール
--> 依存性解決を終了しました。

依存性を解決しました

================================================================================
 Package              アーキテクチャー
                                     バージョン              リポジトリー  容量
================================================================================
インストール中:
 dovecot              x86_64         1:2.2.36-3.el7          base         4.4 M
依存性関連でのインストールをします:
 clucene-core         x86_64         2.3.3.4-11.el7          base         528 k

トランザクションの要約
================================================================================
インストール  1 パッケージ (+1 個の依存関係のパッケージ)

総ダウンロード容量: 4.9 M
インストール容量: 16 M
Is this ok [y/d/N]: y	← 確認してyを入力
Downloading packages:
(1/2): clucene-core-2.3.3.4-11.el7.x86_64.rpm              | 528 kB   00:15     
(2/2): dovecot-2.2.36-3.el7.x86_64.rpm                     | 4.4 MB   00:15     
--------------------------------------------------------------------------------
合計                                               317 kB/s | 4.9 MB  00:15     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  インストール中          : clucene-core-2.3.3.4-11.el7.x86_64              1/2 
  インストール中          : 1:dovecot-2.2.36-3.el7.x86_64                   2/2 
  検証中                  : clucene-core-2.3.3.4-11.el7.x86_64              1/2 
  検証中                  : 1:dovecot-2.2.36-3.el7.x86_64                   2/2 

インストール:
  dovecot.x86_64 1:2.2.36-3.el7                                                 

依存性関連をインストールしました:
  clucene-core.x86_64 0:2.3.3.4-11.el7                                          

完了しました!

### Dovecotの設定

次に、IMAPサーバーであるDovecotの設定を行います。設定ファイルは/etc/dovecot/dovecot.confと/etc/dovecot/conf.dディレクトリ以下に分かれています。

##### /etc/dovecot/dovecot.conf
全体的な設定ファイルです。デフォルトの設定がコメントアウトで記述されています。特に変更は必要ありません。

# vi /etc/dovecot/dovecot.conf

（略）
# Protocols we want to be serving.
#protocols = imap pop3 lmtp	← IMAP/POP3/LMTPが使用可能

# A comma separated list of IPs or hosts where to listen in for connections.
# "*" listens in all IPv4 interfaces, "::" listens in all IPv6 interfaces.
# If you want to specify non-default ports or anything more complex,
# edit conf.d/master.conf.
#listen = *, ::	← ホストのすべてのIPアドレスで接続を受け付ける

#### /etc/dovecot/conf.d/10-mail.conf
メールボックスの位置などを設定するファイルです。今回はmbox形式のメールボックスを指定します。

# vi /etc/dovecot/conf.d/10-mail.conf

（略）
#   mail_location = maildir:~/Maildir
#   mail_location = mbox:~/mail:INBOX=/var/mail/%u
#   mail_location = mbox:/var/mail/%d/%1n/%n:INDEX=/var/indexes/%d/%1n/%n
#
# <doc/wiki/MailLocation.txt>
#
mail_location = mbox:~/mail:INBOX=/var/mail/%u	←　修正

#### /etc/dovecot/conf.d/10-auth.conf
認証を設定するファイルです。今回は暗号化していない平文での認証を許可し、Linuxのログイン情報を認証に利用できるように設定します。

# vi /etc/dovecot/conf.d/10-auth.conf

##
## Authentication processes
##

# Disable LOGIN command and all other plaintext authentications unless
# SSL/TLS is used (LOGINDISABLED capability). Note that if the remote IP
# matches the local IP (ie. you're connecting from the same computer), the
# connection is considered secure and plaintext authentication is allowed.
# See also ssl=required setting.
#disable_plaintext_auth = yes
disable_plaintext_auth = no	← 追加

#### /etc/dovecot/conf.d/10-ssl.conf
SSL/TLSを設定するファイルです。今回はSSL/TLS暗号化をしませんので、SSLの利用を停止しておきます。

# vi /etc/dovecot/conf.d/10-ssl.conf

##
## SSL settings
##

# SSL/TLS support: yes, no, required. <doc/wiki/SSL.txt>
# disable plain pop3 and imap, allowed are only pop3+TLS, pop3s, imap+TLS and imaps
# plain imap and pop3 are still allowed for local connections
#ssl = required	←　コメントアウト
ssl = no	← 追加

### ファイアウォールの設定
Dovecotの起動の前に、POP3とIMAP4でメールの受信ができるようにファイアウォールのサービス許可設定を行います。

# firewall-cmd --add-service=pop3
# firewall-cmd --add-service=imap

さらに、設定を保存しておきます。

# firewall-cmd --runtime-to-permanent

### Dovecotの再起動
dovecotサービスを再起動します。

# systemctl start dovecot.service

自動起動設定も行っておきます。

# systemctl enable dovecot.service
Created symlink from /etc/systemd/system/multi-user.target.wants/dovecot.service to /usr/lib/systemd/system/dovecot.service.

### Thunderbirdのインストール
メールクライアントとしてThunderbirdをインストールします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。

# yum install thunderbird
読み込んだプラグイン:fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirrors.cat.net
依存性の解決をしています
--> トランザクションの確認を実行しています。
---> パッケージ thunderbird.x86_64 0:52.9.1-1.el7.centos を インストール
--> 依存性解決を終了しました。

依存性を解決しました

================================================================================
 Package            アーキテクチャー
                                  バージョン                  リポジトリー
                                                                           容量
================================================================================
インストール中:
 thunderbird        x86_64        52.9.1-1.el7.centos         base         76 M

トランザクションの要約
================================================================================
インストール  1 パッケージ

総ダウンロード容量: 76 M
インストール容量: 144 M
Is this ok [y/d/N]: y	← 確認してyを入力
Downloading packages:
thunderbird-52.9.1-1.el7.centos.x86_64.rpm                 |  76 MB   00:22     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  インストール中          : thunderbird-52.9.1-1.el7.centos.x86_64          1/1 
  検証中                  : thunderbird-52.9.1-1.el7.centos.x86_64          1/1 

インストール:
  thunderbird.x86_64 0:52.9.1-1.el7.centos                                      

完了しました!

### Thunderbirdの起動
次にThunderbirdの設定を行います。以下の手順は受講者Aの場合です。

1. adminでログインしている場合にはログアウトします。ログアウトは、GNOMEメニューバーの電源アイコン付近をクリックし、「admin」をクリックすると表示される「ログアウト」をクリックします。  
   ![ログアウトする](image/logout.png){width=70%}  
1. メールの送受信テスト用に作成したユーザーアカウントuseraでログインします。パスワードはuserapassです。正しく設定されていない場合には、再度adminでログインし、rootユーザになってpasswdコマンドで設定し直して下さい。このパスワードがメールの送受信にも使用されます。
1. 「アプリケーション」メニューから「インターネット」→「Thunderbird」を選択します。  
   ![Thunderbirdを起動する](image/thunderbird-menu.png){width=70%}  
1. Thunderbirdが起動すると「Thunderbirdのご利用ありがとうございます」の画面が表示されます。  
   ![Thunderbirdを起動する](image/thunderbird1.png){width=70%}  
1. 「メールアカウントを設定する」をクリックすると、「メールアカウント設定」ダイアログが表示されます。
   ![メールアカウント画面](image/mail-account.png){width=70%}  
1. 以下のように設定して「続ける」をクリックします。  
   
   : アカウント設定の設定値 {#tbl:アカウント設定}  
   
   |設定項目                | 値           |
   |-----------------------|--------------|
   |あなたの名前		|UserA         |
   |メールアドレス		|usera@alpha.jp|
   |パスワード		|userapass     |
   |パスワードを記憶する	|チェックしておく     |  
    	
   すると、「アカウント設定をMozilla ISPデータベースから検索しています。」と表示されます。検索はしばらく時間がかかります。
1. 「アカウント設定が、一般的なサーバー名で検索したことにより見つかりました。」と表示されます。  
   
   ![メールアカウント画面](image/mail-account2.png){width=50%}  
   
   もし、アカウントの検索時「Thunderbirdはあなたのアカウント設定を見つけられませんでした。」のように表示された場合には、次のような設定になるように手動設定をし、「再テスト」ボタンをクリックします。  
   
   : メールアカウント設定の設定値 {#tbl:メールアカウント設定}  
   
   |カテゴリ       | 項目	     	| 設定値         |
   |------------|---------------|---------------|
   |ユーザ名	             	||usera         |
   |受信サーバー  |サーバーのホスト名	|mail.alpha.jp  |
               ||プロトコル	|IMAP           |
               ||受信ポート番号	|143            |
               ||SSL		|接続の保護なし    |
               ||認証方式	|通常のパスワード   |
   |送信サーバー  |サーバーのホスト名	|mail.alpha.jp  |
               ||送信ポート番号	|25             |
               ||SSL	        |接続の保護なし    |
               ||認証方式	|通常のパスワード   |
   		
1. 「完了」をクリックします。すると、接続が暗号化されないため、警告が表示されます。  
   
   ![警告画面](image/thunderbird-warn.png){width=70%}

   「接続する上での危険性を理解しました」をチェックし、「完了」ボタンをクリックします。  

### メールの送信
メールを送信するには、「作成」ボタンをクリックしてメール作成ウインドウを呼び出します。

1. 宛先に自分のメールアドレス（usera@alpha.jp）を指定して、メールを作成、送信してみます。
1. 「受信」ボタンをクリックして、メールが受信できることを確認します。
1. 宛先に他の受講生のメールアドレス（userb@beta.jp）を指定して、メールを作成、送信してみます。
1. 相手がメールを受信できたこと、相手からのメールを受信できることを確認します。

### 起動時のスタートページの設定
インターネットに接続できない環境で演習をしている場合には、起動時に「サーバーが見つかりませんでした」のエラーが表示されることがあります。エラーが表示されないようにするには、以下の手順で設定を修正します。

1.三本線のボタンからメニューを表示し、「設定」→「設定」を選択します。
	
   ![メニューから設定を選ぶ](image/thunderbird-setup.png){width=70%}
   
1. 「Thunderbird スタートページ」の「起動時にメッセージペインにスタートページを表示する」のチェックを外して、「閉じる」をクリックします。

   ![メニューから設定を選ぶ](image/thunderbird-setup-edit.png){width=70%}	 

## まとめ
本章では、電子メールに関する学習を行いました。また、実際にメールサーバーを設定し、mailコマンドやThunderbirdを利用してメールの送受信の確認を行いました。
メールサーバーの設定は、メールサーバーが正しく設定され起動していたとしても、DNSサーバーが正しく動いていなければ利用できないなどの理由から難しかったと思います。設定ファイルの記述に問題がないのに、メールがどうしても送れない、受信できない場合は、まずDNSが正しく動いているか、hostコマンドやdigコマンドを実行して確認します。また、ログ（/var/log/mail）を見て、エラーが出ていないか確認することも大切です。

