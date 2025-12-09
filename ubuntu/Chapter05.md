# DNSサーバーの構築
第5章では、ネットワークサービスを使うための土台となる名前解決のサービス(DNS)を設定します。自分のDNSサーバーを他のコンピュータから参照できるように設定をします。DNSに問い合わせを行うコマンドに慣れ、ドメインを管理するBINDプログラムの設定ファイルを扱います。

## 用語集
### DNS {.unlisted .unnumbered}
DNS(Domain Name System)は、IPアドレスと対応するホスト名を登録しておき、プログラムからの問い合わせに応じてIPアドレスやホスト名を返答するシステムです。

### ドメイン名とゾーン {.unlisted .unnumbered}
組織に割り当てられてインターネットで使用する名前をドメイン名と呼びます。ドメイン名はICANN(Internet Corporation for Assigned Names and Numbers)により管理されています。DNSでドメイン名を設定するときは、ドメインではなく「ゾーン」と呼びます。

### ゾーン {.unlisted .unnumbered}
DNSの名前空間の一部分を取り出したものをゾーンとよびます。ゾーンは、DNSを管理する単位として使われます。ゾーンには、ドメイン、サブドメイン、ホスト名などが含まれています。DNS名前空間はツリー構造で表されますが、ゾーンは特定のノード以下の一部または全部を含む部分です。

### FQDN {.unlisted .unnumbered}
ドメイン名表記で、一番右に「.」（ドット）でルートドメインまでを記述する方式をFQDNと呼びます。

### DNSキャッシュサーバー {.unlisted .unnumbered}
プログラムからの名前問い合わせを代行して、様々なDNSサーバーへ名前問い合わせを行って結果を返却するサーバーです。調べた結果をキャッシュしておき、次回問い合わせ時にキャッシュの情報を返すことから、DNSキャッシュサーバーと呼ばれます。クライアントのネットワーク設定でDNSサーバーと呼んだときには、DNSキャッシュサーバーのことを指します。

### DNSコンテンツサーバー {.unlisted .unnumbered}
委託されたゾーンのIPアドレスやホスト名を管理するDNSサーバーです。取得したドメイン名を利用するには、DNSコンテンツサーバーを用意して設定する必要があります。

### リゾルバ {.unlisted .unnumbered}
ドメイン名をもとにIPアドレス情報の検索をしたり、IPアドレスからドメイン情報の検索を行う、名前解決を行うプログラムのことです。

### BIND {.unlisted .unnumbered}
BIND(Berkeley Internet Name Domain)は、Linuxと組み合わせて多く使用されているDNSサーバーのソフトウェアです。DNSキャッシュサーバーとしても、DNSコンテンツサーバーとしても利用することができます。

### グルーレコード {.unlisted .unnumbered}
管理を委任しているゾーンについての問合せに対して、DNSサーバーが委任先のゾーンのDNSコンテンツサーバーのアドレスを返す際に、追加情報として必要となる委任先DNSコンテンツサーバーのAレコードをグルーレコードといいます。

### Aレコード {.unlisted .unnumbered}
名前に対してIPアドレスを指定するためのレコードです。

### NS(Name Server)レコード {.unlisted .unnumbered}
ゾーンの権威を持つDNSコンテンツサーバーを指定するためのレコードです。

### MX(Mail eXchange)レコード {.unlisted .unnumbered}
メールアドレスに利用するドメイン名を定義するためのレコードです。メールサーバーの障害にも対応するために、複数個のメールサーバーを記述でき、プリファレンス値の低いサーバーにメール配信が優先されます。

## DNSの仕組み
インターネットでのコンピュータ同士の通信は、IP(Internet Protocol)を使って行われています。IP通信には相手のIPアドレスが必要ですが、インターネット上の大量のコンピュータをIPアドレスで識別するのは困難です。そこでドメイン名やホスト名という考え方が導入されました。

ドメイン名は組織を表し、ホスト名はその組織が管理しているコンピュータです。表記するときは「ホスト名.ドメイン名」とドット区切りで表記しますが、両方を合わせてホスト名と呼ぶこともあります。

### HOSTSファイルとDNS
インターネットの研究が始まった当初はIPアドレスが割り当てられたコンピュータの数も数えるほどだったので、ホスト名とIPアドレスの対応関係はファイルに記述されて、定期的に更新されていました。この仕組みは今でも残っており、Linuxでは/etc/hostsがそのファイルです。

しかし、インターネットが広まるに従って、ホストファイルでは管理しきれなくなってきました。そこで登場したのがDNS(Domain Name System)です。

### DNSコンテンツサーバーによるドメイン名の管理
ドメイン名を割り当てられた組織毎にDNSコンテンツサーバーを用意します。DNSコンテンツサーバーの管理者は、そのドメインに所属しているホスト名と割り当てられたIPアドレスをDNSコンテンツサーバー登録します。

あるドメインに所属しているホストにアクセスしたいユーザーは、そのドメインのDNSコンテンツサーバーに問い合わせを行うことで、IPアドレスを得ることができます。

DNSの仕組みでは、ドメイン（ゾーン）の管理権限がそれぞれのDNS管理者に委譲されているので、ホストファイルのような一元管理ではなく分散管理となります。管理作業が分担されていて更新も頻繁に行われるので、リアルタイムにホスト名とIPアドレスの対応関係を調べることができる仕組みとなっています。

### DNSキャッシュサーバーによる名前解決
ユーザーの端末が名前解決を必要とする度に、アクセス先のDNSコンテンツサーバーを探して問い合わせをするのは非常に煩雑になります。そこで端末はDNSキャッシュサーバーに名前解決を依頼し、DNSキャッシュサーバーが後述する再帰問い合わせという方法でDNSコンテンツサーバーに対して問い合わせを行います。名前解決が完了すると、その結果だけを端末に返します。

このような仕組みになっているので、PCやスマートフォンではIPアドレス設定の際に検索に使用するDNSサーバーの設定が必要になります。この設定が、名前解決を依頼するDNSキャッシュサーバーのIPアドレスとなります。

また、名前解決の結果は一定期間キャッシュされています。同じホストの名前解決が依頼されるとキャッシュから返答するようにしているので、毎回調べる必要がありません。

\pagebreak
## ドメインの構造
DNSが取り扱うドメイン名は設計上、ルートドメインを頂点とした階層型のツリー構造となっています。ちょうどコンピュータのファイルシステムが、ルートディレクトリを頂点としたツリー構造になっているのと同じだと考えてよいでしょう。そして、その配下にあるドメインはサブドメインとよばれます。ドメインの階層型のツリーは、ルートドメインとたくさんのサブドメインから構成されています。

![DNSは階層型データベース](image/Ch5/DomainTree.png){width=70%}

### ルートドメイン
ルートドメインは、ドメイン名の開始点です。通常は省略されますが、ドメイン名として記述する際には「.」（ドット）で表されます。

