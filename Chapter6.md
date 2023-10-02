# とりあえずVer3の原稿をはめこみ

# メールサーバーの構築
メールのやり取りが行えるよう、メールサーバーを設定します。まずはPostfixを使って、メールサーバー同士でメールのやり取りが行えるように設定します。さらにPOP/IMAPサーバーとメールクライアントを使って、より実践的なメール環境を構築します。

## 用語集
#### メールサーバー
電子メールのサービスを行います。クライアントよりメールを受け取り、バケツリレーの方式で相手先のメールサーバーまで送ります。また、受信用のメールサーバーでは、送ってきたメールを蓄積しておいて、クライアントの要求に応じて応答します。

#### MTA（Mail Transfer Agent）
メールの転送を行うプログラムです。SendmailやPostfixなどが代表例です。

#### SMTP(Simple Mail Transfer Protocol)
電子メールの送信、転送のときに利用されるプロトコルのことです。

#### SMTP認証
SMTPでのメールを送信する際に認証を行う機構です。迷惑メール対策としてのメール中継の制限を、この認証機能で許可する、といった利用方法があります。

#### POP3(Post Office Protocol version3)
クライアントが電子メールを取り寄せるときに利用されるプロトコルです。シンプルな設計で、IMAP4と比べて機能が少ないです。

#### IMAP4（Internet Message Access Protocol 4）
クライアントが電子メールを取り寄せるときに利用されるプロトコルです。メールのフォルダ機能サポート等、多機能です。

#### Postfix
MTAとして動作するサーバープログラムです。LinuxやUnixのシステムで古くから使われてきたSendmailよりもセキュリティが高く、高速に動作すると言われています。

#### Dovecot
POP3やIMAP4のサーバー機能を提供するプログラムです。

#### Thunderbird
Mozilla Projectが配布している、高機能なメールクライアントソフトウェアです。

## メールサーバー実習の説明
メールサーバーの設定と動作確認を行います。メールは、インターネットにおいて、Webに並んで重要なサービスです。メールサーバーを設定し、実際にメールをやり取りすることで、動作原理を確認してみましょう。

### メールとメールサーバー
メールは、メールサーバーを介してやり取りが行われます。

メールサーバーがメールを受け取ると、宛先のメールアドレスを担当しているメールサーバーまでバケツリレー方式で送られます。これは、Thunderbird/Outlookのようなメールクライアントソフトからのメールでも、Gmail/Hotmail/YahooメールのようなWebメールからのメールでも、動作原理は同じです。

#### MTA(Mail Transfer Agent)
メールがバケツリレー方式で運ばれることは、前述の通りです。このバケツリレーをするプログラムのことをMTAといいます。本教科書ではPostfixというMTAを利用します。他に有名なMTAとしてPostfixなどがあります。

#### SMTP(Simple Mail Transfer Protocol)
メールサーバー間は、SMTPというプロトコルでやり取りされています。SMTPはかなり昔に設計、定義されたプロトコルのため、認証やアクセス制限などが無く、勝手にメールサーバーを利用されて迷惑メールを送られてしまうなどの問題がありました。そこでこのような問題を解決するために、ESMTP（拡張SMTP）が定義されました。SMTPと呼ぶ場合、このESMTPで定義された機能も含んでいることがあります。

#### SMTP認証(SMTP Authentication)
正規のSMTP接続では、メールの中継を行います。ところが前述の通り、SMTPには認証機能が無いため、多くの場合、特定の場所以外からの中継を拒否します。SMTP認証は、SMTP上に認証(Authentication)機能を加え、その中継要求が正規のものか不正なものかを判断します。
SMTP認証はESMTPの機能のうちの1つです。

#### POP3(Post Office Protocol version 3)
電子メールは、送受信でプロトコルが異なります。POP3は電子メールを受信するときに利用するプロトコルです。非常にシンプルなプロトコルで、ユーザー名、パスワードを利用して接続し、メールの内容を受信します。

#### IMAP4
IMAP4もPOP3同様、メールを受信するときに利用するプロトコルです。IMAP4はPOP3に比べて機能が豊富で、大きな特徴としてフォルダ機能をサポートしていることが挙げられます。そのため、メール管理が非常に楽になります。

