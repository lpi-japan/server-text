# メールサーバーの構築
メールのやり取りが行えるよう、メールサーバーを設定します。まずはPostfixを使って、メールサーバー同士でメールのやり取りが行えるように設定します。さらにPOP/IMAPサーバーとメールクライアントを使って、より実践的なメール環境を構築します。

## 用語集
### メールサーバー {.unlisted .unnumbered}
電子メールのサービスを行います。クライアントよりメールを受け取り、バケツリレーの方式で相手先のメールサーバーまで送ります。また、受信用のメールサーバーでは、送ってきたメールを蓄積しておいて、クライアントの要求に応じて応答します。

### MTA（Mail Transfer Agent） {.unlisted .unnumbered}
メールの転送を行うプログラムです。SendmailやPostfixなどが代表例です。

### SMTP（Simple Mail Transfer Protocol） {.unlisted .unnumbered}
電子メールの送信、転送のときに利用されるプロトコルのことです。

### SMTP認証 {.unlisted .unnumbered}
SMTPでのメールを送信する際に認証を行う機構です。迷惑メール対策としてのメール中継の制限を、この認証機能で許可する、といった利用方法があります。

### Postfix {.unlisted .unnumbered}
MTAとして動作するサーバープログラムです。LinuxやUnixのシステムで古くから使われてきたSendmailよりもセキュリティが高く、高速に動作すると言われています。

### POP3（Post Office Protocol version3） {.unlisted .unnumbered}
クライアントが電子メールを取り寄せるときに利用されるプロトコルです。シンプルな設計で、IMAP4と比べて機能が少ないです。

### IMAP4（Internet Message Access Protocol 4） {.unlisted .unnumbered}
クライアントが電子メールを取り寄せるときに利用されるプロトコルです。メールのフォルダ機能サポート等、多機能です。

### Dovecot {.unlisted .unnumbered}
POP3やIMAP4のサーバー機能を提供するプログラムです。

### Thunderbird {.unlisted .unnumbered}
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

### MTA（Mail Transfer Agent）
メールクライアントから送信されたメールは、送信用メールサーバーから宛先の受信用メールサーバーに転送されます。このメールの転送を行うプログラムをMTAと呼びます。本教科書ではPostfixというMTAを利用します。他に有名なMTAとしてSendmailがあります。

### MDA（Mail Delivery Agent）
受信用メールサーバーが受信したメールを宛先アドレスのメールボックスに配送するプログラムをMDAと呼びます。MTAであるPostfixがMDAの機能も受け持ちます。他にMDAとしてProcmailがあります。

### MUA（Mail User Agent）
メールの利用者が、メールの送信や受信を行うプログラムをMUAと呼びます。本教科書ではThunderbirdを利用します。WebメールもMUAの一種となります。

### SMTP（Simple Mail Transfer Protocol）の拡張
メールクライアントからのメール送信や、メールサーバー間のメールの転送は、SMTPというプロトコルでやり取りされています。SMTPはかなり昔に設計、定義されたプロトコルのため、認証やアクセス制限などが無く、勝手にメールサーバーを利用されて迷惑メールを送られてしまう問題がありました。このような問題を解決するためにESMTP（拡張SMTP）が定義されました。SMTPと呼ぶ場合、このESMTPで定義された機能も含んでいることがあります。

#### SMTP認証（SMTP Authentication）とリレー
SMTP認証はESMTPの機能のうちの1つです。通常のSMTPには認証機能が無いため、送信元のIPアドレスを制限するなど適切に設定されていないと迷惑メール送信の踏み台とされてしまう問題があります。SMTP認証は、メールの送信時に認証を行い、認証が行われた場合のみメールの送信を受け付けます。受け付けたメールを宛先の受信用メールサーバーに転送することをリレーと呼びます。

## メールの受信
送信されたメールが宛先のメールボックスに配送されると、受信者はメールを受信して読むことができます。メールの受信に関係するいくつかの事項について解説します。

### メールの配送
受信用メールサーバーが送信用メールサーバーからメールを受け取り、宛先アドレスのメールボックスにメールを届けることを配送と呼びます。メールボックスが無い場合、宛先不明として送信用メールサーバーにエラーを返します。メールの配送を行うソフトウェアをMDA（Mail Delivery Agent）と呼びます。

