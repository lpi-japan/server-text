# DNSサーバーの構築
ネットワークサービスを使うための土台となる名前解決のサービス(DNS)を設定します。自分のDNSサーバーを他のコンピューターから参照できるように設定をします。
DNSに問い合わせを行うコマンドに慣れ、ドメインを管理するBINDプログラムの設定ファイルを扱います。

## 用語集
### ドメイン名とゾーン
組織に割り当てられてインターネットで使用する名前をドメイン名と呼びます。ドメイン名はICANN(Internet Corporation for Assigned Names and Numbers)により管理されています。DNSでドメイン名を設定するときは、ドメインではなく「ゾーン」と呼びます。

### FQDN
ドメイン名表記で、一番右に「.」（ドット）でルートドメインまでを記述する方式をFQDNと呼びます。

### DNS
DNS(Domain Name System)は、IPアドレスと対応するホスト名を登録しておき、プログラムからの問い合わせに応じてIPアドレスやホスト名を返答するシステムです。

### ゾーン
DNSの名前空間の一部分を取り出したものをゾーンとよびます。ゾーンは、DNSを管理する単位として使われます。ゾーンには、ドメイン、サブドメイン、ホスト名などが含まれています。DNS名前空間はツリー構造で表されますが、ゾーンは特定のノード以下の一部または全部を含む部分です。

### DNSキャッシュサーバー
プログラムからの名前問い合わせを代行して、様々なDNSサーバーへ名前問い合わせを行って結果を返却するサーバーです。調べた結果をキャッシュしておき、次回問い合わせ時にキャッシュの情報を返すことから、DNSキャッシュサーバーと呼ばれます。クライアントのネットワーク設定でDNSサーバーと呼んだときには、DNSキャッシュサーバーのことを指します。

### DNSコンテンツサーバー
委託されたゾーンのIPアドレスやホスト名を管理するDNSサーバーです。取得したドメイン名を利用するには、DNSコンテンツサーバーを用意して設定する必要があります。

### リゾルバ
ドメイン名をもとにIPアドレス情報の検索をしたり、IPアドレスからドメイン情報の検索を行う、名前解決を行うプログラムのことです。

### BIND
BIND(Berkeley Internet Name Domain)は、Linuxと組み合わせて多く使用されているDNSサーバーのソフトウェアです。DNSキャッシュサーバーとしても、DNSコンテンツサーバーとしても利用することができます。

### グルーレコード
管理を委任しているゾーンについての問合せに対して、DNSサーバーが委任先のゾーンのDNSコンテンツサーバーのアドレスを返す際に、追加情報として必要となる委任先DNSコンテンツサーバーのAレコードをグルーレコードといいます。

### Aレコード
名前に対してIPアドレスを指定するためのレコードです。

### NS(Name Server)レコード
ゾーンの権威を持つDNSコンテンツサーバーを指定するためのレコードです。

### MX(Mail eXchange)レコード
メールアドレスに利用するドメイン名を定義するためのレコードです。メールサーバーの障害にも対応するために、複数個のメールサーバーを記述でき、プリファレンス値の低いサーバーにメール配信が優先されます。

## DNSの仕組み
インターネットでのコンピューター同士の通信は、IP(Internet Protocol)を使って行われています。IP通信には相手のIPアドレスが必要ですが、インターネット上の大量のコンピューターをIPアドレスで識別するのは困難です。そこでドメイン名やホスト名という考え方が導入されました。ドメイン名は組織を表し、ホスト名はその組織が管理しているコンピューターです。表記するときは「ホスト名.ドメイン名」とドット区切りで表記しますが、両方を合わせてホスト名と呼ぶこともあります。

インターネットの研究が始まった当初はIPアドレスが割り当てられたコンピューターの数も数えるほどだったので、ホスト名とIPアドレスの対応関係はファイルに記述されて、定期的に更新されていました。この仕組みは今でも残っており、Linuxでは/etc/hostsがそのファイルです。しかし、インターネットが広まるに従って、ホストファイルでは管理しきれなくなってきました。そこで登場したのがDNS(Domain Name System)です。

ドメイン名を割り当てられた組織毎にDNSコンテンツサーバーを用意します。DNSコンテンツサーバーの管理者は、そのドメインに所属しているホスト名と割り当てられたIPアドレスをDNSコンテンツサーバー登録します。ホストにアクセスしたい利用者は、そのホストが所属するドメインのDNSコンテンツサーバーに問い合わせを行うことで、IPアドレスを得ることができます。しかし、ユーザが、アクセスする毎にどのDNSコンテンツサーバーに問い合わせをするのかを調べることは面倒です。DNSキャッシュサーバーは、その調査を自動的に行ってくれます。また、調査結果を一定時間キャッシュし、毎回調べなくても良いようにしてくれます。