### メールのやり取り
インターネット上で、沢山の人が電子メールを利用しています。電子メールは以下の手順でやり取りされます。

1. 送信側のメールクライアントからメールを送信します
2. メールは送信用メールサーバーを経由して相手のメールサーバーに配信されます
3. 相手の受信側のメールサーバーにメールが届きます
4. 受信側のメールクライアントで受信側のメールサーバーに接続します
5. メールが受信され、メールを見ることができます

前述の構成で実習を行う場合、サーバー、クライアントをそれぞれ2台ずつ、計4台必要になります。本実習では二人一組のペアを組んで2台で実習を行うため、以下のような構成を取ります。

- 1台のマシンで、メールサーバーとメールクライアントの1台2役とします
- 自分のメールサーバーに、自分のメールアカウントを作成します
- 相手のメールサーバーに、相手のメールアカウントが作成されます
- 自分のメールクライアントは、自分のメールサーバーを送受信用サーバーとして設定します

ポイントは、自分のマシンは1台ですが、メールサーバーとメールクライアントの1台2役であることです。

## 実習の進め方
本章では、次の手順で実習を行います。実習でのメールの送受信は、大きく分けて2回あります。

#### mailコマンドを利用する
端末でmailコマンドを使って相手にメール送信します。以下の手順に従ってください。

1. 二人一組になります。それぞれhost1.alpha.jpを利用するAさん(usera@alpha.jp)と、host2.beta.jpを利用するBさん(userb@beta.jp)とします。
1. Postfixの設定ファイルを作成し、Postfixを再起動します。
1. 送受信テスト用の自分のアカウント（usera@alpha.jp、userb@beta.jp）を、それぞれのホストに作成します。
1. Aさんがhost1.alpha.jpからmailコマンドを使って、Bさんにメールを送ります。
1. Bさんはmailコマンドを使って、到着を確認します。
1. 逆にBさんからAさんにメールを送り、確認します。

![実習の流れ](image/9mail1.jpg){width=70%}

\pagebreak

#### メールクライアントソフトを利用する
メールクライアントを使って相手にメール送信します。本実習ではThunderbirdを使います。以下の手順に従ってください。

1. POP/IMAPサーバーとしてDovecotの設定を行い、POP/IMAPサーバーを起動します。
1. メールクライアントとしてThunderbirdを設定します。
1. Aさんがhost1.alpha.jpからメールクライアントを使って、Bさんにメールを送ります。
1. Bさんはメールクライアントを使って、到着を確認します。
1. 逆にBさんからAさんにメールを送り、確認します。

![メールクライアントを使った実習の流れ](image/10mail2.jpg){width=70%}

### 実習後の注意点
設定したメールサーバーは、あくまで実習用にメールのやり取りをするために設定されています。ですが、セキュリティ等決して頑丈に設定してある訳ではないので、以下の点に留意します。

- 決してグローバル環境には接続しない。
- 実習後はメールサーバーを止める、もしくは本体自体を止める。LANの中に不正中継を探すマシンがあった場合、それに利用される可能性があるからです。

### 実習で使用するソフトウェアについて
#### Postfix
今回の実習では、MTAとしてPostfixを利用します。

#### mailコマンド
mailコマンドは、標準でインストールされている、メールを操作するコマンドです。mailコマンドには、メールを送る以外に、届いたメールを読む機能もあります。

本実習では、メールで送るときと届いたメールを読むときに利用します。

#### Dovecot
Dovecotは、POP3やIMAP4を機能させるサーバーのソフトウェアです。実習では、メールのクライアントソフトからIMAP4でメールを受信します。そのときにIMAP4のサーバーとして動作させます。
標準ではインストールされていないので、実習時にパッケージを追加し、設定ファイルを書き換えます。

#### Thunderbird
Mozilla Projectにより開発されている、フリーのメールクライアントソフトがこのThunderbirdです。Windows, Mac OS X, Linux等と、動作環境は多岐に渡っており、各国語版も用意されております。機能も必要十分な内容がそろっています。
本実習では、メールのクライアントソフトとしてThunderbirdを使って実習を行います。実際にThunderbirdをインストールしメールの送受信を行うことで、メール設定が正しいか確認を行います。