#### ローカル配送
送信側と受信側が同じメールサーバーを使用している場合、メールは外部のメールサーバーに転送する必要がなく、すぐに宛先アドレスのメールボックスに配送されます。これをローカル配送と呼びます。

### POP3（Post Office Protocol version 3）
POP3は電子メールを受信するときに利用するプロトコルです。非常にシンプルなプロトコルで、ユーザー名、パスワードを利用して接続し、メールの内容を受信します。

### IMAP4
IMAP4もPOP3同様、メールを受信するときに利用するプロトコルです。IMAP4はPOP3に比べて機能が豊富で、大きな特徴としてフォルダ機能をサポートしていることが挙げられます。メールをIMAPサーバーに残しておくことができるので、メールクライアントとWebメールを併用したりすることもできますが、その分だけメールサーバーのストレージを消費するので容量管理が必要になります。

## メールサーバーの構築
メールサーバーの構築は、送信用メールサーバーと受信用メールサーバーの2台を構築します。それぞれのサーバーを以下のように設定します。

- 1台のマシンで、メールサーバーとメールクライアントの1台2役とします
- MTAとしてPostfixをインストールし、送信用メールサーバーおよび受信用メールサーバーとして設定します
- IMAP4サーバーとしてDovecotをインストールし、設定します
- それぞれのメールサーバーにメールアカウントを作成します
- メールクライアントとしてThunderbirdをインストールし、サーバー自身を送受信用サーバーとして設定します

通常、メールサーバーとメールクライアントは別々のマシンを用意し、その間をSMTPやPOP3、IMAP4などで接続しますが、演習では同じマシンで行います。

構築は、Postfixの設定とmailコマンドによるメールの送受信、DovecotとThunderbirdの設定とメールの送受信の2段階に分けて行います。

### mailコマンドを利用したメールの送受信
MTAの設定ができたら、mailコマンドを使ってメールのやり取りを行います。メールクライアントの設定を必要としないので、MTAが正しく設定されていることを確認するのに適しています。

### Thunderbirdを利用したメールの送受信
Thunderbirdをメールクライアントとして設定し、SMTP認証によるメール送信や、DovecotによるIMAPサーバーからのメール受信を行います。

## Postfixのインストール
Postfixをdnfコマンドでインストールをします。また、SMTP認証で使用するCyrus-SASL（cyrus-saslパッケージ）とmailコマンドが含まれているs-nailパッケージも一緒にインストールしておきます。

```
$ sudo dnf install postfix cyrus-sasl s-nail
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
```

### インターネット接続できない環境でのインストール
インターネット接続できない環境での実習の場合、OSインストール時にメールサーバーを追加でインストールしていますが、s-nailパッケージはインストールされていません。

本章の最後でISOイメージからインストールする方法を解説しているので、その手順に従ってs-nailとthunderbirdをインストールしてください。

## Postfixの設定ファイル main.cfの設定
Postfixの設定ファイルは、/etc/postfix/main.cfです。次のパラメータを探して設定します。

パラメータによっては、デフォルト値が設定されているので、その場合には書き換えます。コメントアウトされた形で記述されている場合には、コメントアウトを外して設定を有効にした上で値を記述します。

smtpd_sasl_auth_enableとsmtpd_recipient_restrictionsは、main.cfに記述されていないので、ファイルの最後に追加しておきます。

host1とhost2に、それぞれ以下のように設定します。

host1の設定
| 項目 | 設定値 |
|------------|---------------|
| myhostname | mail.example1.jp |
| mydomain | example1.jp |
| inet_interfaces | localhost, 192.168.56.101 |
| mydestination | $mydomain |
| mynetworks | 192.168.56.101 |
| smtpd_sasl_auth_enable | yes |
| smtpd_recipient_restrictions | permit_mynetworks, permit_sasl_authenticated, reject_unauth_destinaition |

host2の設定
| 項目 | 設定値 |
|------------|---------------|
| myhostname | mail.example2.jp |
| mydomain | example2.jp |
| inet_interfaces | localhost, 192.168.56.102 |
| mydestination | $mydomain |
| mynetworks | 192.168.56.102 |
| smtpd_sasl_auth_enable | yes |
| smtpd_recipient_restrictions | permit_mynetworks, permit_sasl_authenticated, reject_unauth_destinaition |