### トップレベルドメイン
トップレベルドメインには、.comや.orgのような組織別ドメインや、.jpのような国別ドメインがあります。また、日本の場合にはexample.co.jpのような組織種別型ドメインと、example.jpのような汎用JPドメインなどがあります。

### ドメイン名の記述
ドメイン名の記述は、右側から記述していきます。FQDN(Fully Qualified Domain Name)であれば一番右にルートドメイン、そしてトップレベルドメインを記述し、さらに左側に各組織毎に割り当てられたドメイン名を記述していきます。各要素の間は「.」（ドット）で区切っていきます。

### ドメイン名の記述例
- example.com.
- example.jp.
- example.co.jp.

トップレベルドメイン以降のドメイン名は、ドメイン取得者が独自にドメイン名を決めることができます。上記の例ではexampleの部分が独自のドメイン名にあたります。

### サブドメイン
記述例のようにドメイン名の左側にさらにドメイン名を記述していくことを「サブドメイン化」と呼びます。たとえば、example.co.jpドメインをさらに東京と大阪の2つに分けて表記したいような場合には、以下の例のように記述します。

- tokyo.example.co.jp.
- osaka.example.co.jp.

サブドメイン化は、上位のドメイン（表記上の右側）を管理している管理者が行います。たとえば、tokyo.example.co.jpドメインまでのサブドメインの階層は次のようになっています。

1. jpドメインはルートドメインのサブドメイン
1. co.jpドメインはjpドメインのサブドメイン
1. example.co.jpドメインはco.jpドメインのサブドメイン
1. tokyo.example.co.jpドメインはexample.co.jpドメインのサブドメイン

### ドメイン名の取得
ドメイン名を取得するということは、上位のドメイン名の管理者にサブドメインを作ってもらい、管理権限を委譲してもらうということになります。

独自の短いドメイン名を取得したいのであればトップレベルドメインを管理している管理組織からサブドメイン化してもらうことになりますが、登録料などの費用がかかります。

短いドメイン名にこだわらない、費用をかけたくない場合には、既にドメイン名を取得している管理者からサブドメインの管理権限を委譲してもらうこともできます。

\pagebreak
## DNSを使った名前解決と再帰問い合わせ
DNSを使って名前を解決する、すなわち名前からIPアドレスを調べる時には、次のような手順で調査が行われます。

1. 端末は、自分の組織やプロバイダーの用意したDNSキャッシュサーバーへ問い合わせます。
1. DNSキャッシュサーバーは、ルートサーバーに「test」を管理するDNSコンテンツサーバーのIPアドレスを問い合わせます。ルートサーバーは、「test」を管理するDNSコンテンツサーバーのIPアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、「test」を管理するDNSコンテンツサーバーへ、サブドメイン「example1.test」を管理するDNSコンテンツサーバーのIPアドレスを問い合わせます。「test」を管理するDNSコンテンツサーバーは、サブドメイン「example1.test」を管理するDNSコンテンツサーバーのIPアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、「example1.test」を管理するDNSコンテンツサーバーへ、「www.example1.test」のIPアドレスを問い合わせます。「example1.test」を管理するDNSコンテンツサーバーは、「www.example1.test」のIPアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、クライアントに「www.example1.test」のIPアドレスを返します。

このように、DNSキャッシュサーバーがルートサーバーから順番に問い合わせを行い、最終的に目的のドメインを管理するDNSコンテンツサーバーまで問い合わせをしていくことを「再帰問い合わせ」と呼びます。

![名前解決と再帰問い合わせ](image/Ch5/NameResolv.png){width=70%}

\pagebreak
## 演習で構築するDNSの概略
2つのドメイン名「example1.test」と「example2.test」を設定し、相互に名前解決ができるようにDNSコンテンツサーバーを構築します。また、testドメインからサブドメイン化してゾーンの管理権限を委譲する設定も行います。以下の3つのDNSサーバーを構築します。

### testゾーンのマシン
example1.testとexample2.testをサブドメイン化し、ゾーン管理権限の委譲を設定します。またDNSキャッシュサーバーとしても動作します。

### example1.testゾーンのマシン
example1.testゾーンを管理するDNSコンテンツサーバーとして設定します。

### example2.testゾーンのマシン
example2.testゾーンを管理するDNSコンテンツサーバーとして設定します。

## 演習の手順
3台のマシンを相互に接続し、相互にDNSを参照できるように設定します。追加でマシン2台分の仮想マシンの作成やOSのインストールなどが必要となります。以下の作業を行っていきます。

1. DNSサーバーソフトウェアであるBINDを使って、example1.testゾーンを管理するDNSコンテンツサーバーを設定します。
1. testゾーンおよびexample2.testゾーンの仮想マシンを作成し、OSをインストールします。それぞれIPアドレスなどの設定が異なる点に注意してください。
1. example2.testゾーンを管理するDNSコンテンツサーバーを設定します。
1. testゾーンを管理するDNSコンテンツサーバーを設定します。example1.testゾーンおよびexample2.testゾーンに対する権限委譲を設定します。
1. example1.testゾーンとexample2.testゾーンのDNSを相互に参照できることを確認します。

次章のメールサーバー構築ではDNSサーバーが正しく設定されていることを前提としているので、この章の演習内容が完全に終わっている必要があります。

## 演習で使うアドレスとドメイン
演習で使用する3台のサーバーのドメイン名、ホスト名、IPアドレスは以下の通りです。

|ドメイン名|ホスト名|IPアドレス|
|---|---|---|
| test | host0.test | 192.168.1.11 |
| example1.test | host1.example1.test | 192.168.1.12 |
| example2.test | host2.example2.test | 192.168.1.13 |

## アドレス解決の流れ
host1.example1.testのマシン(192.168.1.12)がホストwww.example2.testを解決するときの動きを追ってみましょう。

WebブラウザでWebページを表示させるとき、DNSキャッシュサーバーのことは特に意識せずWebサイトのアドレスを入力しています。ここではWebアドレスを入力してリクエストしてページが表示されるまでの流れを例に、DNSがどのように動くのか簡単に説明します。

1. host1.example1.testマシンは、Webブラウザにアドレスとしてwww.example2.testを入力します。
1. Webブラウザは、Linuxのリゾルバに問い合わせます。
1. リゾルバは、/etc/resolv.confファイルで指定されているDNSキャッシュサーバー（192.168.1.11）へ問い合わせます。
1. DNSキャッシュサーバーは、testゾーンのDNSコンテンツサーバーを参照し、example2.testゾーンのDNSコンテンツサーバーのIPアドレス（192.168.1.13）を返します。
1. DNSキャッシュサーバーは、example2.testゾーンのDNSコンテンツサーバーに問い合わせします。
1. example2.testゾーンのDNSコンテンツサーバーは、www.example2.testホストのIPアドレス（192.168.1.13）を返します。
1. DNSキャッシュサーバーは、結果をexample1.testマシンへ返します。
1. Webブラウザは、www.example2.testにHTTPでアクセスし、Webページを受け取って表示します。

