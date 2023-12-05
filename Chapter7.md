#  ネットワークとセキュリティの設定
AlmaLinuxでは、基本的なネットワークやセキュリティの設定はインストール時に行われます。ここでは、これらをOSインストール後に設定する方法について説明します。

## 用語集
### ネットワークインターフェース
LANケーブルを接続して、外部のマシンとの間でデータをやり取りするための物理的なインターフェースです。

### ループバックインターフェース
マシン内部でデータをやり取りするための仮想的なインターフェースです。

### IP(Internet Protocol)
IPは、ネットワークに接続したコンピューター間でデータをやり取りするためのプロトコルです。

### IPアドレス
IPアドレスは、IP通信で各コンピューターに割り当てられる値です。データの送り先としてIPアドレスを指定すると、そのIPアドレスが割り当てられたコンピューターに送信されたデータが届きます。

### IPv4(Internet Protocol version 4)
現在のインターネットで利用されている通信プロトコルです。IPv4では、IPアドレスを4バイト（32ビット）で表します。本来は32個の2進数（0と1）の羅列ですが、人間に分かりやすくするために1バイトごとに10進数に変換して . (ドット)で区切って「192.168.1.1」の様に表記します。
次世代のIPであるIPv6では、IPアドレスを128ビットで表します。

### ネットワークアドレス
ホストが属しているネットワーク自体を指し示すIPアドレスです。

### ブロードキャストアドレス
ホストが属しているネットワーク全体を指し示すIPアドレスです。

### ネットマスク
IPアドレスのうち、どこまでがネットワーク部で、どこまでがホスト部かを示すための値です。IPアドレスとネットマスクの2つの値から、ネットワークアドレス、ブロードキャストアドレスを割り出すことができます。

### デフォルトゲートウェイ
インターネットは、小さなネットワークが相互に接続したネットワークです。小さなネットワーク間を接続する機器としてルーター(ゲートウェイ)が使われます。ゲートウェイは1つのネットワークに複数設置することができますが、特に指定が無い場合にはデフォルトゲートウェイを使って外部のネットワークとの通信を行います。

### DHCP(Dynamic Host Configuration Protocol)
IPアドレスなどのネットワーク設定を自動的に割り当てるプロトコルです。

### TCP(Transmission Control Protocol)
TCPは、コネクション方式で通信するプロトコルです。IPと組み合わせたTCP/IPがインターネットの標準的な通信プロトコルです。TCPの特長として、届かなかった通信パケットを再送信して確実に通信を行う仕組みがあります。

### UDP(User Datagram Protocol)
UDPは、コネクションレス方式で通信するプロトコルです。TCPとは異なり、データの再送信が行われないので通信の確実性は劣りますが、セッションを確立するための「3ウェイハンドシェイク」の手間が不要なためシンプルな通信に適しています。たとえば、大量に問い合わせが行われるDNSへの名前解決の問い合わせはUDPとなっています。

### ポート番号
ポート番号は、TCPとUDPが通信する際に使用する値です。たとえばWebサーバーはポート番号80番を使用して動作しているので、Webブラウザーは目的のWebサーバーのポート番号80番に接続します。ポート番号は0番から65535番まで使用できますが、0〜1023番はWELL KNOWN PORT、1024〜49151番はREGISTERED PORTとして予約されています。

### ICMP(Internet Control Message Protocol)
データの転送エラーやデータ転送量などの情報を通知するためのプロトコルです。

### pingコマンド
pingコマンドは、ICMPを使って宛先に指定したホストに到達することができるかどうかを確認するコマンドです。

## ネットワーク管理
ネットワークが上手く使えない場合には、確認のためにネットワークインターフェースが正しく設定されているかを調べる必要があります。また、設定が間違っている場合には、インターフェースの設定を変更する必要があります。ここでは、ネットワークインターフェースの確認と設定の方法について解説します。

### ネットワークインターフェースの確認
Linuxをインストールしたマシンが正常にネットワークに接続できるかどうか、設定を確認します。ipコマンドで確認します。

# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:cb:f6:31 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.101/24 brd 192.168.1.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 2001:db8::10/64 scope global noprefixroute 
       valid_lft forever preferred_lft forever
    inet6 fe80::40f4:1400:1f0d:132b/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:96:78:2c brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master virbr0 state DOWN group default qlen 1000
    link/ether 52:54:00:96:78:2c brd ff:ff:ff:ff:ff:ff

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:2d:1c:bc brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 65668sec preferred_lft 65668sec
    inet6 fe80::a00:27ff:fe2d:1cbc/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:93:ab:ef brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.101/24 brd 192.168.56.255 scope global noprefixroute enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe93:abef/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

ipコマンドで表示されたloは仮想的なループバックインターフェースです。また、この例ではenp0s3が物理的なインターフェースです。この名称は、インストールしたPCによって変わります。enoXX、ensXX、enpXsX、ethX、enxXXなどの名称になる場合もあります。

### ネットワークインターフェースの再設定
インストール時にIPアドレスの設定を間違えた時などは、ネットワークインターフェースを再設定します。設定は、GNOMEの管理画面から行うことができます。

GNOMEのデスクトップのアプリケーションメニューから「システムツール」→「設定」を選択します。表示された設定画面の左側のメニューから「ネットワーク」を選択します。

「有線」の欄にある歯車のボタンをクリックすると、接続プロファイルの設定画面が表示されます。「IPv4」のタブをクリックすると、次のような画面になります。

この画面で、設定を変更することで、ネットワークインターフェースの設定を変更することができます。変更したら、「適用」ボタンを押して元の画面に戻ります。「有線」の項目にあるスイッチを、一旦「オフ」に変えます。再度、「オン」に変えるとネットワークインターフェース設定が変更されます。

### ネットワークインターフェースの動作確認
ネットワークインターフェースが動作しているかはpingコマンドで確認します。pingコマンドで確認するIPアドレスとして自分の物理ネットワークインターフェースのIPアドレス、講師のマシンのIPアドレス(192.168.1.10)やその他のマシンのIPアドレスなどを指定します。pingコマンドは[Control]+[c]で中止できます。

# ping 192.168.56.101	←　自分のIPアドレス
PING 192.168.56.101 (192.168.1.101) 56(84) bytes of data.
64 bytes from 192.168.56.101: icmp_seq=1 ttl=64 time=0.209 ms
64 bytes from 192.168.56.101: icmp_seq=2 ttl=64 time=0.151 ms
64 bytes from 192.168.56.101: icmp_seq=3 ttl=64 time=0.174 ms
64 bytes from 192.168.56.101: icmp_seq=4 ttl=64 time=0.144 ms
64 bytes from 192.168.56.101: icmp_seq=5 ttl=64 time=0.144 ms
^C
--- 192.168.56.101 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 3998ms
rtt min/avg/max/mdev = 0.144/0.164/0.209/0.027 ms

PING 192.168.56.101 (192.168.56.101) 56(84) bytes of data.
64 バイト応答 送信元 192.168.56.101: icmp_seq=1 ttl=64 時間=0.148ミリ秒
64 バイト応答 送信元 192.168.56.101: icmp_seq=2 ttl=64 時間=0.038ミリ秒
64 バイト応答 送信元 192.168.56.101: icmp_seq=3 ttl=64 時間=0.040ミリ秒
^C
--- 192.168.56.101 ping 統計 ---
送信パケット数 3, 受信パケット数 3, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 0.038/0.075/0.148/0.051 ms

### サービスのポート番号を確認
どんなネットワークサービスが自分のPCで動いているかを、ssコマンドとlsofコマンドで確認します。ss -atコマンドを実行すると、現在のTCP通信の状態をすべて表示します。

# ss -at
State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
LISTEN     0      50         *:microsoft-ds             *:*                    
LISTEN     0      50         *:netbios-ssn              *:*                    
LISTEN     0      100        *:pop3                     *:*                    
LISTEN     0      100        *:imap                     *:*                    
LISTEN     0      128        *:sunrpc                   *:*                    
LISTEN     0      5      192.168.122.1:domain                   *:*                    
LISTEN     0      10     192.168.1.101:domain                   *:*                    
LISTEN     0      10     127.0.0.1:domain                   *:*                    
LISTEN     0      128        *:ssh                      *:*                    
（略）