### myhostname
メールサーバーのホスト名を設定します。

host1の設定
```
myhostname = mail.example1.jp
```

host2の設定
```
myhostname = mail.example2.jp
```

### mydomain
メールサーバーのドメイン名を設定します。

host1の設定
```
mydomain = example1.jp
```

host2の設定
```
mydomain = example2.jp
```

### inet_interfaces
メールを受け付けるネットワークインターフェースのIPアドレスを設定します。localhostの記述を忘れると、自分自身からのメールを受け付けなくなるので

host1の設定
```
inet_interfaces = localhost, 192.168.56.101
```

host2の設定
```
inet_interfaces = localhost, 192.168.56.102
```

### mydestination
メールを受信するドメイン名を設定します。自分のドメイン名宛以外のメール転送は受け付けません。

host1とhost2共通の設定
```
mydestination = $mydomain
```

### mynetworks
信頼するクライアントのIPアドレスを設定します。このIPアドレスからのメール送信は、認証無しでリレーして宛先の受信用メールサーバーに転送されます。

host1の設定
```
mynetworks = 192.168.56.101
```

host2の設定
```
mynetworks = 192.168.56.101
```

### smtpd_sasl_auth_enable
SMTP認証用のSASL認証連携を有効にします。

host1とhost2共通の設定
```
smtpd_sasl_auth_enable = yes
```

### smtpd_recipient_restrictions
SMTP認証でSASL認証されたクライアントからのメール送信を許可するように設定します。

host1とhost2共通の設定
```
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destinaition
```

これら2つの設定は後述するSMTP認証（SASL認証連携）に関係する設定ですが、先に設定しておきます。

## 書式のチェック
/etc/postfix/main.cfの修正ができたら、書式チェックを行っておきます。

```
$ sudo postfix check
```

書式が正しい場合には、何も表示されません。エラーが表示された場合には、エラー内容をよく見て修正します。

## Postfixの再起動
postfixサービスを再起動します。

```
$ sudo systemctl restart postfix.service
```

## Postfixの自動起動の設定
postfixサービスの自動起動を設定します。

```
$ sudo systemctl enable postfix.service
Created symlink /etc/systemd/system/multi-user.target.wants/postfix.service → /usr/lib/systemd/system/postfix.service.
```

自動起動の設定を確認します。

```
$ sudo systemctl is-enabled postfix.service
enabled
```

### Postfixの起動順の設定（任意）
上記systemctl enableコマンドでPostfixの自動起動を設定しても、システムを再起動するとPostfixが起動していないことがあります。これはシステム起動時のサービスの起動順の設定が正しくないためです。

具体的には、ネットワークサービスの起動完了を待たずにPostfixを起動しようとしているのが原因です。正しい動作をさせるためにはsystemdが参照している設定ファイルを修正する必要があります。

本教科書の実習では頻繁にシステム再起動を行うことはないので、起動していない場合にはその都度Postfixを起動すればよいですが、連続稼働させるシステムでPostfixを動作させる場合には、以下の修正を行ってください。

#### systemctl editコマンドで修正
systemctl editコマンドを使うと、対象となるサービスの設定ファイルを編集することができます。ただし、起動するエディタがnanoになるので、vimと使い勝手が若干異なる点に注意が必要です。

#### vimで設定ファイルを修正
vimで設定ファイルを直接開いて修正しても構いません。設定ファイルは/usr/lib/systemd/system/postfix.serviceです。

```
$ sudo vi /usr/lib/systemd/system/postfix.service
```

```
[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network-online.target ← network.targetをnetwork-online.targetに変更
Conflicts=sendmail.service exim.service
（略）
```

After=network.targetは、ネットワークサービスの起動の後にPostfixを起動しますが、ネットワークが使えるようになったことは確認しません。After=network-online.targetにすることで、ネットワークが使えるようになったことまで確認した後にPostfixを起動します。

変更が適用されたことを確認するため、システムを再起動し、Postfixが自動的に起動していることを確認してください。

## ファイアウォールの設定
Postfixでメールの受信ができるようにファイアウォールのサービス許可設定を行います。