#### saslauthd
saslauthdは、SMTP認証の認証機構です。Postfixは設定ファイルで SMTP認証の機能を有効にできますが、Postfix自体は認証の機能を持っていません。設定ファイルでSMTP認証の機能を有効にすると、Postfixはsaslauthdに認証を依頼してその結果を受け取ります。

\pagebreak

### 実習環境
実習では、受講生二人一組で実習を行います。本章では、それを便宜的に「Aさん」「Bさん」と呼びます。特に明示がない場合は、両者とも作業を行います。どちらか片方の方が作業をするときは、「次はAさんの作業です」といったように、作業する方を明示します。

設定は、alpha.jpのマシン上で行うものとします。ホスト名は、各自読み替えてください。

![実習環境](image/11mail3.jpg){width=70%}

## Postfixのインストール
Postfixは、CentOS7では標準でインストールされています。念のため、rpmコマンドでパッケージがインストールされているかを確認します。

``` {language=Bash title="\{postfixパッケージの確認}"}
# rpm -q postfix
postfix-2.10.1-7.el7.x86_64
```

パッケージがインストールされていない場合は次の様に表示されます。

``` {language=Bash title="\{postfixパッケージの確認}"}
# rpm -q postfix
パッケージ postfix はインストールされていません。
```

### 必要なパッケージをインストール
postfixパッケージがインストールされていないときは、yumコマンドでインストールをします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。

``` {language=Bash title="\{postfixのインストール}"}
# yum install postfix
読み込んだプラグイン:fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: ftp-srv2.kddilabs.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: ftp-srv2.kddilabs.jp
依存性の解決をしています
--> トランザクションの確認を実行しています。
---> パッケージ postfix.x86_64 2:2.10.1-7.el7 を インストール
--> 依存性解決を終了しました。

依存性を解決しました

================================================================================
 Package          アーキテクチャー
                                  バージョン                リポジトリー   容量
================================================================================
インストール中:
 postfix          x86_64          2:2.10.1-7.el7            base          2.4 M

トランザクションの要約
================================================================================
インストール  1 パッケージ

総ダウンロード容量: 2.4 M
インストール容量: 12 M
Is this ok [y/d/N]: y	← 確認してyを入力
Downloading packages:
postfix-2.10.1-7.el7.x86_64.rpm                            | 2.4 MB   00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  インストール中          : 2:postfix-2.10.1-7.el7.x86_64                   1/1 
  検証中                  : 2:postfix-2.10.1-7.el7.x86_64                   1/1 

インストール:
  postfix.x86_64 2:2.10.1-7.el7                                                 

完了しました!

```

### main.cfの設定
Postfixの設定ファイルは、/etc/postfix/main.cfです。このファイルを確認してみると、次のような書式で設定されています。

``` {language=Bash title="\{/etc/postfix/main.cfの確認}"}
# cat /etc/postfix/main.cf
(略）
# LOCAL PATHNAME INFORMATION
#
# The queue_directory specifies the location of the Postfix queue.
# This is also the root directory of Postfix daemons that run chrooted.
# See the files in examples/chroot-setup for setting up Postfix chroot
# environments on different UNIX systems.
#
queue_directory = /var/spool/postfix

# The command_directory parameter specifies the location of all
# postXXX commands.
#
command_directory = /usr/sbin
（略）
# INTERNET HOST AND DOMAIN NAMES
#
# The myhostname parameter specifies the internet hostname of this
# mail system. The default is to use the fully-qualified domain name
# from gethostname(). $myhostname is used as a default value for many
# other configuration parameters.
#
#myhostname = host.domain.tld
#myhostname = virtual.domain.tld
```

queue_directoryやcommand_directoryは、設定パラメータです。Postfixでは、設定パラメータに値を指定することで、設定を行います。先頭が#で始まる行はコメント行です。myhostnameのように、設定例がコメントで記載されていますので、それを参考に設定を行います。また、設定パラメーターは、$myhostnameのようにして、変数のように参照して使うこともできます。

``` {language=Bash title="\{/etc/postfix/main.cfの編集}"}
# vi /etc/postfix/main.cf
```