実際のインターネットでのDNSの名前解決ではルートゾーンから順番に再帰問い合わせを行いますが、演習環境ではDNSキャッシュサーバー自身がjpゾーンのDNSコンテンツサーバーでもあるため、すぐにexample2.testのDNSコンテンツサーバーに関する情報を返す点が異なります。

![実習環境での名前解決](image/Ch5/NameResolvEnv.png){width=70%}

\pagebreak
## DNSコンテンツサーバーの設定
DNSコンテンツサーバーのソフトウェアとしてBINDをインストールして、各ゾーンの設定を行います。

### ゾーンを設定する流れ
ゾーンを設定するために必要な作業は以下の手順となります。

1. BINDのインストールを行います。
1. named.confファイルにゾーンを追加します。
1. ゾーンファイルを作成し、レコードなどを記述します。
1. 設定ファイルに書式間違いが無いか確認します。
1. BINDの起動を行います。
1. BINDの自動起動の設定を行います。
1. ファイアウォールの設定を変更します。
1. /etc/resolv.confの参照するDNSサーバーの設定を確認します。
1. 名前解決の確認を行います。

BINDの基本的な設定ファイルとして/etc/bind/named.confファイルがあります。/etc/bind/named.confにBINDの基本的な設定とゾーンの定義を追加します。さらにゾーンの詳細を定義するゾーンファイルを/etc/bindディレクトリに作ります。

## BINDのインストール
BINDのインストールには、bind9パッケージを使います。必要なパッケージがインストールされていないときには、aptコマンドでインストールします。

```
ubuntu@host1example1test:~$ sudo apt install bind9
[sudo] password for ubuntu:
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  bind9-utils dns-root-data
Suggested packages:
  bind-doc
The following NEW packages will be installed:
  bind9 bind9-utils dns-root-data
0 upgraded, 3 newly installed, 0 to remove and 73 not upgraded.
Need to get 419 kB of archives.
After this operation, 1,624 kB of additional disk space will be used.
Do you want to continue? [Y/n]
Get:1 http://jp.archive.ubuntu.com/ubuntu noble-updates/main amd64 bind9-utils amd64 1:9.18.30-0ubuntu0.24.04.2 [159 kB]
Get:2 http://jp.archive.ubuntu.com/ubuntu noble-updates/main amd64 dns-root-data all 2024071801~ubuntu0.24.04.1 [5,918 B]
Get:3 http://jp.archive.ubuntu.com/ubuntu noble-updates/main amd64 bind9 amd64 1:9.18.30-0ubuntu0.24.04.2 [254 kB]
Fetched 419 kB in 2s (180 kB/s)
Selecting previously unselected package bind9-utils.
(Reading database ... 86791 files and directories currently installed.)
Preparing to unpack .../bind9-utils_1%3a9.18.30-0ubuntu0.24.04.2_amd64.deb ...
Unpacking bind9-utils (1:9.18.30-0ubuntu0.24.04.2) ...
Selecting previously unselected package dns-root-data.
Preparing to unpack .../dns-root-data_2024071801~ubuntu0.24.04.1_all.deb ...
Unpacking dns-root-data (2024071801~ubuntu0.24.04.1) ...
Selecting previously unselected package bind9.
Preparing to unpack .../bind9_1%3a9.18.30-0ubuntu0.24.04.2_amd64.deb ...
Unpacking bind9 (1:9.18.30-0ubuntu0.24.04.2) ...
Setting up dns-root-data (2024071801~ubuntu0.24.04.1) ...
Setting up bind9-utils (1:9.18.30-0ubuntu0.24.04.2) ...
Setting up bind9 (1:9.18.30-0ubuntu0.24.04.2) ...
info: Selecting GID from range 100 to 999 ...
info: Adding group `bind' (GID 110) ...
info: Selecting UID from range 100 to 999 ...

info: Adding system user `bind' (UID 110) ...
info: Adding new user `bind' (UID 110) with group `bind' ...
info: Not creating home directory `/var/cache/bind'.
wrote key file "/etc/bind/rndc.key"
named-resolvconf.service is a disabled or a static unit, not starting it.
Created symlink /etc/systemd/system/bind9.service → /usr/lib/systemd/system/named.service.
Created symlink /etc/systemd/system/multi-user.target.wants/named.service → /usr/lib/systemd/system/named.service.
Processing triggers for man-db (2.12.0-4build2) ...
Processing triggers for ufw (0.36.2-6) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```

## /etc/named.confの基本設定
/etc/bind/named.confファイルにBINDをDNSコンテンツサーバーとして動作させる基本設定を行います。

```
ubuntu@host1example1test:~$ sudo vi /etc/bind/named.conf

ubuntu@host1example1test:~$ sudo cat /etc/bind/named.conf
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
include "/etc/bind/named.conf.my-zones";　← 追記設定を記載するファイルを指定
```

```
ubuntu@host1example1test:~$ sudo vi /etc/bind/named.conf.my-zones

ubuntu@host1example1test:~$ sudo cat /etc/bind/named.conf.my-zones
zone "example1.test" IN { ← example1.testゾーンを指定
        type master;
        file "/etc/bind/example1.test.zone"; ← example1.test用のゾーン定義ファイル名を指定
        allow-update { none; };
};
```

```
ubuntu@host1example1test:~$ sudo vi /etc/bind/example1.test.zone

ubuntu@host1example1test:~$ sudo cat /etc/bind/example1.test.zone
$TTL 3H
$ORIGIN example1.test.
@       IN SOA  host1 root (
                                        2025050501       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host1.example1.test.
        MX 10   mail.example1.test.

host1   A       192.168.1.12
www     A       192.168.1.12
mail    A       192.168.1.12
```

```
ubuntu@host1example1test:~$ sudo vi /etc/bind/named.conf.options

ubuntu@host1example1test:~$ sudo cat /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        //directory "/etc/bind";
        listen-on port 53 { 127.0.0.1; 192.168.1.12; };
        listen-on-v6 port 53 { ::1; };
        allow-query     { any; };

        recursion no;

        dnssec-validation auto;
};
```

設定の内容は以下の通りです。

### 問い合わせを受け付けるアドレスの設定
デフォルトのnamed.confファイルは、127.0.0.1(ローカルループバックインターフェース)への問い合わせにしか返答しない設定なので、外部からの問い合わせを受けられるようにサーバー自身のIPアドレスである「192.168.1.12;」をlisten-onに追加します。後ほど設定するexample2.testサーバーやlocalサーバーの場合にはそれぞれのサーバーのIPアドレスを記述します。