```
$ sudo firewall-cmd --add-service=smtp --zone=public --permanent
$ sudo firewall-cmd --reload
$ sudo firewall-cmd --list-all
```

## SMTP認証（SASL認証連携）の設定
SMTP認証は、メール送信時に認証を行う仕組みです。Postfix自体は認証の機能を持っていませんので、SASL認証との連携を行います。SASL認証連携を行うには、Postfixへの設定とsaslauthdサービスの起動が必要です。

### Postfixの設定の確認
Postfixの設定ファイルであるmain.cfでSASL認証を有効にします。既に以下の2つのパラメータを追加で設定しています。

- smtpd_sasl_auth_enable
- smtpd_recipient_restrictions

SMTP認証の機能を有効にすると、Postfixはsaslauthdに認証を依頼してその結果を受け取ります。

### saslauthdサービスの起動
SMTP認証用のsaslauthdサービスを起動します。

```
$ sudo systemctl start saslauthd.service
```

saslauthdの自動起動設定も行っておきます。

```
$ sudo systemctl enable saslauthd.service
Created symlink from /etc/systemd/system/multi-user.target.wants/saslauthd.service to /usr/lib/systemd/system/saslauthd.service.
```

これでPostfixの設定は完了です。

## アカウントの作成
メールのやり取りを行うためのアカウントを作成します。アカウントはhost1とhost2の双方で行います。

### host1にuser1を作成
host1でuser1というアカウントを作成します。このアカウントはuser1@example1.jpというメールアドレスになります。

```
[admin@host1 ~]$ sudo useradd user1
[admin@host1 ~]$ sudo passwd user1
ユーザー user1 のパスワードを変更。
新しいパスワード: userpass	← 入力文字は非表示
新しいパスワードを再入力してください: userpass	← 入力文字は非表示
passwd: すべての認証トークンが正しく更新できました。
```

### host2にuser2を作成
host2でuser2というアカウントを作成します。このアカウントはuser2@example2.jpというメールアドレスになります。

```
[admin@host2 ~]$ sudo useradd user2
[admin@host2 ~]$ sudo passwd user2
ユーザー user2 のパスワードを変更。
新しいパスワード: userpass	← 入力文字は非表示
新しいパスワードを再入力してください: userpass	← 入力文字は非表示
passwd: すべての認証トークンが正しく更新できました。
```

## mailコマンドを使ったメール送受信のテスト
次にメールを送信します。メールの送受信は作成した一般ユーザーで行います。一般ユーザーで操作できるよう別の端末を起動し、suコマンドを使ってユーザーを切り替えます。メールの送信はmailコマンドを使用します。

### ログの確認用端末の設定
メールサーバーはバックグラウンドで動作するため、どのように動いているのか確認するためにはログを参照する必要があります。

tailコマンドに-fオプションを付けて実行すると、ログが書き込まれる毎に再読み込みされて最新のログを閲覧できます。

1. 「端末」を起動します。
1. tailコマンドを実行して/var/log/maillogを表示します。

```
$ sudo tail -f /var/log/maillog
```

### メール送受信用端末の起動とユーザー切り替え
メール送受信用の端末を起動し、suコマンドでユーザーの切り替えを行います。ユーザーを完全に切り替えるために「su - ユーザー名」と「-」（ハイフン）を付けて実行してください。

1. 「端末」を起動します。
2. suコマンドでユーザーを切り替えます。

#### host1でuser1に切り替え
host1はuser1で操作を行います。

```
[admin@host1 ~]$ sudo su - user1
[user1@host1 ~]$ id
uid=1003(user1) gid=1001(user1) groups=1001(user1) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

#### host2でuser2に切り替え
host2はuser2で操作を行います。

```
[admin@host1 ~]$ sudo su - user2
[user2@host2 ~]$ id
uid=1001(user2) gid=1001(user2) groups=1001(user2) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

### user1@example1.jpからuser2@example2.jpへメール送信
mailコマンドを使って、host1のuser1からuser2@example2.jpへメールを送信します。