DNSの仕組みでは、ゾーン（ドメイン）の管理権限がそれぞれのDNS管理者に委譲されているので、ホストファイルのような一元管理ではなく、分散管理となります。管理作業が分担されていて更新も頻繁に行われるので、リアルタイムにホスト名とIPアドレスの対応関係を調べることができる仕組みとなっています。

## ドメインの構造
DNSが取り扱うドメイン名は設計上、ルートドメインを頂点とした階層型のツリー構造となっています。ちょうど、コンピューターのファイルシステムがルートディレクトリを頂点としたツリー構造になっているのと同じだと考えてよいでしょう。そして、その配下にあるドメインはサブドメインとよばれます。ドメインの階層型のツリーは、ルートドメインとたくさんのサブドメインから構成されています。

### ルートドメイン
ルートドメインは、ドメイン名の開始点です。通常は省略されますが、ドメイン名として記述する際には「.」（ドット）で表されます。

### トップレベルドメイン
トップレベルドメインには、.comや.orgのような組織別ドメインや、.jpのような国別ドメインがあります。また、日本の場合にはexample.co.jpのような組織種別型ドメインと、example.jpのような汎用JPドメインなどがあります。

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

サブドメイン化は、上位のドメイン（表記上の右側）を管理している管理者が行います。たとえば、tokyo.example.co.jpドメインまでのサブドメインの階層は次のようになっています。

1. jpドメインはルートドメインのサブドメイン
1. co.jpドメインはjpドメインのサブドメイン
1. example.co.jpドメインはco.jpドメインのサブドメイン
1. tokyo.example.co.jpドメインはexample.co.jpドメインのサブドメイン

### ドメイン名の取得
ドメイン名を取得するということは、上位のドメイン名の管理者にサブドメインを作ってもらい、管理権限を委譲してもらうということになります。独自の短いドメイン名を取得したいのであればトップレベルドメインを管理している管理組織からサブドメイン化してもらうことになりますが、登録料などの費用がかかります。短いドメイン名にこだわらない、費用をかけたくない場合には、既にドメイン名を取得している管理者からサブドメインの管理権限を委譲してもらうこともできます。

## DNSを使った名前解決と再帰問い合わせ
DNSを使って名前を解決する、すなわち名前からIPアドレスを調べる時には、次のような手順で調査が行われます。

1. クライアントは、自分の組織やプロバイダーのDNSキャッシュサーバーへ問い合わせます。
1. DNSキャッシュサーバーは、ルートサーバーに「jp」を管理するDNSコンテンツサーバーのIPアドレスを問い合わせます。ルートサーバーは、「jp」を管理するDNSコンテンツサーバーのIPアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、「jp」を管理するDNSコンテンツサーバーへ、サブドメイン「alpha.jp」を管理するDNSコンテンツサーバーのIPアドレスを問い合わせます。「jp」を管理するDNSコンテンツサーバーは、サブドメイン「alpha.jp」を管理するDNSコンテンツサーバーのIPアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、「alpha.jp」を管理するDNSコンテンツサーバーへ、「www.alpha.jp」のIPアドレスを問い合わせます。「alpha.jp」を管理するDNSコンテンツサーバーは、「www.alpha.jp」のIPアドレスをDNSキャッシュサーバーへ返します。
1. DNSキャッシュサーバーは、クライアントに「www.alpha.jp」のIPアドレスを返します。

このように、DNSキャッシュサーバーがルートサーバーから順番に問い合わせを行い、最終的に目的のドメインを管理するDNSコンテンツサーバーまで問い合わせをしていくことを「再帰問い合わせ」と呼びます。

## 演習で構築するDNSの概略
2つのドメイン名（alpha.jpとbeta.jp）を設定し、相互に名前解決ができるようにDNSコンテンツサーバーを構築します。また、サブドメイン化してゾーンの管理権限を委譲する設定も行います。以下の3つのDNSサーバーを構築します。

- jpゾーンのマシン
alpha.jpとbeta.jpをサブドメイン化し、ゾーン管理権限の委譲を設定します。またDNSキャッシュサーバーとしても動作します。

- alpha.jpゾーンのマシン
alpha.jpゾーンを管理するDNSコンテンツサーバーとして設定します。

- beta.jpゾーンのマシン
beta.jpゾーンを管理するDNSコンテンツサーバーとして設定します。

## 演習の手順
3台のマシンを相互に接続し、相互にDNSを参照できるように設定します。追加でマシン2台分の仮想マシンの作成やOSのインストールなどが必要となります。以下の作業を行っていきます。

1. DNSサーバーソフトウェアであるBINDを使って、alpha.jpゾーンを管理するDNSコンテンツサーバーを設定します。
1. jpゾーンおよびbeta.jpゾーンの仮想マシンを作成し、OSをインストールします。それぞれIPアドレスなどの設定が異なる点に注意してください。
1. beta.jpゾーンを管理するDNSコンテンツサーバーを設定します。
1. jpゾーンを管理するDNSコンテンツサーバーを設定します。alpha.jpゾーンおよびbeta.jpゾーンに対する権限委譲を設定します。
1. alpha.jpゾーンとbeta.jpゾーンのDNSを相互に参照できることを確認します。