### 問い合わせを許可するアドレスの設定
allow-queryにはデフォルトでは「localhost;」と設定されていて、ローカルからしかDNS問い合わせができないようになっています。DNSコンテンツサーバーはインターネット上のすべての人から参照できなければならないので、この設定を「any」に変更します。

### DNSコンテンツサーバーとしての設定
DNSコンテンツサーバーでは、recursion(再帰問合せ)を禁止にしておく必要があります。そのため、recursionに「no」を設定します。ただし、localサーバーの場合にはDNSキャッシュサーバーとしても動作させるのでyesのままにしておく必要があります。


## ゾーンファイルの準備

\pagebreak
## ゾーンファイルの修正

### $TTL
このゾーン定義ファイル内の記述のTTL（Time to Live・生存時間・有効期間）が3時間であることをデフォルト指定しています。

### \$ORIGIN
このゾーン定義が対象としているゾーン名を指定します。ゾーン定義内のホスト名はすべてFQDNで最後が「.」で終わる必要がありますが、省略された場合には$ORIGINで指定されたゾーン名で補完されます。たとえば、「www」という記述は「www.example1.test.」と補完されて扱われます。

### SOAレコード
＠から始まるゾーンファイルの最初のレコードはSOAレコードです。このゾーンの管理ポリシーについて設定します。SOAレコードの先頭には＠がありますが、これは$ORIGINで指定したゾーン（ここではexample1.test.）に置き換えられます。host1はこのDNSコンテンツサーバーのホスト名、rootは管理者ユーザーです。どちらもゾーン名が補完されて、「host1.example1.test.」「root.example1.test.」となりますが、ユーザー名は最初の「.」を「@」にしてメールアドレスとして読替えます。これらは単なる文字列なので、BINDの動作には影響を与えません。シリアルナンバー(serial)は、ゾーン定義を変更する毎に必ず変更する必要があります。西暦(4桁の年)と月日(2桁ずつ)の後に01から99までの数字(2桁)が付いた10桁の数字で指定します。日が異なる場合には日付を、同じ日に変更が複数回あった場合には最後の2桁を変更するのを忘れないようにしてください。

### NSレコード
NSレコードは、このゾーンのDNSコンテンツサーバーである自分自身を定義します。

### MXレコード
MXレコードは受講生ドメインのメールサーバーを定義します。

NSレコードやMXレコードの定義では、右側にFQDNを入れるので、最後に必ず「.」を付けてください。また、先頭が空白になっていますが、これは前の行と同じ対象（この場合には＠）が省略されていることを示しています。

### Aレコード
Aレコードで名前とIPアドレスの対応を定義する箇所は、左側にホスト名、右側にIPアドレスが入ります。マシンのホスト名であるhost1や、その他のサービスで使う名前であるwwwやmaiとIPアドレスへの対応を記述しました。最後に「.」が付かない名前には、$ORIGINで定義しているゾーン名(ここではexample1.test.)が自動的に追加されます。

## 設定ファイルとゾーンファイルの書式確認
設定ファイルとゾーンファイルの作成が終わったら、書式の確認を行います。設定が多岐に渡るため、間違いがないかを確認するためのコマンドを使って確認します。

### 設定ファイルの書式確認と注意点
/etc/bind/named.confファイルの編集時、括弧やセミコロンの不足などは良くある設定ミスです。named-checkconfコマンドで/etc/bind/named.confに間違いがないか確認しましょう。

```
ubuntu@host1example1test:~$ named-checkconf /etc/bind/named.conf
```

この例のように、何も表示されなければ書式に問題がないということです。問題がある場合には、次のように問題がありそうな行番号が表示されます。

```
ubuntu@host1example1test:~$ named-checkconf /etc/bind/named.conf
/etc/named.conf:11: missing ';' before '}'
```

これは、listen-on portの{}にアドレスを追加するときにIPアドレスの後にセミコロンを記述するのを忘れたというエラーです。エラー表示を見ながら、こうした問題を取り除きましょう。

### ゾーンファイルの書式確認
ゾーンファイルを編集時、よくあるミスとしては、FQDNで記述すべきところを最後の.が抜けているなどがあります。named-checkzoneコマンドを使ってゾーンファイルに間違いがないか確認しましょう。引数は$ORIGINに指定したゾーン名と、確認を行うゾーンファイル名です。

```
ubuntu@host1example1test:~$ named-checkzone example1.test /etc/bind/example1.test.zone
zone example1.ltest/IN: loaded serial 2025050501
OK
```

書式に問題がなければ、この例のように設定したシリアルナンバーが表示され、OKと表示されます。設定が間違っている場合には、次のように問題のある行番号が表示されます。

```
ubuntu@host1example1test:~$ named-checkzone example1.test /etc/bind/example1.test.zone
zone example1.test/IN: NS 'host1.example1.test.example1.test' has no address records (A or AAAA)
zone example1.test/IN: not loaded due to errors.
```

この例では、NSレコードの右側に書いたホスト名がFQDNになっていないため、「host1.example1.test.example1.test」となってしまい、対応するAレコードが見つからないというエラーが発生しています。

## BINDの再起動と確認
BINDの設定を更新するため、再起動してみましょう。BINDの再起動は、systemctlコマンドでbind9ユニットを使います。

```
ubuntu@host1example1test:~$ sudo systemctl restart bind9
```

起動できたら、状態を確認します。

```
ubuntu@host1example1test:~$ systemctl status bind9
● named.service - BIND Domain Name Server
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-05-05 06:09:08 UTC; 3s ago
       Docs: man:named(8)
   Main PID: 3591 (named)
     Status: "running"
      Tasks: 4 (limit: 2272)
     Memory: 4.5M (peak: 4.7M)
        CPU: 107ms
     CGroup: /system.slice/named.service
             mq3591 /usr/sbin/named -f -u bind

May 05 06:09:08 host1example1local named[3591]: command channel listening on ::1#953
May 05 06:09:08 host1example1local named[3591]: managed-keys-zone: loaded serial 2
May 05 06:09:08 host1example1local named[3591]: zone 0.in-addr.arpa/IN: loaded serial 1
May 05 06:09:08 host1example1local named[3591]: zone 127.in-addr.arpa/IN: loaded serial 1
May 05 06:09:08 host1example1local named[3591]: zone localhost/IN: loaded serial 2
May 05 06:09:08 host1example1local named[3591]: zone 255.in-addr.arpa/IN: loaded serial 1
May 05 06:09:08 host1example1local named[3591]: zone example1.local/IN: loaded serial 2025050501
May 05 06:09:08 host1example1local named[3591]: all zones loaded
May 05 06:09:08 host1example1local systemd[1]: Started named.service - BIND Domain Name Server.
May 05 06:09:08 host1example1local named[3591]: running
```

Activeの欄に「active (running)」と表示されていることを確認します。