```
[user1@host1 ~]$ mail user2@example2.jp	← mailコマンドの引数に宛先のアドレスを指定
Subject: Test mail from user1		← Subjectを入力
This is Test Mail from user1		← メッセージ本文を入力
^D ← メッセージ本文の入力が終わったらCtrl+dを入力
-------
(Preliminary) Envelope contains:
To: user2@example2.jp
Subject: Test mail from user1
Send this message [yes/no, empty: recompose]? yes.	← yesと入力するとメールが送信される
```

### user2のメール着信確認
mailコマンドを使って、host2.example2.jpのuser2にメールが届いているかを確認します。

```
[user2@host2 ~]$ mail
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/user2": 1 message 1 new
>N  1 user1@mail.example1.jp   Tue Feb 19 13:38  21/751   "Test mail from user1"
& 1	← 1を入力
Message  1:
From user1@mail.example1.jp  Tue Feb 19 13:38:31 2019
Return-Path: <user1@mail.example1.jp>
X-Original-To: user2@example2.jp
Delivered-To: user2@example2.jp
Date: Tue, 19 Feb 2019 13:38:31 +0900
To: user2@example2.jp
Subject: Test mail from user1
User-Agent: Heirloom mailx 12.5 7/5/10
Content-Type: text/plain; charset=us-ascii
From: user1@mail.example1.jp
Status: R

This is Test Mail from user1

& q	← qを入力
Held 1 message in /var/spool/mail/user2
```

このように、host1.example1.jpからhost2.example2.jpにメールが送られていることがわかります。

反対にuser2@example2.jpからuser1@example1.jpへのメールも送信できることを確認してみましょう。

## メールクライアントソフトでのメールの送受信
通常のメールサーバーの運用では、メールの利用者はメールクライアントを使用してメールの送受信を行います。送信はSMTP、受信はIMAP4やPOP3をプロトコルとして使用します。

IMAPサーバーを利用してメールを受信できるよう、IMAPサーバーであるDevecotと、メールクライアントとしてThunderbirdをインストールして、メールを送受信してみます。

## Dovecotのインストール
まずはIMAPサーバーであるDovecotをインストールします。

```
$ sudo dnf install dovecot
```

## Dovecotの設定
次に、Dovecotの設定を行います。

設定ファイルは/etc/dovecot/dovecot.confと/etc/dovecot/conf.dディレクトリ以下に分かれています。

### /etc/dovecot/dovecot.conf
全体的な設定ファイルです。デフォルトの設定がコメントアウトで記述されています。特に変更は必要ありません。

```
$ sudo vi /etc/dovecot/dovecot.conf
（略）
# Protocols we want to be serving.
#protocols = imap pop3 lmtp submission	← IMAP/POP3/LMTP/SMTP submissionが使用可能

# A comma separated list of IPs or hosts where to listen in for connections.
# "*" listens in all IPv4 interfaces, "::" listens in all IPv6 interfaces.
# If you want to specify non-default ports or anything more complex,
# edit conf.d/master.conf.
#listen = *, ::	← ホストのすべてのIPアドレスで接続を受け付ける
```

### /etc/dovecot/conf.d/10-mail.conf
メールボックスの位置などを設定するファイルです。

今回はmbox形式のメールボックスを指定します。また、メールボックスへのアクセス権限を設定します。

```
$ sudo vi /etc/dovecot/conf.d/10-mail.conf
```

```
（略）
#   mail_location = maildir:~/Maildir
#   mail_location = mbox:~/mail:INBOX=/var/mail/%u
#   mail_location = mbox:/var/mail/%d/%1n/%n:INDEX=/var/indexes/%d/%1n/%n
#
# <doc/wiki/MailLocation.txt>
#
mail_location = mbox:~/mail:INBOX=/var/mail/%u	← 上にある例を参考に修正

（略）

# Group to enable temporarily for privileged operations. Currently this is
# used only with INBOX when either its initial creation or dotlocking fails.
# Typically this is set to "mail" to give access to /var/mail.
#mail_privileged_group =
mail_privileged_group = mail ← 権限が必要な動作はmailグループとして行う

# Grant access to these supplementary groups for mail processes. Typically
# these are used to set up access to shared mailboxes. Note that it may be
# dangerous to set these if users can create symlinks (e.g. if "mail" group is
# set here, ln -s /var/mail ~/mail/var could allow a user to delete others'
# mailboxes, or ln -s /secret/shared/box ~/mail/mybox would allow reading it).
#mail_access_groups =
mail_access_groups = mail ← mailグループにアクセス権限を与える
```