以降の章(特にメール)ではDNSサーバーが正しく設定されていることを前提としているので、この章の演習内容が完全に終わっている必要があります。

## 演習で使うアドレスとドメイン
演習で使用する3台のサーバーのドメイン名、ホスト名、IPアドレスは以下の通りです。

|ドメイン名|ホスト名|IPアドレス|
|---|---|---|
| jp. | host0.jp. | 192.168.56.100 |
| alpha.jp. | host1.alpha.jp. | 192.168.56.101 |
| beta.jp. | host2.alpha.jp. | 192.168.56.102 |

## アドレス解決の流れ
alpha.jpのマシン(192.168.56.101)がホストwww.beta.jpを解決するときの動きを追ってみましょう。

WebブラウザーでWebページを表示させるとき、DNSキャッシュサーバーのことは特に意識せずWebサイトのアドレスを入力しています。ここではWebアドレスを入力してリクエストしてページが表示されるまでの流れを例に、DNSがどのように動くのか簡単に説明します。

1. alpha.jpマシンは、Webブラウザーにアドレスとしてwww.beta.jpを入力します。
1. Webブラウザーは、Linuxのリゾルバに問い合わせます。
1. リゾルバは、/etc/resolv.confファイルで指定されているDNSキャッシュサーバー（192.168.56.100）へ問い合わせます。
1. DNSキャッシュサーバーは、jpゾーンのDNSコンテンツサーバーを参照し、beta.jpゾーンのDNSコンテンツサーバーのIPアドレス（192.168.56.102）を返します。
1. DNSキャッシュサーバーは、beta.jpゾーンのDNSコンテンツサーバーに問い合わせします。
1. beta.jpゾーンのDNSコンテンツサーバーは、www.beta.jpホストのIPアドレス（192.168.56.102）を返します。
1. DNSキャッシュサーバーは、結果をalpha.jpマシンへ返します。
1. Webブラウザーは、www.beta.jpにHTTPでアクセスし、Webページを受け取って表示します。

実際のインターネットでのDNSの名前解決ではルートゾーンから順番に再帰問い合わせを行いますが、演習環境ではDNSキャッシュサーバー自身がjpゾーンのDNSコンテンツサーバーでもあるため、すぐにbeta.jpのDNSコンテンツサーバーに関する情報を返す点が異なります。

## DNSコンテンツサーバーの設定
DNSコンテンツサーバーのソフトウェアとしてBINDをインストールして、各ゾーンの設定を行います。

### chroot機能を利用したBINDのセキュリティ
chroot機能はセキュリティを高めるために、プログラムに対して特定のディレクトリ以外にはアクセスできないようにするための機能です。

chroot機能を使ってBINDを実行すると、bindプロセスは/var/named/chrootディレクトリを/（ルート）ディレクトリとして動作します。たとえば、bindプロセスが/etcディレクトリにアクセスしても、実際にアクセスされるのは/var/named/chroot/etcディレクトリになるので、パスワードその他のセキュリティに関する情報にアクセスできません。

DNSという重要なサービスを提供している関係上、BINDはインターネット上の数多くのサーバーで実行されており、セキュリティの攻撃を受けやすくなっています。万が一、BINDがセキュリティ攻撃を受けて乗っ取られてしまったとしても、chroot機能のおかげでbindプロセスがアクセスできるディレクトリを限定することができるので、システムのその他のファイルへのアクセスを妨げ、被害を最小限に食い止めることができます。

AlmaLinuxでは、シンボリックリンクやマウントなどのLinuxの機能を使って、chroot機能を使った場合でもほとんど管理方法が変わらないように工夫されています。そのため、本書でもchroot機能を有効にします。追加でbind-chrootパッケージのインストールが必要だったり、systemctlコマンドで扱うユニット名が異なる点に注意してください。

### ゾーンを設定する流れ
ゾーンを設定するために必要な作業は以下のようになります。

1. BINDのインストール
1. named.confファイルにゾーンを追加
1. ゾーンファイルを作成し、レコードなどを記述
1. 設定ファイルに書式間違いが無いか確認
1. BINDの起動
1. BINDの自動起動の設定
1. ファイアーウォールの設定を変更
1. 名前解決の確認

BINDの基本的な設定ファイルとして/etc/named.confファイルがあります。/etc/named.confにBINDの基本的な設定とゾーンの定義を追加します。さらにゾーンの詳細を定義するゾーンファイルを/var/namedディレクトリに作ります。

## BINDのインストール
BINDのインストールには、bindパッケージとbind-chrootパッケージが必要です。必要なパッケージがインストールされていないときには、dnfコマンドでインストールします。