必要に応じて、表示を終了するためにQキーを押します。

## 自動起動の設定
システム起動時にBINDが自動的に起動されるようになっているか、systemctl is-enabledコマンドで確認します。

```
ubuntu@host1example1test:~$ sudo systemctl is-enabled bind9
alias
```

自動起動の設定がされている場合には、「enabled」または「alias」と表示されます。

## 参照するDNSサーバーの設定
DNSサーバーによる名前解決を確認する前に、参照するDNSサーバーの設定について確認、変更します。

### /etc/resolv.confによる参照DNSサーバーの設定
Linuxで名前解決を行うために参照するDNSサーバーは/etc/resolv.confに記述されます。

```
ubuntu@host1example1test:~$ sudo vi /etc/resolv.conf

ubuntu@host1example1test:~$ cat /etc/resolv.conf
nameserver 192.168.1.12
search example1.test
```

設定の内容は使用しているネットワーク環境によって異なりますが、参照するDNSサーバーを指定するnameserverの設定値として、インストール時に設定した「8.8.8.8」以外に設定されているのがNATネットワークのDHCPで設定された参照するDNSサーバーです。

### エディタで/etc/resolv.confを修正すると？
エディタで/etc/resolv.confを修正すると、設定は即時有効となります。

ただし、システムの再起動などによって修正変更は破棄されます。一時的に動作を変更したいような場合にはよいですが、継続して設定を適用したい場合には大元となるネットワークの設定を変更する必要があります。本章の最後では、ネットワークインターフェースの設定を変更する方法を解説しています。

### ネットワークインターフェースの名前を確認
まず、ネットワークインターフェースの名前を確認します。

```
ubuntu@host1example1test:~$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ee:b7:1d brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.12/24 brd 192.168.1.255 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet6 240f:32:57b8:1:a00:27ff:feee:b71d/64 scope global dynamic mngtmpaddr noprefixroute
       valid_lft 291sec preferred_lft 291sec
    inet6 fe80::a00:27ff:feee:b71d/64 scope link
       valid_lft forever preferred_lft forever
```

この例では、IPアドレス「192.168.1.12」からネットワークインターフェースは「enp0s3」と分かります。


### 起動時に読み込まれるresolv.confの設定の更新

OS起動時に/etc/resolv.confは、プログラムsystemd-resolvedにより/run/systemd/resolve/stub-resolv.confのリンクとなっています。
その為、/run/systemd/resolve/resolv.confを編集しリンクを貼り直します。

```
ubuntu@host1example1test:~$ sudo ls -l /etc/resolv.conf
lrwxrwxrwx 1 root root 39 Feb 16 20:58 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf

ubuntu@host1example1test:~$ sudo ln -fs /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

```
ubuntu@host1example1test:~$ sudo vi /etc/systemd/resolved.conf
[Resolve]
DNSStubListener=no

ubuntu@host1example1test:~$ sudo systemctl restart systemd-resolved
```

```
ubuntu@host1example1test:~$ sudo cat /etc/netplan/50-cloud-init.yaml
[sudo] password for ubuntu:
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
      - "192.168.1.12/24"
      nameservers:
        addresses:
        - 8.8.8.8
        search: []
      routes:
      - to: "default"
        via: "192.168.1.1"

ubuntu@host1example1test:~$ sudo vi /etc/netplan/50-cloud-init.yaml

ubuntu@host1example1test:~$ sudo cat /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
      - "192.168.1.12/24"
      nameservers:
        addresses:
        - 192.168.1.12
        search: [example1.test]
      routes:
      - to: "default"
        via: "192.168.1.1"
```



```
ubuntu@host1example1test:~$ sudo systemctl reboot
```

### /etc/resolv.confの変更の確認
起動後、/etc/resolv.confが変更されたことを確認します。

```
ubuntu@host1example1test:~$ cat /etc/resolv.conf
nameserver 192.168.1.12
search example1.test
```

このように、参照するDNSサーバーの設定が自分自身だけになりました。

## 名前解決の確認
BINDを起動し、名前解決が正常に行われるかを確認します。名前解決の確認にはdigコマンドが使用できます。

### digコマンドでホストの名前解決を確認
digコマンドでホスト名からIPアドレスが解決されることを確認します。digコマンドの引数に名前解決するホスト名を指定して実行します。

```
ubuntu@host1example1test:~$ dig host1.example1.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> host1.example1.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8355
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 1f2f3acc082ceae30100000068186513f091803433fb6364 (good)
;; QUESTION SECTION:
;host1.example1.test.          IN      A

;; ANSWER SECTION:
host1.example1.test.   10800   IN      A       192.168.1.12

;; Query time: 0 msec
;; SERVER: 192.168.1.12#53(192.168.1.12) (UDP)
;; WHEN: Mon May 05 07:13:23 UTC 2025
;; MSG SIZE  rcvd: 93
```

host1.example1.testのAレコードが正しく設定されていることが確認できます。

### 正しく名前解決が行えない場合
正しく動作しない場合、結果の下から3行にある「SERVER」の結果が「192.168.1.12」になっているかを確認してください。

### その他のAレコードを名前解決する
同様に、www.example1.testやmail.example1.testも確認してみます。

```
ubuntu@host1example1test:~$ dig www.example1.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> www.example1.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50636
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: bfec6c91de1603590100000068186568f20a05ed61bea5f8 (good)
;; QUESTION SECTION:
;www.example1.test.            IN      A

;; ANSWER SECTION:
www.example1.test.     10800   IN      A       192.168.1.12

;; Query time: 0 msec
;; SERVER: 192.168.1.12#53(192.168.1.12) (UDP)
;; WHEN: Mon May 05 07:14:48 UTC 2025
;; MSG SIZE  rcvd: 91
```

```
ubuntu@host1example1test:~$ dig mail.example1.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> mail.example1.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 41210
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 6d30f32079eea33a010000006818656da02c664311bc9a76 (good)
;; QUESTION SECTION:
;mail.example1.test.           IN      A

;; ANSWER SECTION:
mail.example1.test.    10800   IN      A       192.168.1.12

;; Query time: 0 msec
;; SERVER: 192.168.1.12#53(192.168.1.12) (UDP)
;; WHEN: Mon May 05 07:14:53 UTC 2025
;; MSG SIZE  rcvd: 92
```

### digコマンドでNSレコードを確認
ドメイン名の後にnsを指定すると、ドメインに登録されているNSレコード(ネームサーバーの情報)と、NSレコードで返されたホストのAレコードが表示されます。

```
ubuntu@host1example1test:~$ dig example1.test ns

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> example1.test ns
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 44674
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c2a1daeba429a6ce01000000681865b53b764f0a7969a375 (good)
;; QUESTION SECTION:
;example1.test.                        IN      NS