### /etc/dovecot/conf.d/10-auth.conf
認証を設定するファイルです。

今回は暗号化していない平文での認証を許可し、Linuxのログイン情報を認証に利用できるように設定します。

```
$ sudo vi /etc/dovecot/conf.d/10-auth.conf
```

```
##
## Authentication processes
##

# Disable LOGIN command and all other plaintext authentications unless
# SSL/TLS is used (LOGINDISABLED capability). Note that if the remote IP
# matches the local IP (ie. you're connecting from the same computer), the
# connection is considered secure and plaintext authentication is allowed.
# See also ssl=required setting.
#disable_plaintext_auth = yes
disable_plaintext_auth = no	← noに変更
```

### /etc/dovecot/conf.d/10-ssl.conf
SSL/TLSを設定するファイルです。

今回はSSL/TLS暗号化をしませんので、SSLの利用を停止しておきます。

```
$ sudo vi /etc/dovecot/conf.d/10-ssl.conf
```

```
##
## SSL settings
##

# SSL/TLS support: yes, no, required. <doc/wiki/SSL.txt>
# disable plain pop3 and imap, allowed are only pop3+TLS, pop3s, imap+TLS and imaps
# plain imap and pop3 are still allowed for local connections
ssl = no	← requiredをnoに変更
```

## ファイアウォールの設定
Dovecotの起動の前に、IMAP4でメールの受信ができるようにファイアウォールのサービス許可設定を行います。

```
$ sudo firewall-cmd --add-service=imap --zone=public --permanent
$ sudo firewall-cmd --reload
$ sudo firewall-cmd --list-all
```

## Dovecotの起動
dovecotサービスを起動します。

```
$ sudo systemctl start dovecot
```

自動起動設定も行っておきます。

```
$ sudo systemctl enable dovecot
Created symlink from /etc/systemd/system/multi-user.target.wants/dovecot.service to /usr/lib/systemd/system/dovecot.service.
```

## Thunderbirdのインストール
メールクライアントとしてThunderbirdをインストールします。

```
$ sudo dnf install thunderbird
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
```

## Thunderbirdの起動
次にThunderbirdの設定を行います。

1. その他のユーザーでログインしている場合にはログアウトします。
1. メールの送受信テスト用に作成したユーザーアカウントuser1でログインします。パスワードはuserpassです。正しく設定されていない場合には、再度初期ユーザーでログインし、rootユーザになってpasswdコマンドで設定し直して下さい。このパスワードがThunderbirdの設定にも使用されます。
1. Thunderbirdを起動します。画面左上にある「アクティビティ」をクリックし、画面下に表示されるアイコンドックから一番右にある「アプリケーションを表示する」をクリックします。表示されるアプリケーションアイコンから「Thunderbird」をクリックします。
1. Thunderbirdが起動すると別途Webブラウザが開いてThunderbirdのWebページが表示されますが、Webブラウザごと閉じて構いません。
1. Thunderbirdのアプリケーションウインドウを表示し、「既存のメールアドレスのセットアップ」タブが表示されていることを確認します。

1. 各設定項目の値を以下のように入力します。

   |設定項目                | 値           |
   |-----------------------|--------------|
   |あなたの名前		|User1         |
   |メールアドレス		|user1@example1.jp|
   |パスワード		|userpass     |
   |パスワードを記憶する	|チェックしておく     |  

1. 「手動設定」をクリックします。
1. 「受信サーバー」と「送信サーバー」が表示されるので、各設定項目を以下のように入力します。

| 項目 | 設定値 |
|------------|---------------|
|プロトコル	|IMAP |
| ホスト名 | mail.example1.jp |
| ポート番号 | 143 |
| 接続の保護 | なし |
| 認証方式 | 通常のパスワード認証 |
|ユーザ名 | user1 |

| 項目 | 設定値 |
|------------|---------------|
|プロトコル	|IMAP |
| ホスト名 | mail.example1.jp |
| ポート番号 | 25 |
| 接続の保護 | なし |
| 認証方式 | 通常のパスワード認証 |
|ユーザ名 | user1 |

