# Ver3の原稿をとりあえずはめこみ

# DNSサーバーの構築
ネットワークサービスを使うための土台となる名前解決のサービス(DNS)を設定します。自分のDNSサーバーを他のコンピューターから参照できるように設定をします。
DNSに問い合わせを行うコマンドに慣れ、ドメインを管理するBINDプログラムの設定ファイルを扱います。

## 用語集
#### ドメイン名とゾーン
組織に割り当てられてインターネットで使用する名前をドメイン名と呼びます。ドメイン名はICANN(Internet Corporation for Assigned Names and Numbers)により管理されています。DNSでドメイン名を設定するときは、ドメインではなく「ゾーン」と呼びます。

#### FQDN
ドメイン名表記で、一番右に「.」（ドット）でルートドメインまでを記述する方式をFQDNと呼びます。

#### DNS
DNS(Domain Name System)は、IPアドレスと対応するホスト名を登録しておき、プログラムからの問い合わせに応じてIPアドレスやホスト名を返答するシステムです。

#### ゾーン
DNSの名前空間の一部分を取り出したものをゾーンとよびます。ゾーンは、DNSを管理する単位として使われます。ゾーンには、ドメイン、サブドメイン、ホスト名などが含まれています。DNS名前空間はツリー構造で表されますが、ゾーンは特定のノード以下の一部または全部を含む部分です。

#### DNSキャッシュサーバー
プログラムからの名前問い合わせを代行して、様々なDNSサーバーへ名前問い合わせを行って結果を返却するサーバーです。調べた結果をキャッシュしておき、次回問い合わせ時にキャッシュの情報を返すことから、DNSキャッシュサーバーと呼ばれます。単純に、DNSサーバーと呼んだときには、DNSキャッシュサーバーのことを指します。

#### DNSコンテンツサーバー
委託されたゾーンのIPアドレスやホスト名を管理するDNSサーバーです。

#### リゾルバ
ドメイン名をもとにIPアドレス情報の検索をしたり、IPアドレスからドメイン情報の検索を行う、名前解決を行うプログラムのことです。

#### BIND
BIND(Berkeley Internet Name Domain)は、Linuxと組み合わせて多く使用されているDNSサーバーのソフトウェアです。DNSキャッシュサーバーとしても、DNSコンテンツサーバーとしても利用することができます。

#### unbound
unboundは、高機能で高速なDNSキャッシュサーバーです。攻撃に強いことから、最近はBINDに変わって利用されることが多くなっています。

#### グルーレコード
管理を委任しているゾーンについての問合せに対して、DNSサーバーが委任先のゾーンのDNSコンテンツサーバーのアドレスを返す際に、追加情報として必要となる委任先DNSコンテンツサーバーのAレコードをグルーレコードといいます。

#### Aレコード
名前に対してIPアドレスを指定するためのレコードです。

#### NS(Name Server)レコード
ゾーンの権威を持つDNSコンテンツサーバーを指定するためのレコードです。

#### MX(Mail eXchange)レコード
メールアドレスに利用するドメイン名を定義するためのレコードです。メールサーバーの障害にも対応するために、複数個のメールサーバーを記述でき、プリファレンス値の低いサーバーにメール配信が優先されます。

## DNSの仕組み
インターネットでのコンピューター同士の通信は、IP(Internet Protocol)を使って行われています。IP通信には相手のIPアドレスが必要ですが、インターネット上の大量のコンピューターをIPアドレスで識別するのは困難です。そこでドメイン名やホスト名という考え方が導入されました。ドメイン名は組織を表し、ホスト名はその組織が管理しているコンピューターです。表記するときは「ホスト名.ドメイン名」とドット区切りで表記しますが、両方を合わせてホスト名と呼ぶこともあります。

インターネットの研究が始まった当初はIPアドレスが割り当てられたコンピューターの数も数えるほどだったので、ホスト名とIPアドレスの対応関係はファイルに記述されて、定期的に更新されていました。この仕組みは今でも残っており、Linuxでは/etc/hostsがそのファイルです。しかし、インターネットが広まるに従って、ホストファイルでは管理しきれなくなってきました。そこで登場したのがDNS(Domain Name System)です。

*DNSコンテンツサーバー*は、ドメイン名を割り当てられた組織毎に用意します。DNSコンテンツサーバーの管理者は、そのドメインに所属しているホスト名と割り当てられたIPアドレスをDNSコンテンツサーバー登録します。ホストにアクセスしたい利用者は、そのホストが所属するドメインのDNSコンテンツサーバーに問い合わせを行うことで、IPアドレスを得ることができます。しかし、ユーザが、アクセスする毎にどのDNSコンテンツサーバーに問い合わせをするのかを調べることは面倒です。*DNSキャッシュサーバー*は、その調査を自動的に行ってくれます。また、調査結果を一定時間キャッシュし、毎回調べなくても良いようにしてくれます。

DNSの仕組みでは、ゾーンの管理権限がそれぞれのDNS管理者に権限委譲されているので、ホストファイルのような一元管理ではなく、分散管理となります。管理作業が分担されていて更新も頻繁に行われるので、リアルタイムにホスト名とIPアドレスの対応関係を調べることができる仕組みとなっています。