;; ANSWER SECTION:
example1.test.         10800   IN      NS      host1.example1.test.

;; ADDITIONAL SECTION:
host1.example1.test.   10800   IN      A       192.168.1.12

;; Query time: 0 msec
;; SERVER: 192.168.1.12#53(192.168.1.12) (UDP)
;; WHEN: Mon May 05 07:16:05 UTC 2025
;; MSG SIZE  rcvd: 107
```

### digコマンドでMXレコードを確認
ドメイン名の後にmxを指定すると、ドメインに登録されているMXレコード(メールサーバーの情報)と、MXレコードで返されたホストのAレコードが表示されます。

```
ubuntu@host1example1test:~$ dig example1.test mx

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> example1.test mx
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55253
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: aaec93e87a20012c01000000681865d3b615ea0d7704eb0a (good)
;; QUESTION SECTION:
;example1.test.                        IN      MX

;; ANSWER SECTION:
example1.test.         10800   IN      MX      10 mail.example1.test.

;; ADDITIONAL SECTION:
mail.example1.test.    10800   IN      A       192.168.1.12

;; Query time: 0 msec
;; SERVER: 192.168.1.12#53(192.168.1.12) (UDP)
;; WHEN: Mon May 05 07:16:35 UTC 2025
;; MSG SIZE  rcvd: 108
```

### 参照するDNSサーバーを指定したdigコマンドの実行
digコマンドの引数に「@IPアドレス」を指定することで、一時的に参照するDNSサーバーを変更することができます。DNSサーバーの動作が正しくないような場合の原因究明に利用できます。

```
ubuntu@host1example1test:~$ dig www.example1.test @192.168.1.12
```

## example2.testサーバーとtestサーバーの追加
example1.testドメインの設定ができたので、相互に名前解決ができるように仮想マシンを2台追加し、それぞれexample2.testドメイン、testドメインを管理するDNSサーバーとして設定します。

追加の手順は以下の情報を参考に、第2章および第3章の手順を繰り返し行ってください。

### 仮想マシン作成の留意事項
VirtualBoxで仮想マシンを追加で2台作成します。

既に作成している仮想マシンと同じように作成しますが、区別が付くように仮想マシンの名前をホスト名に合わせてください。

| 名前 |
|------------|
| host2.example2.test |
| host0.test |

### OSのインストール
作成した仮想マシンにOSをインストールします。

ホスト名とIPアドレスをそれぞれのサーバーに合わせて設定します。

| ホスト名 | IPアドレス | DNS |
|---|---|---|
| host2.example2.test | 192.168.1.13 | 192.168.1.13 |
| host0.test | 192.168.1.11 | 8.8.8.8 |

### 相互通信の確認
OSが起動したら、仮想マシン間で相互に通信ができることをpingコマンドを使って確認してください。

以下のように、各マシンから既に動作しているhost1.example1.testに向けてpingコマンドを実行してみます。

```
$ ping 192.168.1.12
```

## example2.testゾーンの設定
まず、example2.testゾーンの設定を行います。手順はexample1.testゾーンを設定した以下の手順と同じです。

1. BINDのインストールを行います。
1. named.confファイルにゾーンを追加します。
1. ゾーンファイルを作成し、レコードなどを記述します。
1. 設定ファイルに書式間違いが無いか確認します。
1. BINDの起動を行います。
1. BINDの自動起動の設定を行います。
1. /etc/resolv.confの参照するDNSサーバーの設定を確認します。
1. 名前解決の確認を行います。

以下、example1.testゾーンの設定と異なるポイントです。

### named.confの設定
named.confを設定します。listen-onに設定するIPアドレスが「192.168.1.13」になる点と、定義するゾーン名が「example2.test」になる点が異なります。

```
ubuntu@host2example2test:~$ sudo vi /etc/bind/named.conf
ubuntu@host2example2test:~$ cat /etc/bind/named.conf
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
include "/etc/bind/named.conf.my-zones";　← 追記設定を記載するファイルを指定
```

```
ubuntu@host2example2test:~$ sudo vi /etc/bind/named.conf.my-zones
ubuntu@host2example2test:~$ cat /etc/bind/named.conf.my-zones
zone "example2.test" IN { ← example1.testゾーンを指定
        type master;
        file "example2.test.zone"; ← example1.test用のゾーン定義ファイル名を指定
        allow-update { none; };
};
```

### ゾーンファイルの作成
ゾーンファイルを作成します。

```
ubuntu@host2example2test:~$ sudo vi /etc/bind/example2.test.zone
ubuntu@host2example2test:~$ cat /etc/bind/example2.test.zone
$TTL 3H
$ORIGIN example2.test.
@       IN SOA  host2 root (
                                        2025050501       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host2.example2.test.
        MX 10   mail.example2.test.

host2   A       192.168.1.13
www     A       192.168.1.13
mail    A       192.168.1.13
```

### 設定ファイルの確認
設定ファイルの書式に間違いがないか、確認します。

```
ubuntu@host2example2test:~$ named-checkconf /etc/bind/named.conf
```

```
ubuntu@host2example2test:~$ named-checkzone example2.test /etc/bind/example2.test.zone
zone example2.test/IN: loaded serial 2025050501
OK
```


### Bindの再起動
bind9を再起動し、自動起動設定を確認します。

```
ubuntu@host2example2test:~$ sudo systemctl restart bind9
ubuntu@host2example2test:~$ systemctl status bind9
● named.service - BIND Domain Name Server
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-05-05 08:44:44 UTC; 8s ago
       Docs: man:named(8)
   Main PID: 2159 (named)
     Status: "running"
      Tasks: 4 (limit: 2272)
     Memory: 4.5M (peak: 4.7M)
        CPU: 108ms
     CGroup: /system.slice/named.service
             mq2159 /usr/sbin/named -f -u bind

May 05 08:44:44 host2example2local named[2159]: command channel listening on ::1#953
May 05 08:44:44 host2example2local named[2159]: managed-keys-zone: loaded serial 2
May 05 08:44:44 host2example2local named[2159]: zone 0.in-addr.arpa/IN: loaded serial>
May 05 08:44:44 host2example2local named[2159]: zone 127.in-addr.arpa/IN: loaded seri>
May 05 08:44:44 host2example2local named[2159]: zone 255.in-addr.arpa/IN: loaded seri>
May 05 08:44:44 host2example2local named[2159]: zone example2.local/IN: loaded serial>
May 05 08:44:44 host2example2local named[2159]: zone localhost/IN: loaded serial 2
May 05 08:44:44 host2example2local named[2159]: all zones loaded
May 05 08:44:44 host2example2local named[2159]: running
May 05 08:44:44 host2example2local systemd[1]: Started named.service - BIND Domain Na>
```

```
ubuntu@host2example2test:~$ sudo systemctl is-enabled bind9
alias
```

### ネットワーク設定の変更
Ubuntuのネットワーク設定に関連する、/etc/resolv.conf(resolvedプログラム)とnetplanの設定を変更します。

```
ubuntu@host2example2test:~$ sudo ln -fs /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

```
ubuntu@host1example1test:~$ sudo vi /etc/systemd/resolved.conf
[Resolve]
DNSStubListener=no
```

```
ubuntu@host2example2test:~$ sudo vi /etc/netplan/50-cloud-init.yaml

ubuntu@host2example2test:~$ sudo cat /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
      - "192.168.1.13/24"
      nameservers:
        addresses:
        - 192.168.1.13
        search: [example2.test]
      routes:
      - to: "default"
        via: "192.168.1.1"
```

### システムの再起動
ネットワーク設定を反映する為、Ubuntuを再起動します。

```
ubuntu@host2example2test:~$ sudo systemctl reboot
```

### DNSレコードの確認
再起動完了後、DNSサーバで正常に回答が得られるか確認します。

```
ubuntu@host2example2test:~$ dig host2.example2.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> host2.example2.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 25440
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c3e461a7154b7e370100000068187e456ea67ac7c750d713 (good)
;; QUESTION SECTION:
;host2.example2.test.          IN      A

;; ANSWER SECTION:
host2.example2.test.   10800   IN      A       192.168.1.13

;; Query time: 0 msec
;; SERVER: 192.168.1.13#53(192.168.1.13) (UDP)
;; WHEN: Mon May 05 09:00:53 UTC 2025
;; MSG SIZE  rcvd: 93

ubuntu@host2example2test:~$ dig www.example2.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> www.example2.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24422
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: ce1045269f0ded900100000068187e4a0e6c1acef196fa87 (good)
;; QUESTION SECTION:
;www.example2.test.            IN      A

;; ANSWER SECTION:
www.example2.test.     10800   IN      A       192.168.1.13

;; Query time: 0 msec
;; SERVER: 192.168.1.13#53(192.168.1.13) (UDP)
;; WHEN: Mon May 05 09:00:58 UTC 2025
;; MSG SIZE  rcvd: 91

ubuntu@host2example2test:~$ dig mail.example2.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> mail.example2.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21839
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 5bb70f42b0d26cb70100000068187e4f81181f7ae37bf7ea (good)
;; QUESTION SECTION:
;mail.example2.test.           IN      A

;; ANSWER SECTION:
mail.example2.test.    10800   IN      A       192.168.1.13

;; Query time: 0 msec
;; SERVER: 192.168.1.13#53(192.168.1.13) (UDP)
;; WHEN: Mon May 05 09:01:03 UTC 2025
;; MSG SIZE  rcvd: 92

ubuntu@host2example2test:~$ dig example2.test ns

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> example2.test ns
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 46180
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 1d882f4fe9dac0e50100000068187e7ba7cf1023cd3734e8 (good)
;; QUESTION SECTION:
;example2.test.                        IN      NS

;; ANSWER SECTION:
example2.test.         10800   IN      NS      host2.example2.test.

;; ADDITIONAL SECTION:
host2.example2.test.   10800   IN      A       192.168.1.13

;; Query time: 0 msec
;; SERVER: 192.168.1.13#53(192.168.1.13) (UDP)
;; WHEN: Mon May 05 09:01:47 UTC 2025
;; MSG SIZE  rcvd: 107

ubuntu@host2example2test:~$ dig example2.test mx

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> example2.test mx
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23307
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 32ca3ae6331aa84a0100000068187e80fb23bc833ff7dfe2 (good)
;; QUESTION SECTION:
;example2.test.                        IN      MX

;; ANSWER SECTION:
example2.test.         10800   IN      MX      10 mail.example2.test.

;; ADDITIONAL SECTION:
mail.example2.test.    10800   IN      A       192.168.1.13

;; Query time: 0 msec
;; SERVER: 192.168.1.13#53(192.168.1.13) (UDP)
;; WHEN: Mon May 05 09:01:52 UTC 2025
;; MSG SIZE  rcvd: 108

ubuntu@host2example2test:~$ dig www.example2.test @192.168.1.13

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> www.example2.test @192.168.1.13
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16932
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c852859fb4f1368b0100000068187e8ad7718da8b1b2098f (good)
;; QUESTION SECTION:
;www.example2.test.            IN      A

;; ANSWER SECTION:
www.example2.test.     10800   IN      A       192.168.1.13

;; Query time: 0 msec
;; SERVER: 192.168.1.13#53(192.168.1.13) (UDP)
;; WHEN: Mon May 05 09:02:02 UTC 2025
;; MSG SIZE  rcvd: 91
```


## 上位testゾーンのDNSコンテンツサーバーの設定
example1.testゾーン、example2.testゾーンの設定が完了したら、上位ゾーンにあたるtestゾーンの設定を行います。手順はexample1.testゾーンやexample2.testゾーンを設定した以下の手順と同じです。

1. BINDのインストールを行います。
1. named.confファイルにゾーンを追加します。
1. ゾーンファイルを作成し、レコードなどを記述します。
1. 設定ファイルに書式間違いが無いか確認します。
1. BINDの起動を行います。
1. BINDの自動起動の設定を行います。
1. /etc/resolv.confの参照するDNSサーバーの設定を確認します。
1. 名前解決の確認を行います。

以下、example1.testゾーンの設定と異なるポイントです。

### named.confの設定
named.confを設定します。listen-onに設定するIPアドレスが192.168.1.11になる点と、定義するゾーン名が.testになる点が異なります。また、このDNSサーバーはDNSキャッシュサーバーとしても動作させるので、recursionの設定を「yes;」のままにしておきます。

```
ubuntu@host0test:~$ sudo vi /etc/bind/named.conf
ubuntu@host0test:~$ cat /etc/bind/named.conf
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";
include "/etc/bind/named.conf.my-zones";
```

```
ubuntu@host0test:~$ sudo vi /etc/bind/named.conf.my-zones
ubuntu@host0test:~$ cat /etc/bind/named.conf.my-zones
zone "test" IN {
        type master;
        file "test.zone";
        allow-update { none; };
};
```

```
ubuntu@host0test:~$ sudo vi /etc/bind/named.conf.options
ubuntu@host0test:~$ cat /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";
        //directory "/etc/bind";
        listen-on port 53 { 127.0.0.1; 192.168.1.11; };
        listen-on-v6 port 53 { ::1; };
        allow-query     { any; };

        recursion yes;

        dnssec-validation auto;
};
```


### ゾーンファイルの作成
ゾーンファイルを作成します。
example1.testとexample2.testを委譲するNSレコードも記載します。

```
ubuntu@host0test:~$ sudo vi /etc/bind/test.zone
ubuntu@host0test:~$ cat /etc/bind/test.zone
$TTL 3H
$ORIGIN test.
@       IN SOA  host0 root (
                                        2025050501       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host0.test.
example1.test. NS      host1.example1.test.
example2.test. NS      host2.example2.test.

host0   A       192.168.1.11
host1.example1.test.     A       192.168.1.12
host2.example2.test.     A       192.168.1.13
```

### 設定ファイルの確認
設定ファイルの書式に間違いがないか、確認します。

```
ubuntu@host0test:~$ named-checkconf /etc/bind/named.conf
```

```
ubuntu@host0test:~$ named-checkzone test /var/cache/bind/test.zone
zone test/IN: loaded serial 2025050501
OK
```

### Bindの再起動
bind9を再起動し、自動起動設定を確認します。

```
ubuntu@host0test:~$ sudo systemctl restart bind9
[sudo] password for ubuntu:
ubuntu@host0test:~$ systemctl status bind9
● named.service - BIND Domain Name Server
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: en>
     Active: active (running) since Mon 2025-05-05 15:18:57 UTC; 7s ago
       Docs: man:named(8)
   Main PID: 1956 (named)
     Status: "running"
      Tasks: 4 (limit: 2272)
     Memory: 5.1M (peak: 5.4M)
        CPU: 241ms
     CGroup: /system.slice/named.service
             mq1956 /usr/sbin/named -f -u bind

May 05 15:18:57 host0test named[1956]: command channel listening on ::1#953
May 05 15:18:57 host0test named[1956]: managed-keys-zone: loaded serial 16
May 05 15:18:57 host0test named[1956]: zone test/IN: loaded serial 2025050501
May 05 15:18:57 host0test named[1956]: zone 0.in-addr.arpa/IN: loaded serial 1
May 05 15:18:57 host0test named[1956]: zone 127.in-addr.arpa/IN: loaded serial 1
May 05 15:18:57 host0test named[1956]: zone 255.in-addr.arpa/IN: loaded serial 1
May 05 15:18:57 host0test named[1956]: zone localhost/IN: loaded serial 2
May 05 15:18:57 host0test named[1956]: all zones loaded
May 05 15:18:57 host0test named[1956]: running
May 05 15:18:57 host0test systemd[1]: Started named.service - BIND Domain Name
```

```
ubuntu@host0test:~$ sudo systemctl is-enabled bind9
alias
```

### ネットワーク設定の変更
Ubuntuのネットワーク設定に関連する、/etc/resolv.conf(resolvedプログラム)とnetplanの設定を変更します。

```
ubuntu@host0test:~$ sudo ln -fs /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

```
ubuntu@host0test:~$ sudo vi /etc/systemd/resolved.conf
[Resolve]
DNSStubListener=no
```

```
ubuntu@host0test:~$ sudo vi /etc/netplan/50-cloud-init.yaml

ubuntu@host0test:~$ sudo cat /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
      - "192.168.1.11/24"
      nameservers:
        addresses:
        - 192.168.1.11
        search: [test]
      routes:
      - to: "default"
        via: "192.168.1.1"
```

### システムの再起動
ネットワーク設定を反映する為、Ubuntuを再起動します。

```
ubuntu@host0test:~$ sudo systemctl reboot
```

### DNSレコードの確認
再起動完了後、DNSサーバで正常に回答が得られるか確認します。
```
ubuntu@host0test:~$ dig host0.test

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> host0.test
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51412
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: cd4484ef3fccd0ce010000006818d88f87036ee71c3ae627 (good)
;; QUESTION SECTION:
;host0.test.                    IN      A

;; ANSWER SECTION:
host0.test.             10800   IN      A       192.168.1.11

;; Query time: 0 msec
;; SERVER: 192.168.1.11#53(192.168.1.11) (UDP)
;; WHEN: Mon May 05 15:26:07 UTC 2025
;; MSG SIZE  rcvd: 83
```

```
ubuntu@host0test:~$ dig example1.test ns

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> example1.test ns
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34417
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: a0db2494cbd2f000010000006818d8a5b6107ddb44449d5d (good)
;; QUESTION SECTION:
;example1.test.                 IN      NS

;; ANSWER SECTION:
example1.test.          10800   IN      NS      host1.example1.test.

;; Query time: 11 msec
;; SERVER: 192.168.1.11#53(192.168.1.11) (UDP)
;; WHEN: Mon May 05 15:26:29 UTC 2025
;; MSG SIZE  rcvd: 90
```

```
ubuntu@host0test:~$ dig example2.test ns

; <<>> DiG 9.18.30-0ubuntu0.24.04.2-Ubuntu <<>> example2.test ns
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31608
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: b3d43799c24d59db010000006818d8b693cc76881afc95af (good)
;; QUESTION SECTION:
;example2.test.                 IN      NS

;; ANSWER SECTION:
example2.test.          10800   IN      NS      host2.example2.test.

;; Query time: 40 msec
;; SERVER: 192.168.1.11#53(192.168.1.11) (UDP)
;; WHEN: Mon May 05 15:26:46 UTC 2025
;; MSG SIZE  rcvd: 90
```



### example1.testとexapmle2.testのDNSサーバの名前解決先の変更
example1.test・example2.testを管理するDNSサーバのネットワーク設定のうち、
名前解決を行うDNSサーバを上位DNSにあたるtestゾーンを管理する「192.168.1.11」に変更し、
設定を反映させる為、Ubuntuを再起動します。

```
ubuntu@host1example1test:~$ sudo vi /etc/netplan/50-cloud-init.yaml
```

```
ubuntu@host1example1test:~$ sudo cat /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
      - "192.168.1.12/24"
      nameservers:
        addresses:
        - 192.168.1.11
        search: [example1.test]
      routes:
      - to: "default"
        via: "192.168.1.1"
```

```
ubuntu@host1example1test:~$ sudo systemctl reboot
```

```
ubuntu@host2example2test:~$ sudo vi /etc/netplan/50-cloud-init.yaml
```

```
ubuntu@host2example2test:~$ sudo cat /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
      - "192.168.1.13/24"
      nameservers:
        addresses:
        - 192.168.1.11
        search: [example2.test]
      routes:
      - to: "default"
        via: "192.168.1.1"
```

```
ubuntu@host2example2test:~$ sudo systemctl reboot
```

## 次章のメールサーバ構築に向けて
MXレコードの名前解決は、次の章で行うメールサーバーを動かす上での前提条件となります。きちんと名前解決が行えていることを確認した上で次の章に進んでください。

## うまく名前解決が行えない場合には
サーバー相互の名前解決がうまく動作しない場合には、以下の点を確認してください。

- DNSサーバーが起動している
- DNSサーバーが名前解決に応答している
- pingコマンドでお互いにIP通信が行えている
- ファイアウォールの設定が変更されている
- 参照するDNSサーバーの設定が「192.168.56.100」に変更されている

\pagebreak