1. 「完了」ボタンをクリックします。
1. 「警告！」ダイアログが表示されます。左下の「接続する上での危険性を理解しました」をチェックし、「確認」ボタンをクリックします。
1. 「リンクしたサービスへの接続」の「完了」ボタンをクリックします。

## メールの送信
メールを送信するには、「作成」ボタンをクリックしてメール作成ウインドウを呼び出します。

### 自分宛のメール送信
1. 宛先に自分のメールアドレス（user1@example1.jp）を指定して、メールを作成、送信してみます。
1. 「受信」ボタンをクリックして、メールが受信できることを確認します。

### 別サーバー宛のメール送信
1. 宛先に他の受講生のメールアドレス（user2@example2.jp）を指定して、メールを作成、送信してみます。
1. 相手がメールを受信できたこと、相手からのメールを受信できることを確認します。

## まとめ
本章では、電子メールに関する学習を行いました。また、実際にメールサーバーを設定し、mailコマンドやThunderbirdを利用してメールの送受信の確認を行いました。

メールサーバーの設定は、メールサーバーが正しく設定され起動していたとしても、DNSサーバーが正しく動いていなければ利用できないなどの理由から難しかったと思います。設定ファイルの記述に問題がないのに、メールがどうしても送れない、受信できない場合は、まずDNSが正しく動いているかdigコマンドを実行して確認します。また、ログ（/var/log/mail）を見て、エラーが出ていないか確認することも大切です。

## ISOイメージからのパッケージのインストール
dnfコマンドはインターネット上にあるパッケージリポジトリからダウンロードしてインストールを行います。インターネット接続できない環境でパッケージをインストールするには、ISOイメージに入っているRPMパッケージからインストールを行います。

1. 仮想マシンにadminユーザーでログインします
1. 仮想マシンの仮想光学ドライブにISOイメージを読み込ませます
1. ISOイメージが自動マウントされます

### ISOイメージのマウントポイントの確認
ISOイメージが自動マウントされたマウントポイント（ディレクトリ）を確認します。

マウントポイントはmountコマンドで確認できます。マウントポイントが多数あるため、grepコマンドで絞り込みます。

```
$ mount | grep dvd
/dev/sr0 on /run/media/admin/AlmaLinux-9-3-aarch64-dvd type iso9660 (ro,nosuid,nodev,relatime,nojoliet,check=s,map=n,blocksize=2048,uid=1000,gid=1000,dmode=500,fmode=400,uhelper=udisks2)
```

ISOイメージはISO9660ファイル形式として「/run/media/ユーザー名」以下にマウントされていることが分かります。

ISOイメージの中身を確認してみます。

```
$ ls /run/media/admin/AlmaLinux-9-3-aarch64-dvd/
AppStream  EULA                     TRANS.TBL         images
BaseOS     LICENSE                  boot.catalog      media.repo
EFI        RPM-GPG-KEY-AlmaLinux-9  extra_files.json
```

### パッケージのインストール
マウントされたISOイメージからパッケージをインストールします。

OSインストール時にインストールできなかったs-nailとthunderbirdをインストールします。これらはAppStremディレクトリ内に保存されています。

```
$ cd /run/media/admin/AlmaLinux-9-3-aarch64-dvd/AppStream/Packages/
$ ls -l s-nail-14.9.22-6.el9.x86_64.rpm
-r--r--r--. 5 admin admin 635625  3月 10  2022 s-nail-14.9.22-6.el9.x86_64.rpm
$ ls -l thunderbird-115.4.1-1.el9_2.alma.x86_64.rpm
-r--r--r--. 5 admin admin 111843172 11月  3 00:37 thunderbird-115.4.1-1.el9_2.alma.x86_64.rpm
```

パッケージのRPMファイルが確認できたら、dnfコマンドの引数として指定してインストールします。

```
$ pwd
/run/media/admin/AlmaLinux-9-3-x86_64-dvd/AppStream/Packages
$ sudo dnf install ./s-nail-14.9.22-6.el9.x86_64.rpm
$ sudo dnf install ./thunderbird-115.4.1-1.el9_2.alma.x86_64.rpm
```

\pagebreak