次のパラメータを探して設定します。

: 設定が必要な項目 {#tbl:table}

|パラメータ         |内容						|設定例          |
|---------------------|--------------------------------------------|---------------|
|myhostname      | メールサーバーのホスト名		| mail.alpha.jp |
|mydomain        | メールサーバーのドメイン名		| alpha.jp      |
|inet_interfaces | メールを受け付けるIPアドレス	| localhost, 192.168.1.101 |
|mydestination   | 受信するメールドメイン		| alpha.jp      |
|mynetworks      | クライアントのIPまたはネットワーク	| 192.168.1.101 |
|smtpd_sasl_auth_enable | SMTP認証用のsaslを有効にします | yes        |
|smtpd_recipient_restrictions | SMTP認証を有効にします | permit_mynetworks, permit_sasl_authenticated, reject_unauth_destinaition |

mynetworksは、192.168.1.0/24のようにネットワークで指定することもできます。ですが、この実習では自分のIPアドレスだけで充分です。smtpd_sasl_auth_enableとsmtpd_recipient_restrictionsは、コメントが用意されていませんので、ファイルの最後に追加しておきます。

``` {title="\{SMTP認証の設定}"}
smtpd_sasl_auth_enable = yes
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination
```

### 書式のチェック

/etc/postfix/main.cfの修正ができたら、書式チェックを行っておきます。

``` {language=Bash title="\{main.cfの書式チェック}"}
# postfix check
```

書式が正しい場合には、何も表示されません。エラーが表示された場合には、エラー内容をよく見て修正します。

### ファイアウォールの設定
Postfixの再起動の前に、メールサーバーでメールの受信ができるようにファイアウォールのサービス許可設定を行います。

``` {language=Bash title="\{SMTPアクセスの許可}"}
# firewall-cmd --add-service=smtp
```

さらに、設定を保存しておきます。

``` {language=Bash title="\{Firewallルールの保存}"}
# firewall-cmd --runtime-to-permanent
```

### Postfixの再起動
postfixサービスを再起動します。

``` {language=Bash title="\{postfixサービスの再起動}"}
# systemctl restart postfix.service
```

postfixサービスの自動起動を確認します。

``` {language=Bash title="\{自動起動設定の確認}"}
# systemctl is-enabled postfix.service
enabled
```

### saslauthdサービスの起動
SMTP 認証用のsaslauthdサービスを起動します。

``` {language=Bash title="\{saslauthdの起動}"}
# systemctl start saslauthd.service
```

sasluauthdの自動起動設定も行っておきます。

``` {language=Bash title="\{saslauthdの自動起動設定}"}
# systemctl enable saslauthd.service
Created symlink from /etc/systemd/system/multi-user.target.wants/saslauthd.service to /usr/lib/systemd/system/saslauthd.service.
```

## アカウントの作成
それでは、実際にメールを送信する前に、宛先となるアカウントを作成します。

### host1.alpha.jpにuseraを作成
host1.alpha.jpでuseraというアカウントを作成します。このアカウントはusera@alpha.jpというメールアドレスになります。ユーザーは、mailグループに参加させるように設定します。

``` {language=Bash title="\{useraの作成}"}
[root@host1 postfix]# useradd -G mail usera
[root@host1 postfix]# passwd usera
ユーザー usera のパスワードを変更。
新しいパスワード: userapass	← 入力文字は非表示
新しいパスワードを再入力してください: userapass	← 入力文字は非表示
passwd: すべての認証トークンが正しく更新できました。
```

### host2.beta.jpにuserbを作成
host2.beta.jpでuserbというアカウントを作成します。このアカウントはuserb@beta.jpというメールアドレスになります。ユーザーは、mailグループに参加させるように設定します。

``` {language=Bash title="\{userbの作成}"}
[root@host2 postfix]# useradd -G mail userb
[root@host2 postfix]# passwd userb
ユーザー userb のパスワードを変更。
新しいパスワード: userbpass	← 入力文字は非表示
新しいパスワードを再入力してください: userbpass	← 入力文字は非表示
passwd: すべての認証トークンが正しく更新できました。
```

## メールの送受信
次にメールを送信します。メールの送受信は作成した一般ユーザーで行います。一般ユーザーで操作できるよう別の端末を起動し、suコマンドを使ってユーザーを切り替えます。メールの送信はmailコマンドを使用します。

### ログの確認用端末の設定

1. 「端末」を起動します
1. tailコマンドを実行して、/var/log/maillogを表示します。-fオプションを付けて実行すると、ログが書き込まれる毎に再読み込みされて最新のログを閲覧できます。

``` {language=Bash title="\{メールログの確認}"}
# tail -f /var/log/maillog
```

### メール送受信用端末の起動とユーザー切り替え
メール送受信用の端末を起動し、suコマンドでユーザーの切り替えを行います。

1. 「端末」を起動します
2. suコマンドでユーザーを切り替えます

#### host1.alpha.jpでuseraに切り替え

``` {language=Bash title="\{useraに切り替え}"}
[root@host1 ~]# su - usera
[usera@host1 ~]$  id
uid=1003(usera) gid=1003(usera) groups=1003(usera),12(mail) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

#### host2.beta.jpでuserbに切り替え

``` {language=Bash title="\{userbに切り替え}"}
# su - userb
[userb@host2 ~]$  id
uid=1001(userb) gid=1001(userb) groups=1001(userb),12(mail) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

### usera@alpha.jpからuserb@beta.jpへメール送信
mailコマンドを使って、host1.alpha.jpのuseraからuserb@beta.jpへメールを送信します。


``` {language=Bash title="\{メール送信}"}
[usera@host1 ~]$ mail userb@beta.jp	← mailコマンドの引数に宛先のアドレスを指定
Subject: Test mail from usera		← Subjectを入力
This is Test Mail from usera		← メッセージ本文を入力
.	← メッセージ本文の入力が終わったらピリオドを入力
EOT
```

### userbのメール着信確認
mailコマンドを使って、host2.beta.jpのuserbにメールが届いているかを確認します。

``` {language=Bash title="\{メールの確認}"}
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
```

このように、host1.alpha.jpからhost2.beta.jpにメールが送られていることがわかります。
以上で、Aさんによる実習が終了です。次に、今度はBさんがAさんに対してメールを送ってみましょう。

## メールクライアントソフトでのメールの送受信
通常のメールサーバーの運用では、メールの利用者はメールクライアントを使用してメールの送受信を行います。送信はSMTP、受信はIMAPやPOP3をプロトコルとして使用します。
IMAPサーバーを利用してメールを受信できるよう、IMAPサーバーであるDevecotと、メールクライアントとしてThunderbirdをインストールしてメールを送受信してみます。

![メールクライアントソフトでのメールの流れ](image/12mail4.jpg){width=70%}

### Dovecotパッケージの追加
それでは早速、必要なパッケージを追加して、クライアントでメールを送受信できるように設定してみましょう。まずはIMAPサーバーであるDovecotをインストールします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。

``` {language=Bash title="\{dovecotパッケージのインストール}"}
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
```

### Dovecotの設定

次に、IMAPサーバーであるDovecotの設定を行います。設定ファイルは/etc/dovecot/dovecot.confと/etc/dovecot/conf.dディレクトリ以下に分かれています。

##### /etc/dovecot/dovecot.conf
全体的な設定ファイルです。デフォルトの設定がコメントアウトで記述されています。特に変更は必要ありません。

``` {language=Bash title="\{dovecot.confを開く}"}
# vi /etc/dovecot/dovecot.conf
```

``` {title="\{/etc/dovecot/dovecot.confの確認}"}
（略）
# Protocols we want to be serving.
#protocols = imap pop3 lmtp	← IMAP/POP3/LMTPが使用可能

# A comma separated list of IPs or hosts where to listen in for connections.
# "*" listens in all IPv4 interfaces, "::" listens in all IPv6 interfaces.
# If you want to specify non-default ports or anything more complex,
# edit conf.d/master.conf.
#listen = *, ::	← ホストのすべてのIPアドレスで接続を受け付ける
```

#### /etc/dovecot/conf.d/10-mail.conf
メールボックスの位置などを設定するファイルです。今回はmbox形式のメールボックスを指定します。

``` {language=Bash title="\{10-mail.confを編集}"}
# vi /etc/dovecot/conf.d/10-mail.conf
```

``` {language=Bash title="\{/etc/dovecot/10-mail.conf}"}
（略）
#   mail_location = maildir:~/Maildir
#   mail_location = mbox:~/mail:INBOX=/var/mail/%u
#   mail_location = mbox:/var/mail/%d/%1n/%n:INDEX=/var/indexes/%d/%1n/%n
#
# <doc/wiki/MailLocation.txt>
#
mail_location = mbox:~/mail:INBOX=/var/mail/%u	←　修正
```

#### /etc/dovecot/conf.d/10-auth.conf
認証を設定するファイルです。今回は暗号化していない平文での認証を許可し、Linuxのログイン情報を認証に利用できるように設定します。

``` {language=Bash title="\{10-auth.confを編集}"}
# vi /etc/dovecot/conf.d/10-auth.conf
```

``` {language=Bash title="\{/etc/dovecot/10-auth.conf}"}
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
```

#### /etc/dovecot/conf.d/10-ssl.conf
SSL/TLSを設定するファイルです。今回はSSL/TLS暗号化をしませんので、SSLの利用を停止しておきます。

``` {title="\{10-ssl.confの編集}"}
# vi /etc/dovecot/conf.d/10-ssl.conf
```

``` {language=Bash title="\{/etc/dovecot/10-ssl.conf}"}
##
## SSL settings
##

# SSL/TLS support: yes, no, required. <doc/wiki/SSL.txt>
# disable plain pop3 and imap, allowed are only pop3+TLS, pop3s, imap+TLS and imaps
# plain imap and pop3 are still allowed for local connections
#ssl = required	←　コメントアウト
ssl = no	← 追加
```

### ファイアウォールの設定
Dovecotの起動の前に、POP3とIMAP4でメールの受信ができるようにファイアウォールのサービス許可設定を行います。

``` {language=Bash title="\{POP3, IMAP4アクセスの許可}"}
# firewall-cmd --add-service=pop3
# firewall-cmd --add-service=imap
```

さらに、設定を保存しておきます。

``` {language=Bash title="\{Firewallルールの保存}"}
# firewall-cmd --runtime-to-permanent
```

### Dovecotの再起動
dovecotサービスを再起動します。

``` {language=Bash title="\{dovecotサービスの起動}"}
# systemctl start dovecot.service
```

自動起動設定も行っておきます。

``` {language=Bash title="\{dovecotの自動起動設定}"}
# systemctl enable dovecot.service
Created symlink from /etc/systemd/system/multi-user.target.wants/dovecot.service to /usr/lib/systemd/system/dovecot.service.
```

### Thunderbirdのインストール
メールクライアントとしてThunderbirdをインストールします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。

```
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
```

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
   
   : アカウント設定の設定値 {#tbl:table}  
   
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
   
   : メールアカウント設定の設定値 {#tbl:table}  
   
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
インターネットに接続できない環境で実習をしている場合には、起動時に「サーバーが見つかりませんでした」のエラーが表示されることがあります。エラーが表示されないようにするには、以下の手順で設定を修正します。

1.三本線のボタンからメニューを表示し、「設定」→「設定」を選択します。
	
   ![メニューから設定を選ぶ](image/thunderbird-setup.png){width=70%}
   
1. 「Thunderbird スタートページ」の「起動時にメッセージペインにスタートページを表示する」のチェックを外して、「閉じる」をクリックします。

   ![メニューから設定を選ぶ](image/thunderbird-setup-edit.png){width=70%}	 

## まとめ
本章では、電子メールに関する学習を行いました。また、実際にメールサーバーを設定し、mailコマンドやThunderbirdを利用してメールの送受信の確認を行いました。
メールサーバーの設定は、メールサーバーが正しく設定され起動していたとしても、DNSサーバーが正しく動いていなければ利用できないなどの理由から難しかったと思います。設定ファイルの記述に問題がないのに、メールがどうしても送れない、受信できない場合は、まずDNSが正しく動いているか、hostコマンドやdigコマンドを実行して確認します。また、ログ（/var/log/mail）を見て、エラーが出ていないか確認することも大切です。

\pagebreak