dnf install bind bind-chroot

## /etc/named.confの基本設定
/etc/named.confファイルにBINDをDNSコンテンツサーバーとして動作させる基本設定を行います。

vi /etc/named.conf
※コメントなどは省略しています。

options {
	listen-on port 53 { 127.0.0.1; 192.168.56.101; };	←サーバー自身のIPアドレスを追加
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };	← localhostをanyに変更

	recursion no;	←yesをnoに変更

	dnssec-validation yes;

	managed-keys-directory "/var/named/dynamic";
	geoip-directory "/usr/share/GeoIP";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";

	include "/etc/crypto-policies/back-ends/bind.config";
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

zone "alpha.jp" IN {
	type master;
	file "alpha.jp.zone";
	allow-update { none; };
};	

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

設定の内容は以下の通りです。

### 問い合わせを受け付けるアドレスの設定
デフォルトのnamed.confファイルは、127.0.0.1(ローカルループバックインターフェース)への問い合わせにしか返答しない設定なので、外部からの問い合わせを受けられるようにサーバー自身のIPアドレスである「192.168.56.101;」をlisten-onに追加します。後ほど設定するbeta.jpサーバーやjpサーバーの場合にはそれぞれのサーバーのIPアドレスを記述します。

### 問い合わせを許可するアドレスの設定
allow-queryにはデフォルトでは「localhost;」と設定されていて、ローカルからしかDNS問い合わせができないようになっています。DNSコンテンツサーバーはインターネット上のすべての人から参照できなければならないので、この設定を「any」に変更します。

### DNSコンテンツサーバーとしての設定
DNSコンテンツサーバーでは、recursion（再帰問合せ）を禁止にしておく必要があります。そのため、recursionに「no」を設定します。ただし、jpサーバーの場合にはDNSキャッシュサーバーとしても動作させるのでyesのままにしておく必要があります。

### 正引きゾーンの追加
/etc/named.confにゾーン定義を追加します。上記例では以下のように設定しています。

zone "alpha.jp" IN {
	type master;
	file "alpha.jp.zone";
	allow-update { none; };
};	

## ゾーンファイルの作成
named.confで定義したゾーンの内容を記述するゾーンファイルの作成を行います。

### ゾーンファイルの準備
ゾーンファイルのテンプレートとなる/var/named/named.emptyファイルをコピーします。新たに作成するファイルのファイル名はゾーン定義のfile句で指定したファイル名を指定します。alpha.jpゾーンであればalpha.jp.zoneとなります。また、コピー元と同じ所有権、パーミッションにするため、cpコマンドに-pオプションを付けて実行します。

cd /var/named
cp -p named.empty alpha.jp.zone
ls -l alpha.jp.zone
-rw-r-----. 1 root named 152 Jul 18 16:51 alpha.jp.zone

### ゾーンファイルの修正
コピーした/var/named/alpha.jp.zoneファイルを修正します。

vi /var/named/alpha.jp.zone