## ドメインの構造
DNSが取り扱うドメイン名は設計上、ルートドメインを頂点とした階層型のツリー構造となっています。ちょうど、コンピューターのファイルシステムがルートディレクトリを頂点としたツリー構造になっているのと同じだと考えてよいでしょう。そして、その配下にあるドメインはサブドメインとよばれます。ドメインの階層型のツリーは、ルートドメインとたくさんのサブドメインから構成されています。

### ルートドメイン
ルートドメインは、ドメイン名の開始点です。通常は省略されますが、DNS名として記述する際には「.」（ドット）で表されます。

#### トップレベルドメイン
トップレベルドメインには、.comや.orgのような組織別ドメインや、.jpのような国別ドメインがあります。また、日本の場合には.co.jpのような組織種別型ドメインと、example.jpのような汎用JPドメインなどがあります。

### ドメイン名の記述
ドメイン名の記述は、右側から記述していきます。FQDN(Fully Qualified Domain Name)であれば一番右にルートドメイン、そしてトップレベルドメインを記述し、さらに左側に各組織毎に割り当てられたドメイン名を記述していきます。各要素の間は「.」（ドット）で区切っていきます。

#### ドメイン名の記述例
- example.com.
- example.jp.
- example.co.jp.

トップレベルドメイン以降のドメイン名は、ドメイン取得者が独自にドメイン名を決めることができます。上記の例ではexampleの部分が独自のドメイン名にあたります。

### サブドメイン
記述例のようにドメイン名の左側にさらにドメイン名を記述していくことを「サブドメイン化」と呼びます。たとえば、example.co.jpドメインをさらに東京と大阪の2つに分けて表記したいような場合には、以下の例のように記述します。

- tokyo.example.co.jp.
- osaka.example.co.jp.

サブドメイン化は、上位の（右側の）ドメインを管理している管理者が行います。たとえば、tokyo.example.co.jpドメインまでのサブドメインの階層は次のようになっています。

1. jpドメインはルートドメインのサブドメイン
1. co.jpドメインはjpドメインのサブドメイン
1. example.co.jpドメインはco.jpドメインのサブドメイン
1. tokyo.example.co.jpドメインはexample.co.jpドメインのサブドメイン

### ドメイン名の取得
ドメイン名を取得するということは、上位のドメイン名の管理者にサブドメインを作ってもらい、管理権限を委譲してもらうということになります。短いドメイン名を取得したいのであればトップレベルドメインを管理している管理組織からサブドメイン化してもらうことになりますが、既にドメイン名を取得している管理者からサブドメインの管理権限を委譲してもらうこともできます。

## DNSを使った名前解決
DNSを使って名前を解決する、すなわち名前からIPアドレスを調べる時には、次のような手順で調査が行われます。

1. PCは、自分の組織やプロバイダーのDNSキャッシュサーバーへ問い合わせます。
1. DNSキャッシュサーバーは、ルートサーバーに「jp」を管理するDNSコンテンツサーバーのアドレスを問い合わせます。 ルートサーバーは、「jp」を管理するDNSコンテンツサーバーのアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、「jp」を管理するDNSコンテンツサーバーへ、サブドメイン「alpha.jp」を管理するDNSコンテンツサーバーのアドレスを問い合わせます。「alpha.jp」を管理するDNSコンテンツサーバーは、サブドメイン「alpha」を管理するDNSコンテンツサーバーのアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、「alpha.jp」を管理するDNSコンテンツサーバーへ、「www.alpha.jp」のアドレスを問い合わせます。「alpha.jp」を管理するDNSコンテンツサーバーは、「www.alpha.jp」のアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、PCに「www.alpha.jp」のアドレスを返します。

## これから構築するDNSの概略
各自がjp.ドメインのサブドメインを管理するDNSサーバーを作る演習を進めてもらうので、ドメインを管理する次の3台以上のマシンがある環境が望ましいです。

各マシンには、以下のような役割を割り当てます。

- 講師のマシン  
  DNSキャッシュサーバー
- 受講生Aのマシン  
alpha.jpドメインを受け持つDNSコンテンツサーバー
- 受講生Bのマシン  
beta.jpドメインを受け持つDNSコンテンツサーバー

教室の環境はインターネットに接続されている必要はありません。

以降の章(特にメール)ではDNSサーバーが正しく設定されていることを前提としているので、この章の演習内容が完全に終わっている必要があります。

![演習で使うアドレスとドメイン](image/dns-env2.png){width=65%}