lsof -i コマンドを実行すると現在開かれているすべてのポートを表示します。

# lsof -i
COMMAND    PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
rpcbind    655    rpc    6u  IPv4  15791      0t0  UDP *:sunrpc 
rpcbind    655    rpc    7u  IPv4  15855      0t0  UDP *:821 
rpcbind    655    rpc    8u  IPv4  15856      0t0  TCP *:sunrpc (LISTEN)
rpcbind    655    rpc    9u  IPv6  15857      0t0  UDP *:sunrpc 
rpcbind    655    rpc   10u  IPv6  15858      0t0  UDP *:821 
rpcbind    655    rpc   11u  IPv6  15859      0t0  TCP *:sunrpc (LISTEN)
avahi-dae  672  avahi   12u  IPv4  17393      0t0  UDP *:mdns 
avahi-dae  672  avahi   13u  IPv4  17394      0t0  UDP *:37814 
chronyd    707 chrony    1u  IPv4  17271      0t0  UDP localhost:323 
chronyd    707 chrony    2u  IPv6  17272      0t0  UDP localhost:323 
dhclient   943   root    6u  IPv4  20446      0t0  UDP *:bootpc 
sshd      1155   root    3u  IPv4  22236      0t0  TCP *:ssh (LISTEN)
sshd      1155   root    4u  IPv6  22370      0t0  TCP *:ssh (LISTEN)
（略）

ssコマンドは-aオプションでサービスの状態をすべて表示、-tオプションでTCP(Transmission Control Protocol)のサービスが使うポートなどの情報のみを表示します。lsofコマンドは-iオプションでサービスを受けているポートと対応するプログラムの情報を表示します。
ポート番号とサービスの対応(WELL KNOWN PORT NUMBERS:0〜1023やREGISTERED PORT NUMBERS:1024〜49151)が定義されている/etc/servicesファイルも確認してみてください。