$TTL 3H
$ORIGIN alpha.jp.
@       IN SOA  host1 root (
                                        2023100901       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host1.alpha.jp.
        MX 10   mail.alpha.jp.

host1   A       192.168.56.101
www     A       192.168.56.101
mail    A       192.168.56.101


#### $TTL
$TTLは、このゾーン定義ファイル内の記述のTTL（Time to Live・生存時間・有効期間）が3時間であることをデフォルト指定しています。

#### $ORIGIN
$ORIGINは、このゾーン定義が対象としているゾーン名を指定します。ゾーン定義内のホスト名はすべてFQDNで最後が「.」で終わる必要がありますが、省略された場合には$ORIGINで指定されたゾーン名で補完されます。たとえば、「www」という記述は「www.alpha.jp.」と補完されて扱われます。

#### SOAレコード
＠から始まるゾーンファイルの最初のレコードはSOAレコードです。このゾーンの管理ポリシーについて設定します。SOAレコードの先頭には＠がありますが、これは$ORIGINで指定したゾーン（ここではalpha.jp.）に置き換えられます。host1はこのDNSコンテンツサーバーのホスト名、rootは管理者ユーザーです。どちらもゾーン名が補完されて、「host1.alpha.jp.」「root.alpha.jp.」となりますが、ユーザー名は最初の「.」を「@」にしてメールアドレスとして読み替えます。これらは単なる文字列なので、BINDの動作には影響を与えません。シリアルナンバー(serial)は、ゾーン定義を変更する毎に必ず変更する必要があります。西暦(4桁の年)と月日(2桁ずつ)の後に01から99までの数字(2桁)が付いた10桁の数字で指定します。日が異なる場合には日付を、同じ日に変更が複数回あった場合には最後の2桁を変更するのを忘れないようにしてください。

#### NSレコード
NSレコードは、このゾーンのDNSコンテンツサーバーである自分自身を定義します。

#### MXレコード
MXレコードは受講生ドメインのメールサーバーを定義します。

NSレコードやMXレコードの定義では、右側にFQDNを入れるので、最後に必ず「.」を付けてください。また、先頭が空白になっていますが、これは前の行と同じ対象（この場合には＠）が省略されていることを示しています。

#### Aレコード
Aレコードで名前とIPアドレスの対応を定義する箇所は、左側にホスト名、右側にIPアドレスが入ります。マシンのホスト名であるhost1や、その他のサービスで使う名前であるwwwやmaiとIPアドレスへの対応を記述しました。最後に「.」が付かない名前には、$ORIGINで定義しているゾーン名(ここではalpha.jp.)が自動的に追加されます。

### 設定ファイルの書式確認と注意点
/etc/named.confファイルの編集時、括弧やセミコロンの不足などは良くある設定ミスです。named-checkconfコマンドで/etc/named.confに間違いがないか確認しましょう。

named-checkconf

この例のように、何も表示されなければ書式に問題がないということです。問題がある場合には、次のように問題がありそうな行番号が表示されます。

named-checkconf
/etc/named.conf:11: missing ';' before '}'

これは、listen-on portの{}にアドレスを追加するときにIPアドレスの後にセミコロンを記述するのを忘れたというエラーです。エラー表示を見ながら、こうした問題を取り除きましょう。

### ゾーンファイルの書式確認
ゾーンファイルを編集時、よくあるミスとしては、FQDNで記述すべきところを最後の.が抜けているなどがあります。named-checkzoneコマンドを使ってゾーンファイルに間違いがないか確認しましょう。引数は$ORIGINに指定したゾーン名と、確認を行うゾーンファイル名です。

named-checkzone alpha.jp. /var/named/alpha.jp.zone 
zone alpha.jp/IN: loaded serial 2023100901
OK

書式に問題がなければ、この例のように設定したシリアルナンバーが表示され、OKと表示されます。設定が間違っている場合には、次のように問題のある行番号が表示されます。

named-checkzone alpha.jp. /var/named/alpha.jp.zone 
zone alpha.jp/IN: NS 'host1.alpha.jp.alpha.jp' has no address records (A or AAAA)
zone alpha.jp/IN: not loaded due to errors.

この例では、NSレコードの右側に書いたホスト名がFQDNになっていないため、「host1.alpha.jp.alpha.jp」となってしまい、対応するAレコードが見つからないというエラーが発生しています。

## BINDの起動と確認
BINDを起動してみましょう。BINDの起動は、systemctlコマンドでnamed-chrootユニットを使います。

systemctl start named-chroot

起動できたら、状態を確認します。

systemctl status named-chroot
● named-chroot.service - Berkeley Internet Name Domain (DNS)
     Loaded: loaded (/usr/lib/systemd/system/named-chroot.service; disabled; preset: disabled)
     Active: active (running) since Mon 2023-10-09 15:18:44 JST; 6s ago
    Process: 12416 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named>
    Process: 12418 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} -t /var/named/chroot $OPTIONS (code=exi>
   Main PID: 12419 (named)
      Tasks: 6 (limit: 10696)
     Memory: 21.2M
        CPU: 32ms
     CGroup: /system.slice/named-chroot.service
             └─12419 /usr/sbin/named -u named -c /etc/named.conf -t /var/named/chroot

Oct 09 15:18:44 localhost.localdomain named[12419]: network unreachable resolving './DNSKEY/IN': 2001:500:9f:>
Oct 09 15:18:44 localhost.localdomain named[12419]: network unreachable resolving './NS/IN': 2001:500:9f::42#>
Oct 09 15:18:44 localhost.localdomain named[12419]: network unreachable resolving './DNSKEY/IN': 2001:7fe::53>
Oct 09 15:18:44 localhost.localdomain named[12419]: network unreachable resolving './NS/IN': 2001:7fe::53#53
Oct 09 15:18:44 localhost.localdomain named[12419]: zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.>
Oct 09 15:18:44 localhost.localdomain named[12419]: all zones loaded
Oct 09 15:18:44 localhost.localdomain named[12419]: running
Oct 09 15:18:44 localhost.localdomain systemd[1]: Started Berkeley Internet Name Domain (DNS).
Oct 09 15:18:44 localhost.localdomain named[12419]: managed-keys-zone: Key 20326 for zone . is now trusted (a>
Oct 09 15:18:44 localhost.localdomain named[12419]: resolver priming query complete

Activeの欄に「active (running)」と表示されていることを確認します。また、下に表示されるログにも「Started Berkeley Internet Name Domain...」と表示されていて、BINDのサービスが起動していることが確認できます。

## 自動起動の設定
システム起動時にBINDが自動的に起動されるように設定しておきましょう。systemctl enableコマンドで設定します。

systemctl enable named-chroot
Created symlink from /etc/systemd/system/multi-user.target.wants/named-chroot.service to /usr/lib/systemd/system/named-chroot.service.

自動起動になっているかは、次のように確認できます。

systemctl is-enabled named-chroot
enabled

自動起動の設定がされている場合には、「enabled」と表示されます。

## ファイアウォールの設定
DNSコンテンツサーバーへの問い合わせができるようにファイアウォールのサービス許可設定を行います。以下のfirewall-cmdコマンドを実行します。

firewall-cmd --add-service=dns

さらに、設定を保存しておきます。

firewall-cmd --runtime-to-permanent

## 名前解決の確認
BINDが起動したら、名前解決が正常に行われるかを確認します。名前解決の確認には、hostコマンドとdigコマンドが使用できます。

### hostコマンドで名前を確認
hostコマンドで名前からIPアドレスを確認します。hostコマンドの1つ目の引数は調査するホスト名、2つ目の引数は問い合わせを行うDNSサーバーのアドレスです。設定したサーバー自身のIPアドレスを指定します。

host host1.alpha.jp 192.168.56.101
Using domain server:
Name: 192.168.56.101
Address: 192.168.56.101#53
Aliases:

host1.alpha.jp has address 192.168.56.101

host1.alpha.jpのAレコードが正しく設定されていることが確認できます。

同様に、www.alpha.jpやmail.alpha.jpも確認してみます。

host www.alpha.jp 192.168.56.101
Using domain server:
Name: 192.168.56.101
Address: 192.168.56.101#53
Aliases:

www.alpha.jp has address 192.168.56.101


host mail.alpha.jp 192.168.56.101
Using domain server:
Name: 192.168.56.101
Address: 192.168.56.101#53
Aliases:

mail.alpha.jp has address 192.168.56.101

### digコマンドでドメインを確認
digコマンドでゾーン情報を確認してみます。ドメイン名の後にaxfrを指定するとゾーンに登録されている全ての情報が表示されます。問い合わせをするDNSサーバーは@をつけて指定します。

dig alpha.jp axfr @192.168.56.101

; <<>> DiG 9.16.23-RH <<>> alpha.jp axfr @192.168.56.101
;; global options: +cmd
alpha.jp.		10800	IN	SOA	host1.alpha.jp. root.alpha.jp. 2023100901 86400 3600 604800 10800
alpha.jp.		10800	IN	NS	host1.alpha.jp.
alpha.jp.		10800	IN	MX	10 mail.alpha.jp.
host1.alpha.jp.		10800	IN	A	192.168.56.101
mail.alpha.jp.		10800	IN	A	192.168.56.101
www.alpha.jp.		10800	IN	A	192.168.56.101
alpha.jp.		10800	IN	SOA	host1.alpha.jp. root.alpha.jp. 2023100901 86400 3600 604800 10800
;; Query time: 0 msec
;; SERVER: 192.168.56.101#53(192.168.56.101)
;; WHEN: Mon Oct 09 14:54:46 JST 2023
;; XFR size: 7 records (messages 1, bytes 235)


### digコマンドでNSレコードを確認
ドメイン名の後にnsを指定すると、ドメインに登録されているNSレコード(ネームサーバーの情報)が表示されます。

dig alpha.jp ns @192.168.56.101

; <<>> DiG 9.16.23-RH <<>> alpha.jp ns @192.168.56.101
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57210
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: e0c074ccce4dcb7001000000652395e5374ff621232b02b7 (good)
;; QUESTION SECTION:
;alpha.jp.			IN	NS

;; ANSWER SECTION:
alpha.jp.		10800	IN	NS	host1.alpha.jp.

;; ADDITIONAL SECTION:
host1.alpha.jp.		10800	IN	A	192.168.56.101

;; Query time: 0 msec
;; SERVER: 192.168.56.101#53(192.168.56.101)
;; WHEN: Mon Oct 09 14:55:49 JST 2023
;; MSG SIZE  rcvd: 101

digコマンドの結果に、ANSWER SECTIONがあれば正常であり、ANSWER SECTIONが無ければ結果が返らない状態のエラーです。

### digコマンドでMXレコードを確認
ドメイン名の後にmxを指定すると、ドメインに登録されているMXレコード(メールサーバーの情報)が表示されます。

dig alpha.jp mx @192.168.56.101

; <<>> DiG 9.16.23-RH <<>> alpha.jp mx @192.168.56.101
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23441
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: c1f5c1430953e074010000006523960da0c510f634ea02aa (good)
;; QUESTION SECTION:
;alpha.jp.			IN	MX

;; ANSWER SECTION:
alpha.jp.		10800	IN	MX	10 mail.alpha.jp.

;; ADDITIONAL SECTION:
mail.alpha.jp.		10800	IN	A	192.168.56.101

;; Query time: 0 msec
;; SERVER: 192.168.56.101#53(192.168.56.101)
;; WHEN: Mon Oct 09 14:56:29 JST 2023
;; MSG SIZE  rcvd: 102

## beta.jpサーバーとjpサーバーの追加
alpha.jpドメインの設定ができたので、相互に名前解決ができるように仮想マシンを2台追加し、それぞれbeta.jpドメイン、jpドメインを管理するDNSサーバーとして設定します。

★このあたりから未検証で書いてるので、後で検証の上変更する可能性大

### 仮想マシンの作成
VirtualBoxで仮想マシンを2台作成します。既に作成している仮想マシンと同じように作成しますが、区別が付くように仮想マシン名をドメイン名に合わせてください。仮想マシンはホストオンリーネットワークで相互に通信を行いますので、ネットワークアダプターの追加を忘れないようにしてください。

### OSのインストール
作成した仮想マシンにOSをインストールします。ホスト名とIPアドレスをそれぞれのサーバーに合わせて設定します。

|ドメイン名|ホスト名|IPアドレス|
|---|---|---|
| jp. | host0.jp | 192.168.56.100 |
| alpha.jp. | host1.alpha.jp | 192.168.56.101 |
| beta.jp. | host2.alpha.jp | 192.168.56.102 |

### 相互通信の確認
OSが起動したら、仮想マシン間で相互に通信ができることをpingコマンドを使って確認してください。

## beta.jpゾーンの設定
まず、beta.jpゾーンの設定を行います。手順はalpha.jpゾーンを設定した以下の手順と同じです。

1. BINDのインストール
1. named.confファイルにゾーンを追加
1. ゾーンファイルを作成し、レコードなどを記述
1. 設定ファイルに書式間違いが無いか確認
1. BINDの起動
1. BINDの自動起動の設定
1. ファイアーウォールの設定を変更
1. 名前解決の確認

以下、alpha.jpゾーンの設定と異なるポイントです。

### named.confの設定
named.confを設定します。listen-onに設定するIPアドレスが192.168.56.102になる点と、定義するゾーン名がbeta.jpになる点が異なります。

options {
	listen-on port 53 { 127.0.0.1; 192.168.56.102; };	←ホストのIPアドレスを追加
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };	← localhostをanyに変更

	recursion no;	←yesをnoに変更

	dnssec-validation yes;

	managed-keys-directory "/var/named/dynamic";
	geoip-directory "/usr/share/GeoIP";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";

	include "/etc/crypto-policies/back-ends/bind.config";
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

zone "beta.jp" IN {	←beta.jpゾーンを指定
	type master;
	file "beta.jp.zone";	←beta.jp用のゾーン定義ファイル名を指定
	allow-update { none; };
};	

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

### ゾーン定義ファイルの作成
ゾーン定義ファイルを作成します。alpha.jp.zoneをbeta.jp.zoneとしてコピーします。-pオプションを忘れないようにしてください。

cd /var/named
cp -p alpha.jp.zone beta.jp.zone
ls -l beta.jp.zone
-rw-r-----. 1 root named 257 Oct  9 14:47 beta.jp.zone

### ゾーンファイルの修正
コピーした/var/named/beta.jp.zoneファイルを修正します。ゾーン名がbeta.jp、ホスト名がhost2、IPアドレスが192.168.56.102になっている点に注意が必要です。

vi /var/named/beta.jp.zone

$TTL 3H
$ORIGIN beta.jp.
@       IN SOA  host2 root (
                                        2023100901       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host2.beta.jp.
        MX 10   mail.beta.jp.

host2   A       192.168.56.102
www     A       192.168.56.102
mail    A       192.168.56.102

### BINDの起動と動作確認
beta.jpゾーンの設定が完了したら、BINDを起動して動作を確認します。動作確認方法はalpha.jpゾーンを設定した際に行ったhostコマンド、digコマンドと同様です。ゾーン名やホスト名、問い合わせを行うDNSコンテンツサーバーのIPアドレスが変わる点に注意してください。

host host2.beta.jp 192.168.56.102

dig beta.jp NS @192.168.56.102

自動起動の設定や、ファイアーウォールの設定の変更も忘れず行っておきましょう。

## 上位ゾーンのDNSコンテンツサーバーの設定
alpha.jpゾーン、beta.jpゾーンの設定が完了したら、上位ゾーンにあたるjpゾーンの設定を行います。手順はalpha.jpゾーンやbeta.jpゾーンを設定した以下の手順と同じです。

1. BINDのインストール
1. named.confファイルにゾーンを追加
1. ゾーンファイルを作成し、レコードなどを記述
1. 設定ファイルに書式間違いが無いか確認
1. BINDの起動
1. BINDの自動起動の設定
1. ファイアーウォールの設定を変更
1. 名前解決の確認

以下、alpha.jpゾーンの設定と異なるポイントです。

### named.confの設定
named.confを設定します。listen-onに設定するIPアドレスが192.168.56.10になる点と、定義するゾーン名が.jpになる点が異なります。また、このDNSサーバーはDNSキャッシュサーバーとしても動作させるので、recursionの設定を「yes;」のままにしておきます。

options {
	listen-on port 53 { 127.0.0.1; 192.168.56.10; };	←ホストのIPアドレスを追加
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	recursing-file  "/var/named/data/named.recursing";
	secroots-file   "/var/named/data/named.secroots";
	allow-query     { any; };	← localhostをanyに変更

	recursion yes;	←yesのままにすること

	dnssec-validation yes;

	managed-keys-directory "/var/named/dynamic";
	geoip-directory "/usr/share/GeoIP";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";

	include "/etc/crypto-policies/back-ends/bind.config";
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

zone "jp" IN {	←jpゾーンを指定
	type master;
	file "jp.zone";	←jp用のゾーン定義ファイル名を指定
	allow-update { none; };
};	

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

### ゾーン定義ファイルの作成
ゾーン定義ファイルを作成します。alpha.jp.zoneをjp.zoneとしてコピーします。-pオプションを忘れないようにしてください。

cd /var/named
cp -p alpha.jp.zone jp.zone
ls -l beta.jp.zone
-rw-r-----. 1 root named 257 Oct  9 14:47 beta.jp.zone

### ゾーンファイルの修正
コピーした/var/named/jp.zoneファイルを修正します。ゾーン名がjp、ホスト名がhost0、IPアドレスが192.168.56.10になっている点に注意が必要です。メールやWebなどには作成しないので、MXレコードやwww、mailなどのAレコードは作成しません。

サブドメインとして権限の委譲を行ったalpha.jpゾーンとbeta.jpゾーンのNSレコード、それぞれのゾーンを管理するDNSコンテンツサーバーを指定するAレコードをグルーレコードとして記述します。

vi /var/named/jp.zone

$TTL 3H
$ORIGIN jp.
@       IN SOA  host0 root (
                                        2023100901       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      host0.jp.
alpha.jp. NS      host1.alpha.jp.
beta.jp. NS      host2.beta.jp.

host0   A       192.168.56.10
host1.alpha.jp.     A       192.168.56.101
host2.beta.jp.     A       192.168.56.102

### BINDの起動と動作確認
jpゾーンの設定が完了したら、BINDを起動して動作を確認します。alpha.jpゾーンとbeta.jpゾーンのDNSコンテンツサーバーを示すグルーレコードが名前解決できるかを確認するため、それぞれのNSレコードを問い合わせます。

dig alpha.jp NS @192.168.56.10

dig beta.jp NS @192.168.56.10

自動起動の設定や、ファイアーウォールの設定の変更も忘れず行っておきましょう。

## 相互に名前解決できることを確認
3台のDNSサーバーが設定できたので、alpha.jpとbeta.jpを相互に名前解決できることを確認します。

### 参照するDNSサーバーの変更
alpha.jpゾーンとbeta.jpゾーンを相互に参照できるようにするには、各マシンが名前解決のために参照するDNSサーバーをhost0.jp（192.168.56.10）に設定しておく必要があります。以下の手順で、alpha.jpサーバーとbeta.jpサーバーの設定をそれぞれ変更します。

1. GNOMEのデスクトップのアプリケーションメニューから「システムツール」→「設定」を選択します
1. 表示された設定画面の左側のメニューから「ネットワーク」を選択します
1. 「有線」の欄にある歯車のボタンをクリックすると、接続プロファイルの設定画面が表示されます
1. 「IPv4」のタブをクリックすると、次のような画面になります
1. DNSサーバーのアドレスを講師マシンのIPアドレス「192.168.56.10」に変更します
1. 「適用」ボタンを押して元の画面に戻ります
1. 「有線」の項目にあるスイッチを一旦「オフ」に変えます
1. 再度「オン」に変えるとDNS設定が変更されます

### 名前解決の確認
hostコマンドやdigコマンドで、他のドメインのNSレコードやMXレコードを問い合わせてみます。hostコマンドでは、-tオプションを使うことで、問い合わせるレコードを指定することができます。

host -t ns beta.jp
alpha.jp name server host2.beta.jp.

dig beta.jp MX

## DNSコンテンツサーバーのセキュリティ
動作確認のため、digのaxfrを使ってゾーンを転送する例を紹介しました。しかし、インターネット上の見知らぬサイトに、すべてのゾーンデータを教えるのは賢明ではありません。
BINDのデフォルトでは、すべてのホストへのゾーン転送が許可されます。zoneステートにallow-transferオプションが記述された場合、optionsステートメントの設定を上書きできます。下記のように設定することで、ゾーン転送をlocalhostとネットワークアドレス192.168.56.0以下にある端末からのみ許可できます。

options {
（略）
        allow-transfer  { localhost; 192.168.56.0/24; };
（略）
};