:講師 {#tbl:講師}

|項目|設定値|
|---|---|
|IPアドレス|192.168.1.10|

:受講生A {#tbl:受講生A}

|項目|設定値|
|---|---|
|ドメイン名|alpha.jp.|
|IPアドレス|192.168.1.101|

: 受講生B {#tbl:受講生B}

|項目|設定値|
|---|---|
|ドメイン名|beta.jp.|
|IPアドレス|192.168.1.102|

\pagebreak

### アドレス解決の流れ
受講生Aのマシン(192.168.1.101)がホストwww.beta.jpを解決するときの動きを追ってみましょう。

WebブラウザーでWebページを表示させるとき、DNSキャッシュサーバーのことは特に意識せずWebサイトのアドレスを入力しています。ここではWebアドレスを入力してリクエストしてページが表示されるまでの流れを例に、DNSがどのように動くのか簡単に説明します。

1. 受講生Aは、受講生AのマシンのWebブラウザーにアドレスとしてwww.beta.jpを入力します
1. Webブラウザーは、Linuxのリゾルバに問い合わせします
1. リゾルバは、/etc/resolv.confファイルで指定されているDNSキャッシュサーバー（この場合は講師用サーバー:192.168.1.10）へ問い合わせます
1. 講師のマシンは、講師のDNSキャッシュサーバーを参照します
1. 講師のDNSキャッシュサーバーは、受講生BのDNSサーバーに問い合わせします
1. 受講生BのDNSサーバーは、www.beta.jpホストのIPアドレス（www.beta.jp→192.168.1.102）を講師のマシンに返します
1. 講師のマシンは、結果を受講生Aのマシンへ返します
1. 受講生Aのマシンは、www.beta.jpにHTTPでアクセスし、Webページを受け取って表示します

## 講師マシンへのDNSキャッシュサーバーの設定
最初に講師マシンをDNSキャッシュサーバーとして用意します。

### 必要なパッケージを確認
DNSキャッシュサーバーの構築に必要なパッケージは、unboundです。また、DNSサーバーの動作確認には、bind-utilsパッケージが必要です。rpmコマンドに-qオプションとパッケージ名を指定し、パッケージがインストールされているか確認します。パッケージがインストールされている場合には、次のように表示されます。

``` {language=Bash title="\{unboundパッケージの確認\}"}
# rpm -q unbound bind-utils
unbound-1.6.6-1.el7.x86_64
bind-utils-9.9.4-72.el7.x86_64
```
パッケージがインストールされていない場合には、次のように表示されます。

``` {language=Bash title="\{unboundパッケージがない場合}"}
# rpm -q unbound bind-utils
パッケージ unbound はインストールされていません。
パッケージ bind-utils はインストールされていません。
```
### unboundのインストール
unboundパッケージがインストールされていない時には、yumコマンドでインストールします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。


``` {language=Bash title="\{unboundのインストール}"}
# yum install unbound bind-utils
読み込んだプラグイン:fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: ftp.jaist.ac.jp
 * updates: ftp.jaist.ac.jp
 * extras: ftp.jaist.ac.jp
依存性の解決をしています
--> トランザクションの確認を実行しています。
---> パッケージ bind-utils.x86_64 32:9.9.4-72.el7 を インストール
---> パッケージ unbound.x86_64 0:1.6.6-1.el7 を インストール
--> 依存性解決を終了しました。

依存性を解決しました

================================================================================
 Package            アーキテクチャー
                                   バージョン                リポジトリー  容量
================================================================================
インストール中:
 bind-utils         x86_64         32:9.9.4-72.el7           base         206 k
 unbound            x86_64         1.6.6-1.el7               base         673 k

トランザクションの要約
================================================================================
インストール  2 パッケージ

総ダウンロード容量: 879 k
インストール容量: 2.8 M
Is this ok [y/d/N]: y	← yを入力
Downloading packages:
(1/2): bind-utils-9.9.4-72.el7.x86_64.rpm                  | 206 kB   00:00     
(2/2): unbound-1.6.6-1.el7.x86_64.rpm                      | 673 kB   00:00     
--------------------------------------------------------------------------------
合計                                               1.5 MB/s | 879 kB  00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  インストール中          : 32:bind-utils-9.9.4-72.el7.x86_64               1/2 
  インストール中          : unbound-1.6.6-1.el7.x86_64                      2/2 
  検証中                  : unbound-1.6.6-1.el7.x86_64                      1/2 
  検証中                  : 32:bind-utils-9.9.4-72.el7.x86_64               2/2 

インストール:
  bind-utils.x86_64 32:9.9.4-72.el7         unbound.x86_64 0:1.6.6-1.el7        

完了しました!
```

### リクエストを受け付けるIPアドレスの設定
/etc/unbound/local.d/interface.confファイルを作成し、DNSキャッシュサーバーがリクエストを受け付けるIPアドレスの設定をします。講師PCのIPアドレスと、ループバックアドレスを許可します。

``` {language=Bash title="\{/etc/unbound/local.d/interface.conf}"}
interface: 192.168.1.10
interface: 127.0.0.1
```

### 利用可能なクライアントの設定
DNSキャッシュサーバーは、不正に利用されないように必ず利用者を制限して使います。/etc/unbound/local.d/client.confファイルを作成し、このDNSキャッシュサーバーを利用できるクライアントの設定を行います。ここでは、192.168.1.0/24のネットワーク全体を許可します。

``` {language=Bash title="\{/etc/unbound/local.d/client.conf}"}
access-control: 192.168.1.0/24 allow
```

### 受講者用ドメインの設定
演習の環境では、jpドメインの管理サーバーにalpha.jp、beta.jpという受講者用のドメインを登録することができません。そのため、DNSキャッシュサーバーに特別にスタブゾーンの設定を行います（この設定は、正式にドメイン名を取得した場合には不要な設定です）。
設定のために、次のような/etc/unbound/conf.d/stub.confファイルを作成します。

``` {language=Bash title="\{/etc/unbound/conf.d/stub.conf}"}
stub-zone:
	name: alpha.jp.
	stub-addr: 192.168.1.101
	stub-prime: no
	stub-first: no
stub-zone:
	name: beta.jp.
	stub-addr: 192.168.1.102
	stub-prime: no
	stub-first: no
```

### unbound-keygenの起動
設定が終わったら、unboundの制御に使う鍵の生成を行います。次のように、unbound-keygen.serviceを起動すると、鍵が自動的に生成されます。

``` {language=Bash title="\{unbound-keygen.serviceの起動}"}
# systemctl start unbound-keygen.service
```

### unboundの設定確認
設定を行ったら、書式のチェックを行っておきましょう。

``` {language=Bash title="\{unboundの設定の確認}"}
# unbound-checkconf 
unbound-checkconf: no errors in /etc/unbound/unbound.conf
```

「no errors」と表示されていれば、書式エラーがないということです。エラーがある場合には、次のようにエラーの内容が表示されます。

``` {language=Bash title="\{unboundの設定にエラーがあるとき}"}
# unbound-checkconf	
[1550047518] unbound-checkconf[27152:0] fatal error: cannot parse interface specified as '127.0.0.1.'
```

エラーの内容を確認して、修正します。

### ファイアウォールの設定
次に、DNSキャッシュサーバーへの問い合わせができるようにファイアウォールのサービス許可設定を行います。

``` {language=Bash title="\{DNSアクセスの許可}"}
# firewall-cmd --add-service=dns
```

さらに、設定を保存しておきます。

``` {language=Bash title="\{Firewallルールの保存}"}
# firewall-cmd --runtime-to-permanent
```

### unboundの起動と確認
設定が終わったら、unboundを起動しましょう。systemctlで、unbound.serviceユニットを起動します.

``` {language=Bash title="\{unboundの起動}"}
# systemctl start unbound.service
```

起動ができたら、念のため確認します。

``` {language=Bash title="\{unboundの起動確認}"}
# systemctl status unbound.service
● unbound.service - Unbound recursive Domain Name Server
   Loaded: loaded (/usr/lib/systemd/system/unbound.service; disabled; vendor preset: disabled)
   Active: active (running) since 水 2019-02-13 17:46:55 JST; 4s ago
  Process: 28377 ExecStartPre=/usr/sbin/unbound-anchor -a /var/lib/unbound/root.key -c /etc/unbound/icannbundle.pem (code=exited, status=0/SUCCESS)
  Process: 28373 ExecStartPre=/usr/sbin/unbound-checkconf (code=exited, status=0/SUCCESS)
 Main PID: 28383 (unbound)
    Tasks: 4
   CGroup: /system.slice/unbound.service
           └─28383 /usr/sbin/unbound -d

 2月 13 17:46:55 host0 systemd[1]: Starting Unbound recursive Domain Nam.....
 2月 13 17:46:55 host0 unbound-checkconf[28373]: unbound-checkconf: no err...
 2月 13 17:46:55 host0 systemd[1]: Started Unbound recursive Domain Name...r.
 2月 13 17:46:55 host0 unbound[28383]: [28383:0] notice: init module 0: i...d
 2月 13 17:46:55 host0 unbound[28383]: [28383:0] notice: init module 1: v...r
 2月 13 17:46:55 host0 unbound[28383]: [28383:0] notice: init module 2: i...r
 2月 13 17:46:55 host0 unbound[28383]: [28383:0] info: start of service (....
Hint: Some lines were ellipsized, use -l to show in full.
```
Activeの欄に「active (running)」と表示されていることを確認します。また、下の方にはログが表示されます。ここでも、「info: start of service」と表示されていて、unboundのサービスが起動していることが確認できます。

#### unboundの再起動
既にunboundを起動している状態で、設定変更などをした場合には、次のようにunboundを再起動します。

``` {language=Bash title="\{unboundの再起動}"}
# systemctl restart unbound.service
```

### 自動起動の設定
Linux起動時にunboundが必ず起動されるように設定しておきましょう。自動起動になっているかは、次のように確認できます。

``` {language=Bash title="\{unboundの自動起動の確認}"}
# systemctl is-enabled unbound.service
disabled
```
自動起動の設定がされている場合には、「enabled」と表示されます。この例のように「disabled」と表示される場合には、自動起動設定が行われていません。次のようにして、自動起動設定を行います。

``` {language=Bash title="\{unboundの自動起動の設定}"}
# systemctl enable unbound.service
Created symlink from /etc/systemd/system/multi-user.target.wants/unbound.service to /usr/lib/systemd/system/unbound.service.
``` 

### 名前解決の確認
講師PCがインターネットと通信できる環境の場合には、この時点でインターネットの様々なサイトの名前解決ができるはずです。まずは、それを確認しておきましょう。

``` {language=Bash title="\{名前解決の確認}"}
# host www.yahoo.co.jp 192.168.1.10
Using domain server:
Name: 192.168.1.10
Address: 192.168.1.10#53
Aliases: 

www.yahoo.co.jp is an alias for edge12.g.yimg.jp.
edge12.g.yimg.jp has address 182.22.25.252	← IPアドレスが表示される
```

## 受講者マシンへのDNSコンテンツサーバーの設定
受講者マシンは、DNSコンテンツサーバーとして設定します。DNSコンテンツサーバーのソフトウェアとしてBINDをインストールして設定します。

### chroot機能を利用したBINDのセキュリティ
chroot機能はプログラムに対して特定のディレクトリ以外にはアクセスできないようにするための機能です。

chroot機能を使ってBINDを実行すると、bindプロセスは/var/named/chrootディレクトリを/（ルート）ディレクトリとして動作します。たとえば、bindプロセスが/etcディレクトリにアクセスしても、実際にアクセスされるのは/var/named/chroot/etcディレクトリになります。

![chroot利用時のディレクトリイメージ](image/6chroot.jpg){width=70%}

DNSというサービスを提供している関係上、BINDはインターネット上の数多くのサーバーで実行されており、セキュリティの攻撃を受けやすくなっています。万が一、BINDがセキュリティ攻撃を受けて乗っ取られてしまったとしても、chroot機能のおかげでbindプロセスがアクセスできるディレクトリを限定することができるので、システムのその他のファイルへのアクセスを妨げ、被害を最小限に食い止めることができます。

CentOS7では、シンボリックリンクやマウントなどのLinuxの機能を使って、chroot機能を使った場合でも、ほとんど管理方法が変わらないように工夫されています。そのため、本書でもchroot機能を有効にします。

### BINDパッケージの確認
DNSサーバーの構築に必要なパッケージを確認します。DNSの機能を提供するプログラムとしてBINDがあり、bindパッケージとbind-chrootパッケージが必要です。また、動作確認をするにはbind-utilsパッケージも必要です。rpmコマンドに-qオプションとパッケージ名を指定し、2つのパッケージがインストールされているか確認します。パッケージがインストールされている場合は次のように表示されます。

``` {language=Bash title="\{bindパッケージの確認}"}
# rpm -q bind bind-chroot bind-utils
bind-9.9.4-72.el7.x86_64
bind-chroot-9.9.4-72.el7.x86_64
bind-utils-9.9.4-72.el7.x86_64
```

パッケージがインストールされていない場合は次のように表示されます。

``` {language=Bash title="\{bindパッケージがない場合}"}
# rpm -q bind bind-chroot
パッケージ bind はインストールされていません。
パッケージ bind-chroot はインストールされていません。
パッケージ bind-utils はインストールされていません。
```

### BINDのインストール
DNSサーバーの構築に必要なパッケージがインストールされていないときは、yumコマンドでインストールをします。インターネットに接続できない環境では、GUIからadminでログインし、インストールメディアが自動マウントされた状態でインストール作業を進めます。

``` {language=Bash title="\{bindのインストール}"}
# yum install bind bind-chroot bind-utils
読み込んだプラグイン:fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: ftp.jaist.ac.jp
 * updates: ftp.jaist.ac.jp
 * extras: ftp.jaist.ac.jp
依存性の解決をしています
--> トランザクションの確認を実行しています。
---> パッケージ bind.x86_64 32:9.9.4-72.el7 を インストール
---> パッケージ bind-chroot.x86_64 32:9.9.4-72.el7 を インストール
---> パッケージ bind-utils.x86_64 32:9.9.4-72.el7 を インストール
--> 依存性解決を終了しました。

依存性を解決しました

================================================================================
 Package             アーキテクチャー
                                    バージョン               リポジトリー  容量
================================================================================
インストール中:
 bind                x86_64         32:9.9.4-72.el7          base         1.8 M
 bind-chroot         x86_64         32:9.9.4-72.el7          base          88 k
 bind-utils          x86_64         32:9.9.4-72.el7          base         206 k

トランザクションの要約
================================================================================
インストール  3 パッケージ

総ダウンロード容量: 2.1 M
インストール容量: 5.0 M
Is this ok [y/d/N]: y	← yを入力
Downloading packages:
(1/3): bind-chroot-9.9.4-72.el7.x86_64.rpm                 |  88 kB   00:00     
(2/3): bind-utils-9.9.4-72.el7.x86_64.rpm                  | 206 kB   00:00     
(3/3): bind-9.9.4-72.el7.x86_64.rpm                        | 1.8 MB   00:00     
--------------------------------------------------------------------------------
合計                                               3.4 MB/s | 2.1 MB  00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  インストール中          : 32:bind-9.9.4-72.el7.x86_64                     1/3 
  インストール中          : 32:bind-chroot-9.9.4-72.el7.x86_64              2/3 
  インストール中          : 32:bind-utils-9.9.4-72.el7.x86_64               3/3 
  検証中                  : 32:bind-9.9.4-72.el7.x86_64                     1/3 
  検証中                  : 32:bind-chroot-9.9.4-72.el7.x86_64              2/3 
  検証中                  : 32:bind-utils-9.9.4-72.el7.x86_64               3/3 

インストール:
  bind.x86_64 32:9.9.4-72.el7            bind-chroot.x86_64 32:9.9.4-72.el7     
  bind-utils.x86_64 32:9.9.4-72.el7     

完了しました!
```

### ゾーンを設定する流れ
ゾーンを追加するために必要な作業は次となります。

- named.confファイルにゾーンを追加
- ゾーンファイルを記述

ゾーンをDNSサーバーであるBINDで取り扱うために、BINDの基本的な設定ファイルである/etc/named.confファイルがあります。/etc/named.conf に基本的な設定とゾーンの定義を追加したら、ゾーンの詳細を定義するゾーンファイルを/var/namedディレクトリに作ります。

### /etc/named.confの基本設定
まず最初に、/etc/named.confファイルにDNSコンテンツサーバーとして動作する場合の、基本設定を行います。

``` {language=Bash title="\{/etc/named.confの編集}"}
# vi /etc/named.conf
```

``` {language=Bash title="\{受け付けるIPアドレスの設定（/etc/named.conf）}"}
options {
	listen-on port 53 { 127.0.0.1; 192.168.1.101; };	←　修正
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };	← 修正

	recursion no;	←　修正

	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.iscdlv.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

#### 問い合わせを受け付けるアドレスの設定
デフォルトのnamed.confファイルは、127.0.0.1(ローカルループバックインターフェース)への問い合わせにしか返答しない設定なので、外部からの問い合わせを受けられるように、「192.168.1.101;」をlisten-onに追加します。

#### 問い合わせを許可するアドレスの設定
allow-queryにはデフォルトでは「localhost;」と設定されていて、ローカルからしかDNS問い合わせができないようになっています。DNSコンテンツサーバーは、インターネット上のすべての人から参照できなければならないので、この設定を「any」に変更します。

#### DNSコンテンツサーバーとしての設定
DNSコンテンツサーバーでは、recursion（再帰問合せ）を禁止にしておく必要があります。そのため、recursionに「no」を設定します。

### 正引きゾーンの追加
次に、/etc/named.confの最後にゾーン定義を追加します。

``` {language=Bash title="\{/etc/named.confの編集}"}
# vi /etc/named.conf
```

``` {language=Bash title="\{/etc/named.confへのゾーンの追加}"}
zone "alpha.jp" IN {
	type master;
	file "alpha.jp.zone";
	allow-update { none; };
};	
```

### ゾーンファイルの作成
named.confで定義したゾーンの内容を記述するゾーンファイルの作成を行います。

#### ゾーンファイルの準備
ゾーンファイルのお手本となる/var/named/named.emptyファイルをコピーします。  
	
``` {language=Bash title="\{ゾーンファイルのコピー}"}
# cd /var/named
# cp -p named.empty alpha.jp.zone
# ls -l alpha.jp.zone 
-rw-r-----. 1 root named 152 12月 15  2009 alpha.jp.zone
```  
	
#### ゾーンファイルの修正
コピーした/var/named/alpha.jp.zoneファイルを修正します。  
	
``` {language=Bash title="\{ゾーンファイルの修正}"}
# vi /var/named/alpha.jp.zone
```  
	
``` {title="\{alpha.jp.zone}"}
$TTL 3H
$ORIGIN alpha.jp.
@       IN SOA  host1 root (
	                                 2019021401      ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host1.alpha.jp.
        MX 10   host1.alpha.jp.

host1   A       192.168.1.101
www     A       192.168.1.101
mail    A       192.168.1.101
vhost1  A       192.168.1.101
vhost2  A       192.168.1.101
```  

＠から始まるゾーンファイルの最初のレコードはSOAレコードで、このゾーンの管理ポリシーについて設定します。シリアルナンバー(serial)は、西暦(4桁の年)と月日(2桁ずつ)の後に01から99までの数字(2桁)が付いた10桁の数字で指定します。SOAレコードの先頭には＠がありますが、これは$ORIGINで指定したゾーン（ここではalpha.jp.）に置き換えられます。

MXレコードは受講生ドメインのメールサーバーを定義します。

NSレコードやMXレコードの定義では、右側にFQDNを入れるので、最後に必ず「.」を付けてください。また、先頭が空白になっていますが、これは前の行と同じ対象（この場合には＠）が省略されていることを示しています。

Aレコードで名前とIPアドレスの対応を定義する箇所は、左側にホスト名、右側にIP アドレスが入ります。受講生マシンのホスト名であるhost1や、以降の章で使うサーバーの名前であるwwwやmail、vhost1、vhost2とIPアドレスへの対応を記述しました。最後に「.」が付かない名前には、$ORIGINで定義しているゾーン名(ここではalpha.jp.)が自動的に追加されます。

#### ゾーンファイルの書式確認
ゾーンファイルを編集時、よくあるミスとしては、括弧の不足、セミコロンの不足などがあります。編集後、BINDを起動する前に編集したゾーンファイルに間違いがないかよく確認しましょう。

``` {language=Bash title="\{zoneファイルの確認}"}
# named-checkzone alpha.jp. /var/named/alpha.jp.zone 
zone alpha.jp/IN: loaded serial 2019021401
OK
```

named-checkzoneの引数は、$ORIGINに指定したドメイン名と、ゾーンファイル名です。書式に問題がなければ、この例のように設定したシリアルナンバーが表示され、OKと表示されます。設定が間違っている場合には、次のように問題のある行番号が表示されます。

``` {language=Bash title="\{zoneファイルの書式が不正な場合}"}
# named-checkzone alpha.jp. /var/named/alpha.jp.zone 
alpha.jp.zone:9: unknown RR type 'host1.alpha.jp.'
zone alpha.jp/IN: loading from master file alpha.jp.zone failed: unknown class/type
zone alpha.jp/IN: not loaded due to errors.
```

### 設定ファイルの書式確認と注意点
/etc/named.confファイルでも、括弧の不足やセミコロンの不足などは良くあるミスです。一通りの設定ができたら、/etc/named.confの初期確認をしておきましょう。次のように、named-checkconfを実行します。

``` {language=Bash title="\{/etc/named.confの確認}"}
# named-checkconf
```

この例のように、何も表示されなければ書式に問題がないということです。問題がある場合には、次のように問題がありそうな行番号が表示されます。

``` {language=Bash title="\{/etc/named.confの書式が不正な場合}"}
# named-checkconf
/etc/named.conf:68: missing ';' before end of file
```

listen-on portの{〜}にアドレスを追加するときに、IPアドレスの後にセミコロンを入れ忘れたり、allow-query  { any; };のように、{ }の中と外にセミコロンを入れ忘れたりといったミスが起こりがちです。エラー表示を見ながら、こうした問題を取り除きましょう。

### ファイアウォールの設定
次に、DNSコンテンツサーバーへの問い合わせができるようにファイアウォールのサービス許可設定を行います。

``` {language=Bash title="\{DNSアクセスの許可}"}
# firewall-cmd --add-service=dns
```

さらに、設定を保存しておきます。

``` {language=Bash title="\{Firewallルールの保存}"}
# firewall-cmd --runtime-to-permanent
```

### BINDの起動と確認
各自のドメインを定義したらBINDを起動してみましょう。BINDの起動は、systemctlコマンドでnamed-chroot.serviceユニットを使います。

``` {language=Bash title="\{BINDの起動}"}
# systemctl start named-chroot.service
```

起動ができたら、念のため確認します。

``` {language=Bash title="\{BINDの起動確認}"}
# systemctl status named-chroot.service
 named-chroot.service - Berkeley Internet Name Domain (DNS)
   Loaded: loaded (/usr/lib/systemd/system/named-chroot.service; disabled; vendor preset: disabled)
   Active: active (running) since 木 2019-02-14 16:00:12 JST; 5s ago
  Process: 32681 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} -t /var/named/chroot $OPTIONS (code=exited, status=0/SUCCESS)
  Process: 32678 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -t /var/named/chroot -z "$NAMEDCONF"; else echo "Checking of zone files is disabled"; fi (code=exited, status=0/SUCCESS)
 Main PID: 32683 (named)
    Tasks: 4
   CGroup: /system.slice/named-chroot.service
           └─32683 /usr/sbin/named -u named -c /etc/named.conf -t /var/named/...

 2月 14 16:00:12 centos7 named[32683]: managed-keys-zone: loaded serial 57
 2月 14 16:00:12 centos7 named[32683]: zone 0.in-addr.arpa/IN: loaded serial 0
 2月 14 16:00:12 centos7 named[32683]: zone alpha.jp/IN: loaded serial 2019...1
 2月 14 16:00:12 centos7 named[32683]: zone 1.0.0.127.in-addr.arpa/IN: load...0
 2月 14 16:00:12 centos7 named[32683]: zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0...0
 2月 14 16:00:12 centos7 named[32683]: zone localhost/IN: loaded serial 0
 2月 14 16:00:12 centos7 named[32683]: zone localhost.localdomain/IN: loade...0
 2月 14 16:00:12 centos7 named[32683]: all zones loaded
 2月 14 16:00:12 centos7 named[32683]: running
 2月 14 16:00:12 centos7 systemd[1]: Started Berkeley Internet Name Domain...).
Hint: Some lines were ellipsized, use -l to show in full.
```
Activeの欄に「active (running)」と表示されていることを確認します。また、下の方にはログが表示されます。ここでも、「Started Berkeley Internet Name Domain...」と表示されていて、BINDのサービスが起動していることが確認できます。

#### BINDの再起動
既にBINDを起動している状態で、設定変更などをした場合には、次のようにBINDを再起動します。

``` {language=Bash title="\{BINDの再起動}"}
# systemctl restart named-chroot.service
```

### 自動起動の設定
Linux起動時にBINDが必ず起動されるように設定しておきましょう。自動起動になっているかは、次のように確認できます。

``` {language=Bash title="\{BINDの自動起動の確認}"}
# systemctl is-enabled named-chroot.service
disabled
```

自動起動の設定がされている場合には、「enabled」と表示されます。この例のように「disabled」と表示される場合には、自動起動設定が行われていません。次のようにして、自動起動設定を行います。

``` {language=Bash title="\{BINDの自動起動の設定}"}
# systemctl enable named-chroot.service
Created symlink from /etc/systemd/system/multi-user.target.wants/named-chroot.service to /usr/lib/systemd/system/named-chroot.service.
``` 

### 名前解決の確認
BINDが起動したら、名前解決が正常に行われるかを確認します。名前解決の確認には、hostコマンドとdigコマンドが使用できます。

#### hostコマンドで名前を確認

hostコマンドで名前からIPアドレスを確認します。hostコマンドの最初の引数は調査するアドレス、２つめの引数は調査対象サーバーのアドレスです。さきほど設定したDNSサーバーのIPアドレスを指定します。

``` {language=Bash title="\{hostコマンドでの確認}"}
# host host1.alpha.jp 192.168.1.101
Name: 192.168.1.101
Address: 192.168.1.101#53
Aliases: 

host1.alpha.jp has address 192.168.1.101
# host www.alpha.jp 192.168.1.101
Using domain server:
Name: 192.168.1.101
Address: 192.168.1.101#53
Aliases: 

www.alpha.jp has address 192.168.1.101
# host mail.alpha.jp 192.168.1.101
Using domain server:
Name: 192.168.1.101
Address: 192.168.1.101#53
Aliases: 

mail.alpha.jp has address 192.168.1.101
```

#### digコマンドでドメインを確認
digコマンドでゾーン情報を確認してみてください。ドメイン名の後にaxfrを指定するとゾーンに登録されている全ての情報が表示されます。問い合わせをするサーバーは、@をつけて指定します。

``` {language=Bash title="\{digコマンドでの確認}"}
# dig alpha.jp axfr @192.168.1.101

; <<>> DiG 9.9.4-RedHat-9.9.4-73.el7_6 <<>> alpha.jp axfr @192.168.1.101
;; global options: +cmd
alpha.jp.		10800	IN	SOA	host1.alpha.jp. root.alpha.jp. 2019021401 86400 3600 604800 10800
alpha.jp.		10800	IN	NS	host1.alpha.jp.
alpha.jp.		10800	IN	MX	10 host1.alpha.jp.
host1.alpha.jp.		10800	IN	A	192.168.1.101
mail.alpha.jp.		10800	IN	A	192.168.1.101
vhost1.alpha.jp.	10800	IN	A	192.168.1.101
vhost2.alpha.jp.	10800	IN	A	192.168.1.101
www.alpha.jp.		10800	IN	A	192.168.1.101
alpha.jp.		10800	IN	SOA	host1.alpha.jp. root.alpha.jp. 2019021401 86400 3600 604800 10800
;; Query time: 6 msec
;; SERVER: 192.168.1.101#53(192.168.1.101)
;; WHEN: 木  2月 14 16:28:03 JST 2019
;; XFR size: 9 records (messages 1, bytes 242)
```

ドメイン名の後にnsを指定するとドメインに登録されているNSレコード(ネームサーバーの情報)が表示されます。

``` {language=Bash title="\{digコマンドでのNSレコードの確認}"}
# dig alpha.jp ns @192.168.1.101

; <<>> DiG 9.9.4-RedHat-9.9.4-73.el7_6 <<>> alpha.jp ns @192.168.1.101
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16831
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;alpha.jp.			IN	NS

;; ANSWER SECTION:
alpha.jp.		10800	IN	NS	host1.alpha.jp.

;; ADDITIONAL SECTION:
host1.alpha.jp.		10800	IN	A	192.168.1.101

;; Query time: 0 msec
;; SERVER: 192.168.1.101#53(192.168.1.101)
;; WHEN: 木  2月 14 16:31:55 JST 2019
;; MSG SIZE  rcvd: 73
```

digコマンドの結果に、ANSWER SECTIONがあれば正常であり、ANSWER SECTIONが無ければ結果が返らない状態のエラーです。

ドメイン名の後にmxを指定するとドメインに登録されているMXレコード(メールサーバーの情報)が表示されます。

``` {language=Bash title="\{digコマンドでのMXレコードの確認}"}
# dig alpha.jp mx @192.168.1.101

; <<>> DiG 9.9.4-RedHat-9.9.4-73.el7_6 <<>> alpha.jp mx @192.168.1.101
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 1245
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;alpha.jp.			IN	MX

;; ANSWER SECTION:
alpha.jp.		10800	IN	MX	10 host1.alpha.jp.

;; AUTHORITY SECTION:
alpha.jp.		10800	IN	NS	host1.alpha.jp.

;; ADDITIONAL SECTION:
host1.alpha.jp.		10800	IN	A	192.168.1.101

;; Query time: 0 msec
;; SERVER: 192.168.1.101#53(192.168.1.101)
;; WHEN: 木  2月 14 16:33:08 JST 2019
;; MSG SIZE  rcvd: 89
```

## リゾルバの変更
講師マシンのDNSキャッシュサーバーの設定と、受講生マシンのDNSコンテンツサーバーの設定が完了したので、受講生マシンから講師マシンを経由すればすべての下位ドメインを問合せできます。講師マシンがインターネットと通信できる環境の場合には、すべてのドメインを問合せすることができます。受講生マシンと講師マシンのDNSサーバーの設定を変更しておきましょう。

GNOMEのデスクトップのアプリケーションメニューから「システムツール」→「設定」を選択します。表示された設定画面の左側のメニューから「ネットワーク」を選択します。

![設定画面](image/network-menu.png){width=70%}

「有線」の欄にある歯車のボタンをクリックすると、接続プロファイルの設定画面が表示されます。「IPv4」のタブをクリックすると、次のような画面になります。

![ネットワーク詳細設定画面](image/network-setup.png){width=70%}

DNSサーバーのアドレスを講師マシンのIPアドレス「192.168.1.10」に変更します。変更したら、「適用」ボタンを押して元の画面に戻ります。「有線」の項目にあるスイッチを、一旦「オフ」に変えます。再度、「オン」に変えるとDNS設定が変更されます。

### 名前解決の確認
リゾルバの変更ができたら、DNSサーバーを指定しなくてもDNSの問い合わせができるようになります。hostコマンドで、自分のドメインのNSレコードやMXレコードを問い合わせて見てください。hostコマンドでは、-tオプションを使うことで、問い合わせるレコードを指定することができます。

``` {language=Bash title="\{hostコマンドでの動作確認}"}
# host -t ns alpha.jp
alpha.jp name server host1.alpha.jp.
# host -t mx alpha.jp
alpha.jp mail is handled by 10 host1.alpha.jp.
```
## DNSコンテンツサーバーのセキュリティ
動作確認のため、digのaxfrを使ってゾーンを転送する例を紹介しました。しかし、インターネット上の見知らぬサイトに、すべてのゾーンデータを教えるのは懸命ではありません。
BINDのデフォルトでは、すべてのホストへのゾーン転送が許可されます。zoneステートにallow-transferオプションが記述された場合、optionsステートメントの設定を上書きできます。下記のように設定することで、ゾーン転送をlocalhostとネットワークアドレス192.168.1.0以下にある端末からのみ許可できます。

``` {title="\{/etc/named.confへのallow-transferの設定}"}
options {
（略）
        allow-transfer  { localhost; 192.168.1.0/24; };
（略）
};
```

\pagebreak