# cat /etc/services
(略）
tcpmux          1/tcp                           # TCP port service multiplexer
tcpmux          1/udp                           # TCP port service multiplexer
rje             5/tcp                           # Remote Job Entry
rje             5/udp                           # Remote Job Entry
echo            7/tcp
echo            7/udp
discard         9/tcp           sink null
discard         9/udp           sink null
systat          11/tcp          users

## SSHによるリモートログイン
SSHはネットワーク経由でリモートにあるLinuxサーバーにログインするために使用するプロトコルです。通信が暗号化されているため、覗き見されてもパスワードや作業内容が分からない他、公開鍵を使った認証を行うことでパスワードをネットワークに流すことなくログインすることができます。
Linuxでは、OpenSSHのサーバーとクライアントが用意されています。

### パスワードによる認証
sshコマンドは特別な設定を行わなくても、パスワード認証でリモートログインすることができます。

以下のようにして、自分自身にSSHで接続してみます。初めての接続の場合には、SSHサーバーの電子証明書が送られてきて接続してもよいか訪ねられるので「yes」と入力します。パスワード認証が可能だと、パスワードの入力が要求されます。

[admin@host1 ~]$ ssh user1@localhost	← user1としてlocalhostに接続
The authenticity of host 'localhost (::1)' can't be established.
ECDSA key fingerprint is SHA256:qeRiiKeZpaNMdtkClnl4n0iRsjGPrnvGcLpcbhwXH8g.
ECDSA key fingerprint is MD5:25:d1:b0:2e:b8:f8:19:fb:f7:e0:a7:a6:19:06:b7:96.
Are you sure you want to continue connecting (yes/no)? yes	← yesを入力
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
user1@localhost's password: userpass	← 実際には非表示
Last failed login: Tue Feb 19 15:23:31 JST 2019 from 192.168.56.1 on ssh:notty
There were 5 failed login attempts since the last successful login.
Last login: Tue Feb 19 14:36:42 2019
[use1@host1 ~]$ exit	←　リモートログインを修了
ログアウト
Connection to localhost closed.
[admin@host1 ~]$ 	←　元のユーザーrootに復帰

### 公開鍵による認証
パスワード認証は、通信経路がSSHで暗号化されているといっても、パスワードがネットワークを流れていること、またパスワードを自動的に生成して順番に試していく「総当たり攻撃」を受けた場合不正にログインされてしまう可能性があるので、インターネット上に公開されているサーバーで使用するには相応しくありません。

公開鍵認証は、あらかじめサーバーに設置した公開鍵と対になっている秘密鍵を持っているユーザーしかリモートログインできない認証方法です。

以下の手順で公開鍵認証を設定します。

1. 公開鍵と秘密鍵を生成する
ssh-keygenコマンドを使用して一対の公開鍵(id_dsa.pub)と秘密鍵(id_dsa)を生成します。鍵のファイルはホームディレクトリに作られた.sshディレクトリに保存されます。
秘密鍵には不正利用を防止するためのパスフレーズを設定します。接続時にパスフレーズを正しく入力できないと、秘密鍵は利用できないので、公開鍵認証による接続はできません。このパスフレーズはSSHクライアント側で秘密鍵に対して処理されるので、ネットワーク上には情報は流れません。

[admin@host1 ~]$ su - user1	← ユーザーuseraにユーザを切り替え
[usera@host1 ~]$  ssh-keygen -t dsa	← DSA暗号形式で鍵を生成
Generating public/private dsa key pair.
Enter file in which to save the key (/home/usera/.ssh/id_dsa): ← Enterキーを入力
Created directory '/home/usera/.ssh'.
Enter passphrase (empty for no passphrase): 	← パスフレーズを入力（非表示）
Enter same passphrase again:  	← パスフレーズを入力（非表示）
   Your identification has been saved in /home/usera/.ssh/id_dsa.
   Your public key has been saved in /home/usera/.ssh/id_dsa.pub.
   The key fingerprint is:  ↓ 鍵についた指紋。鍵の称号に使用可能
   SHA256:Y5FJTNhlaIA7z3dT/bCTf0br+X4ZjIQCFFUKDSmtttE usera@host1.alpha.jp
   The key's randomart image is:
   +---[DSA 1024]----+
   |     .+@O++.     |
   |    ...=*=.      |
   |     .+.=.  ..   |
   |    o+ E o ...o  |
   |    .+o S ... o= |
   |     .o...o  .+oo|
   |       . . .   ++|
   |               o*|
   |              .=*|
   +----[SHA256]-----+
   [usera@host1 ~]$ 
   ```
1. 接続先に\~/.ssh/authorized_keysを作成する  
ユーザーにSSHでの接続を許可するには、ユーザーアカウントを作成し、そのユーザーのホームディレクトリに\~/.ssh/authorized_keysファイルを作成しておきます。\~/.ssh/のパーミッションは700(drwx------)、authorized_keysファイルのパーミッションは600(-rwx------)に設定する必要があります。

   [usera@host1 ~]$ ls -ld .ssh
   drwx------. 2 usera usera 38  2月 19 17:28 .ssh
   [usera@host1 ~]$ cd .ssh
   [usera@host1 .ssh]$ cat id_dsa.pub >> authorized_keys
   [usera@host1 .ssh]$ chmod 600 authorized_keys
   [usera@host1 .ssh]$ ls -l authorized_keys 
   -rw-------. 1 usera usera 610  2月 19 17:34 authorized_keys

1. 公開鍵認証で接続する  
公開鍵認証で接続します。sshコマンドの使用法自体はパスワード認証と同じですが、パスワードの代わりに秘密鍵に設定したパスフレーズの入力が必要です。

   [usera@host1 ~]$ ssh usera@localhost
   The authenticity of host 'localhost (::1)' can't be established.
   ECDSA key fingerprint is SHA256:qeRiiKeZpaNMdtkClnl4n0iRsjGPrnvGcLpcbhwXH8g.
   ECDSA key fingerprint is MD5:25:d1:b0:2e:b8:f8:19:fb:f7:e0:a7:a6:19:06:b7:96.
   Are you sure you want to continue connecting (yes/no)? yes
   Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
   Enter passphrase for key '/home/usera/.ssh/id_dsa': 	←　パスフレーズを入力
   Last login: Tue Feb 19 17:34:19 2019
   [usera@host1 ~]$ exit
   ログアウト
   Connection to localhost closed.

### パスワード認証の禁止
パスワード認証が有効になっていると、パスワードの総当たり攻撃により不正にリモートログインできてしまいます。公開鍵認証で接続できるようになった後には、OpenSSHサーバーの設定を変更してパスワード認証を禁止しておきます。

1. パスワード認証で接続できることを確認します。
   # ssh localhost
   root@localhost's password: 
   Last login: Tue Feb 19 17:13:43 2019
   [root@host1 ~]# exit
   ログアウト
   Connection to localhost closed.
   
1. 設定ファイル/etc/ssh/sshd_configを修正します。  
   
   （略）
   # To disable tunneled clear text passwords, change to no here!
   #PasswordAuthentication yes
   #PermitEmptyPasswords no
   PasswordAuthentication no	←　変更
   （略）
   
1. 設定を変更後、sshd設定の再読み込み  
   
   # systemctl reload sshd.service
   
1. 公開鍵認証を設定していないユーザーでOpenSSHサーバーに接続します。  
   
   # ssh localhost
   Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

## ファイアウォールの設定
ファイアウォールはネットワークにおいて様々なアクセス制限を行い、ネットワークからの攻撃や不正なアクセス等を防ぐ機能です。AlmaLinuxのファイアウォール機能は、firewalldによって管理されています。firewalldでは、ネットワークインターフェースへのパケットの受信の許可、拒否のルールを管理しています。firewalldの設定はfirewall-cmdというコマンドで、設定を行います。

### ファイアウォール設定の確認
許可されているサービスを調べるには、--list-servicesオプションを使います。

# firewall-cmd --list-services
ssh dhcpv6-client dns smtp pop3  http imap

### 許可サービスの追加
許可サービスを追加するには、次のように--add-serviceオプションを使います。

# firewall-cmd --add-service=imap
success

この例では、imapサービスを許可しています。設定可能なサービスについては、次のようにして--get-servicesオプションで調べることができます。

# firewall-cmd --get-services
RH-Satellite-6 amanda-client amanda-k5-client bacula bacula-client bgp bitcoin bitcoin-rpc bitcoin-testnet bitcoin-testnet-rpc ceph ceph-mon cfengine condor-collector ctdb dhcp dhcpv6 dhcpv6-client dns docker-registry docker-swarm dropbox-lansync elasticsearch freeipa-ldap freeipa-ldaps freeipa-replication freeipa-trust ftp ganglia-client ganglia-master git gre high-availability http https imap imaps ipp ipp-client ipsec irc ircs iscsi-target jenkins kadmin kerberos kibana klogin kpasswd kprop kshell ldap ldaps libvirt libvirt-tls managesieve mdns minidlna mongodb mosh mountd ms-wbt mssql murmur mysql nfs nfs3 nmea-0183 nrpe ntp openvpn ovirt-imageio ovirt-storageconsole ovirt-vmconsole pmcd pmproxy pmwebapi pmwebapis pop3 pop3s postgresql privoxy proxy-dhcp ptp pulseaudio puppetmaster quassel radius redis rpc-bind rsh rsyncd samba samba-client sane sip sips smtp smtp-submission smtps snmp snmptrap spideroak-lansync squid ssh syncthing syncthing-gui synergy syslog syslog-tls telnet tftp tftp-client tinc tor-socks transmission-client upnp-client vdsm vnc-server wbem-https xmpp-bosh xmpp-client xmpp-local xmpp-server zabbix-agent zabbix-server

### 許可サービスの取り消し
許可されているサービスを停止するには、--remove-serviceオプションを使います。

# firewall-cmd --remove-service=imap
success

### ファイアウォール設定の保存
--add-service、--remove-serviceなどで行ったファイアウォールルールの変更は、一時的なものです。そのため、再起動をすると失われてしまいます。再起動後も設定をに有効にするには、次のように--runtime-to-permanentオプションを使って、設定を保存します。

# firewall-cmd --runtime-to-permanent

