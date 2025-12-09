#  ネットワークとセキュリティの設定
第7章では、ネットワークとセキュリティの設定についてあらためて確認します。Ubuntuでは、基本的なネットワークやセキュリティの設定はインストール時に行われます。ここでは、これらをOSインストール後に設定する方法について説明します。

## 用語集
### ネットワークインターフェース {.unlisted .unnumbered}
LANケーブルを接続して、外部のマシンとの間でデータをやり取りするための物理的なインターフェースです。

### ループバックインターフェース {.unlisted .unnumbered}
マシン内部でデータをやり取りするための仮想的なインターフェースです。

### IP（Internet Protocol） {.unlisted .unnumbered}
IPは、ネットワークに接続したコンピュータ間でデータをやり取りするためのプロトコルです。

### IPアドレス {.unlisted .unnumbered}
IPアドレスは、IP通信で各コンピュータに割り当てられる値です。データの送り先としてIPアドレスを指定すると、そのIPアドレスが割り当てられたコンピュータに送信されたデータが届きます。

### IPv4（Internet Protocol version 4） {.unlisted .unnumbered}
現在のインターネットで利用されている通信プロトコルです。IPv4では、IPアドレスを4バイト（32ビット）で表します。本来は32個の2進数（0と1）の羅列ですが、人間に分かりやすくするために1バイトごとに10進数に変換して . （ドット）で区切って「192.168.1.1」の様に表記します。
次世代のIPであるIPv6では、IPアドレスを128ビットで表します。

### ネットワークアドレス {.unlisted .unnumbered}
ホストが属しているネットワーク自体を指し示すIPアドレスです。

### ブロードキャストアドレス {.unlisted .unnumbered}
ホストが属しているネットワーク全体を指し示すIPアドレスです。このアドレスに対して通信を行うことで、ネットワークに属しているホストすべてに対して通信が行えます。

### ネットマスク {.unlisted .unnumbered}
IPアドレスのうち、どこまでがネットワーク部で、どこまでがホスト部かを示すための値です。IPアドレスとネットマスクの2つの値から、ネットワークアドレス、ブロードキャストアドレスを割り出すことができます。

### デフォルトゲートウェイ {.unlisted .unnumbered}
インターネットは、小さなネットワークが相互に接続したネットワークです。小さなネットワーク間を接続する機器としてルーター（ゲートウェイ）が使われます。ゲートウェイは1つのネットワークに複数設置することができますが、特に指定が無い場合にはデフォルトゲートウェイを使って外部のネットワークとの通信を行います。

### DHCP（Dynamic Host Configuration Protocol） {.unlisted .unnumbered}
IPアドレスなどのネットワーク設定を自動的に割り当てるプロトコルです。

### TCP（Transmission Control Protocol） {.unlisted .unnumbered}
TCPは、コネクション方式で通信するプロトコルです。IPと組み合わせたTCP/IPがインターネットの標準的な通信プロトコルです。TCPの特長として、届かなかった通信パケットを再送信して確実に通信を行う仕組みがあります。

### UDP（User Datagram Protocol） {.unlisted .unnumbered}
UDPは、コネクションレス方式で通信するプロトコルです。TCPとは異なり、データの再送信が行われないので通信の確実性は劣りますが、セッションを確立するための「3ウェイハンドシェイク」の手間が不要なためシンプルな通信に適しています。たとえば、大量に問い合わせが行われるDNSへの名前解決の問い合わせはUDPとなっています。

### ポート番号 {.unlisted .unnumbered}
ポート番号は、TCPとUDPが通信する際に使用する値です。たとえばWebサーバーはポート番号80番を使用して動作しているので、Webブラウザは目的のWebサーバーのポート番号80番に接続します。ポート番号は0番から65535番まで使用できますが、0〜1023番はWELL KNOWN PORT、1024〜49151番はREGISTERED PORTとして予約されています。

### ICMP（Internet Control Message Protocol） {.unlisted .unnumbered}
データの転送エラーやデータ転送量などの情報を通知するためのプロトコルです。

### pingコマンド {.unlisted .unnumbered}
pingコマンドは、ICMPを使って宛先に指定したホストに到達することができるかどうかを確認するコマンドです。

## ネットワーク管理
ネットワークが上手く使えない場合には、確認のためにネットワークインターフェースが正しく設定されているかを調べる必要があります。また、設定が間違っている場合には、インターフェースの設定を変更する必要があります。ここでは、ネットワークインターフェースの確認と設定の方法について解説します。

### ネットワークインターフェースの確認
Linuxをインストールしたマシンが正常にネットワークに接続できるかどうか、設定を確認します。ipコマンドで確認します。

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
       valid_lft 285sec preferred_lft 285sec
    inet6 fe80::a00:27ff:feee:b71d/64 scope link
       valid_lft forever preferred_lft forever
```

ipコマンドで表示されたloは仮想的なループバックインターフェースです。また、この例ではenp0s3に「192.168.1.12」が割り当てられていることが分かります。なお、この名称は、enoXX、ensXX、ethX、enxXXなどの名称になる場合もあります。

### ネットワークインターフェースの再設定

/etc/netplan/50-cloud-init.yamlを編集します。

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
        - 192.168.1.11
        search: [example1.test]
      routes:
      - to: "default"
        via: "192.168.1.1"
```

設定を適用します。
```
ubuntu@host1example1test:~$ sudo netplan apply
```

### ネットワークインターフェースの動作確認
ネットワークインターフェースが動作しているかはpingコマンドで確認します。pingコマンドで確認するIPアドレスとして自分の物理ネットワークインターフェースのIPアドレス、もう一台のサーバのIPアドレス（192.168.1.13）やその他のマシンのIPアドレスなどを指定します。pingコマンドはCtrl+Cで中止できます。

```
ubuntu@host1example1test:~$ ping 192.168.1.13
PING 192.168.1.13 (192.168.1.13) 56(84) bytes of data.
64 bytes from 192.168.1.13: icmp_seq=1 ttl=64 time=5.96 ms
64 bytes from 192.168.1.13: icmp_seq=2 ttl=64 time=2.98 ms
64 bytes from 192.168.1.13: icmp_seq=3 ttl=64 time=1.17 ms
64 bytes from 192.168.1.13: icmp_seq=4 ttl=64 time=3.15 ms
^C
--- 192.168.1.13 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 1.166/3.314/5.959/1.713 ms
```

## サービスのポート番号を確認
どんなネットワークサービスが自分のPCで動いているかを、ssコマンドで確認します。ss -atコマンドを実行すると、現在のTCP通信の状態をすべて表示します。

### ssコマンドを使ったポート使用状況の確認
ssコマンドは-aオプションでサービスの状態をすべて表示、-tオプションでTCP（Transmission Control Protocol）のサービスが使うポートなどの情報のみを表示します。

```
ubuntu@host1example1test:~$ ss -ta
State       Recv-Q    Send-Q                             Local Address:Port                                          Peer Address:Port          Process
LISTEN      0         100                                    127.0.0.1:smtp                                               0.0.0.0:*
LISTEN      0         10                                     127.0.0.1:domain                                             0.0.0.0:*
LISTEN      0         5                                      127.0.0.1:953                                                0.0.0.0:*
LISTEN      0         4096                               127.0.0.53%lo:domain                                             0.0.0.0:*
LISTEN      0         100                                 192.168.1.12:smtp                                               0.0.0.0:*
LISTEN      0         100                                      0.0.0.0:imap2                                              0.0.0.0:*
LISTEN      0         10                                  192.168.1.12:domain                                             0.0.0.0:*
LISTEN      0         4096                                  127.0.0.54:domain                                             0.0.0.0:*
LISTEN      0         511                                      0.0.0.0:http                                               0.0.0.0:*
LISTEN      0         100                                      0.0.0.0:pop3                                               0.0.0.0:*
LISTEN      0         10                                         [::1]:domain                                                [::]:*
LISTEN      0         100                                         [::]:imap2                                                 [::]:*
LISTEN      0         5                                          [::1]:953                                                   [::]:*
LISTEN      0         4096                                           *:ssh                                                      *:*
LISTEN      0         511                                         [::]:http                                                  [::]:*
LISTEN      0         100                                         [::]:pop3                                                  [::]:*
ESTAB       0         0                          [::ffff:192.168.1.12]:ssh                                 [::ffff:192.168.1.122]:56119
ESTAB       0         52                         [::ffff:192.168.1.12]:ssh                                 [::ffff:192.168.1.122]:50112
SYN-SENT    0         1            [240f:32:57b8:1:a00:27ff:feee:b71d]:33848             [2a05:d018:91c:3200:2846:99fb:81b6:1e11]:https
```

### servicesファイルによるポート番号の確認
ポート番号とサービスの対応（WELL KNOWN PORT NUMBERS:0〜1023やREGISTERED PORT NUMBERS:1024〜49151）が定義されている/etc/servicesファイルも確認してみてください。

```
ubuntu@host1example1test:~$ cat /etc/services
（略）
ssh             22/tcp                          # SSH Remote Login Protocol
telnet          23/tcp
smtp            25/tcp          mail
time            37/tcp          timserver
time            37/udp          timserver
whois           43/tcp          nicname
tacacs          49/tcp                          # Login Host Protocol (TACACS)
tacacs          49/udp
domain          53/tcp                          # Domain Name Server
domain          53/udp
bootps          67/udp
bootpc          68/udp
tftp            69/udp
gopher          70/tcp                          # Internet Gopher
finger          79/tcp
http            80/tcp          www             # WorldWideWeb HTTP
kerberos        88/tcp          kerberos5 krb5 kerberos-sec     # Kerberos v5
kerberos        88/udp          kerberos5 krb5 kerberos-sec     # Kerberos v5
iso-tsap        102/tcp         tsap            # part of ISODE
acr-nema        104/tcp         dicom           # Digital Imag. & Comm. 300
pop3            110/tcp         pop-3           # POP version 3
sunrpc          111/tcp         portmapper      # RPC 4.0 portmapper
sunrpc          111/udp         portmapper
auth            113/tcp         authentication tap ident
nntp            119/tcp         readnews untp   # USENET News Transfer Protocol
ntp             123/udp                         # Network Time Protocol
epmap           135/tcp         loc-srv         # DCE endpoint resolution
netbios-ns      137/udp                         # NETBIOS Name Service
netbios-dgm     138/udp                         # NETBIOS Datagram Service
netbios-ssn     139/tcp                         # NETBIOS session service
imap2           143/tcp         imap            # Interim Mail Access P 2 and 4
（略）
```

## SSHによるリモートログイン
SSHはネットワーク経由でリモートにあるLinuxサーバーにログインするために使用するプロトコルです。通信が暗号化されているため、覗き見されてもパスワードや作業内容が分からない他、公開鍵を使った認証を行うことでパスワードをネットワークに流すことなくログインすることができます。

Linuxでは、OpenSSHのサーバーとクライアントが用意されています。

### パスワードによる認証
sshコマンドは特別な設定を行わなくても、パスワード認証でリモートログインすることができます。

以下のようにして、自分自身にSSHで接続してみます。初めての接続の場合には、SSHサーバーの公開鍵が送られてきて接続してもよいか確認されるので「yes」と入力します。パスワード認証が可能だと、パスワードの入力が要求されます。

```
ubuntu@host1example1test:~$ ssh user1@localhost
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ED25519 key fingerprint is SHA256:c68i9zv/K4gfef+MMMxm0e6WMJ09ufi9dQwA8vt8n4A.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
user1@localhost's password:
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May  6 01:17:31 AM UTC 2025

  System load:             0.0
  Usage of /:              46.8% of 9.75GB
  Memory usage:            13%
  Swap usage:              0%
  Processes:               124
  Users logged in:         2
  IPv4 address for enp0s3: 192.168.1.12
  IPv6 address for enp0s3: 240f:32:57b8:1:a00:27ff:feee:b71d

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

75 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


You have mail.
Last login: Tue May  6 00:02:42 2025 from 192.168.1.122

user1@host1example1test:~$ exit ← リモートログインを終了
logout
Connection to localhost closed.
ubuntu@host1example1test:~$ ← 元のユーザーに復帰
```

### 公開鍵による認証
パスワード認証は、通信経路がSSHで暗号化されているといっても、パスワードがネットワークを流れていること、またパスワードを自動的に生成して順番に試していく「総当たり攻撃」を受けた場合不正にログインされてしまう可能性があるので、インターネット上に公開されているサーバーで使用するには相応しくありません。

公開鍵認証は、あらかじめサーバーに設置した公開鍵と対になっている秘密鍵を持っているユーザーしかリモートログインできない認証方法です。

以下の手順で公開鍵認証を設定します。

1. 公開鍵と秘密鍵を生成する
ssh-keygenコマンドを使用して一対の公開鍵（id_ed25519.pub）と秘密鍵（id_ed25519）を生成します。鍵のファイルはホームディレクトリに作られた.sshディレクトリに保存されます。

秘密鍵には不正利用を防止するためのパスフレーズを設定します。接続時にパスフレーズを正しく入力できないと、秘密鍵は利用できないので、公開鍵認証による接続はできません。このパスフレーズはSSHクライアント側で秘密鍵に対して処理されるので、ネットワーク上には情報は流れません。

```
ubuntu@host1example1test:~$ su - user1 ← user1ユーザーに切り替え
Password:
user1@host1example1test:~$

user1@host1example1test:~$ ssh-keygen ← 鍵形式を省略したのでED25519形式で鍵を生成
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user1/.ssh/id_ed25519):
Created directory '/home/user1/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/user1/.ssh/id_ed25519
Your public key has been saved in /home/user1/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:r05cuOLisPskAOeApHjAco7++UQ5sVmtYXS7iWqFzW4 user1@host1example1test
The key's randomart image is:
+--[ED25519 256]--+
|o.     . .       |
|*o.   . o .      |
|B+o  . + o       |
|o=.   @ +.o      |
|o .  B *So.      |
| o  . =. +       |
|  + o+.E+ .      |
|   B+..o .       |
|  o++o..o        |
+----[SHA256]-----+
```

1. 接続先にauthorized_keysを作成する
ユーザーに公開鍵認証によるSSHでの接続を許可するには、ユーザーアカウントを作成し、そのユーザーのホームディレクトリに.ssh/authorized_keysファイルを作成しておきます。.sshディレクトリのパーミッションは700（drwx------）、authorized_keysファイルのパーミッションは600（-rwx------）に設定する必要があります。

```
user1@host1example1test:~$ ls -ld .ssh
drwx------ 2 user1 user1 4096 May  6 01:24 .ssh

user1@host1example1test:~$ cd .ssh

user1@host1example1test:~/.ssh$ touch authorized_keys

user1@host1example1test:~/.ssh$ chmod 600 authorized_keys

user1@host1example1test:~/.ssh$ cat id_ed25519.pub >> authorized_keys

user1@host1example1test:~/.ssh$ ls -l authorized_keys
-rw------- 1 user1 user1 105 May  6 01:27 authorized_keys
```

1. 公開鍵認証で接続する
公開鍵認証で接続します。sshコマンドの使用法自体はパスワード認証と同じですが、パスワードの代わりに秘密鍵に設定したパスフレーズの入力が必要です。

```
ubuntu@host1example1test:~$ ssh user1@192.168.1.12
The authenticity of host '192.168.1.12 (192.168.1.12)' can't be established.
ED25519 key fingerprint is SHA256:c68i9zv/K4gfef+MMMxm0e6WMJ09ufi9dQwA8vt8n4A.
This host key is known by the following other names/addresses:
    ~/.ssh/known_hosts:1: [hashed name]
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.12' (ED25519) to the list of known hosts.
user1@192.168.1.12's password:
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May  6 01:42:03 AM UTC 2025

  System load:             0.03
  Usage of /:              46.8% of 9.75GB
  Memory usage:            13%
  Swap usage:              0%
  Processes:               124
  Users logged in:         2
  IPv4 address for enp0s3: 192.168.1.12
  IPv6 address for enp0s3: 240f:32:57b8:1:a00:27ff:feee:b71d

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

75 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


You have mail.
Last login: Tue May  6 01:35:50 2025 from 127.0.0.1
user1@host1example1test:~$
```

### パスワード認証の禁止
パスワード認証が有効になっていると、パスワードの総当たり攻撃により不正にリモートログインできてしまいます。公開鍵認証で接続できるようになった後には、SSHサーバーの設定を変更してパスワード認証を禁止しておきます。

1. ubuntuユーザーでパスワード認証で接続できることを確認する
user1ユーザーになっている場合にはexitしてubuntuユーザーに戻ります。

```
user1@host1example1test:~$ exit
logout
ubuntu@host1example1test:~$ ssh ubuntu@localhost
ubuntu@localhost's password:
ubuntu@host1example1test:~$ exit
logout
Connection to localhost closed.
```

1. 設定ファイル/etc/ssh/sshd_config.d/50-cloud-init.confを修正する

```
ubuntu@host1example1test:~$ sudo cat /etc/ssh/sshd_config.d/50-cloud-init.conf
```

```
（略）
PasswordAuthentication no ← noに設定した行を追加
#PasswordAuthentication yes
（略）
```

1. 設定を変更後、ssh設定を再読み込みする

```
ubuntu@host1example1test:~$ sudo systemctl reload ssh
```

1. 公開鍵認証を設定していないユーザーでSSHサーバーに接続して、接続できないことを確認する

```
ubuntu@host2example2test:~$ ssh ubuntu@192.168.1.12
ubuntu@192.168.1.12: Permission denied (publickey).
```

1. 公開鍵認証を設定済みのユーザーでSSHサーバーに接続して、接続できることを確認する

```
user1@host1example1test:~$ ssh user1@localhost
The authenticity of host 'localhost (127.0.0.1)' can't be established.
ED25519 key fingerprint is SHA256:c68i9zv/K4gfef+MMMxm0e6WMJ09ufi9dQwA8vt8n4A.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
Enter passphrase for key '/home/user1/.ssh/id_ed25519':
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-58-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue May  6 01:54:51 AM UTC 2025

  System load:             0.2
  Usage of /:              46.8% of 9.75GB
  Memory usage:            13%
  Swap usage:              0%
  Processes:               125
  Users logged in:         2
  IPv4 address for enp0s3: 192.168.1.12
  IPv6 address for enp0s3: 240f:32:57b8:1:a00:27ff:feee:b71d

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

75 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


You have mail.
Last login: Tue May  6 01:42:05 2025 from 192.168.1.12
user1@host1example1test:~$
```

この設定を行った後はパスワード認証でリモートログインできなくなるので、かならず事前に管理権限を持ったユーザーが公開鍵認証でリモートログインできるようにしておく必要があります。

## ファイアウォールの設定
ファイアウォールはネットワークにおいて様々なアクセス制限を行い、ネットワークからの攻撃や不正なアクセス等を防ぐ機能です。

Ubuntuのファイアウォール機能はufwによって管理されています。ufwでは、ネットワークインターフェースへのパケットの受信の許可、拒否のルールを管理しています。ufwの設定は、ufwコマンドで行います。

### ファイアウォール設定の確認
まず、ufwの状態を確認すると、ufwが無効となっていることが分かります。

```
ubuntu@host1example1test:~$ sudo ufw status
sudo: unable to resolve host host1example1test: Name or service not known
Status: inactive
```

ufwを有効化する前に、まずssh通信が出来るようにしておきます。
```
ubuntu@host1example1test:~$ sudo ufw allow 22/tcp
Rules updated
Rules updated (v6)
```

ufwを有効化し、状態を確認します。
```
ubuntu@host1example1test:~$ sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup

ubuntu@host1example1test:~$ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
```

### 許可サービスの追加
サービスの許可を追加します。以下の例では、今回の演習で構築した各サービスを許可しています。

```
ubuntu@host1example1test:~$ sudo ufw allow 80/tcp
Rule added
Rule added (v6)

ubuntu@host1example1test:~$ sudo ufw allow 25/tcp
Rule added
Rule added (v6)

ubuntu@host1example1test:~$ sudo ufw allow 110/tcp
Rule added
Rule added (v6)

ubuntu@host1example1test:~$ sudo ufw allow 143/tcp
Rule added
Rule added (v6)

ubuntu@host1example1test:~$ sudo ufw allow 53/tcp
Rule added
Rule added (v6)

ubuntu@host1example1test:~$ sudo ufw allow 53/udp
Rule added
Rule added (v6)

ubuntu@host1example1test:~$ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
25/tcp                     ALLOW       Anywhere
110/tcp                    ALLOW       Anywhere
143/tcp                    ALLOW       Anywhere
53/tcp                     ALLOW       Anywhere
53/udp                     ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
80/tcp (v6)                ALLOW       Anywhere (v6)
25/tcp (v6)                ALLOW       Anywhere (v6)
110/tcp (v6)               ALLOW       Anywhere (v6)
143/tcp (v6)               ALLOW       Anywhere (v6)
53/tcp (v6)                ALLOW       Anywhere (v6)
53/udp (v6)                ALLOW       Anywhere (v6)
```

この設定は即座に有効になります。
ufwがOS起動時に自動起動されるか確認しておきましょう。

```
ubuntu@host1example1test:~$ sudo systemctl is-enabled ufw
enabled
```


### 許可サービスの取り消し
許可されているサービスを取り消しすることもできます。

```
ubuntu@host1example1test:~$ sudo ufw deny 53/tcp
Rule updated
Rule updated (v6)

ubuntu@host1example1test:~$ sudo ufw status
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
25/tcp                     ALLOW       Anywhere
110/tcp                    ALLOW       Anywhere
143/tcp                    ALLOW       Anywhere
53/tcp                     DENY        Anywhere
53/udp                     ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
80/tcp (v6)                ALLOW       Anywhere (v6)
25/tcp (v6)                ALLOW       Anywhere (v6)
110/tcp (v6)               ALLOW       Anywhere (v6)
143/tcp (v6)               ALLOW       Anywhere (v6)
53/tcp (v6)                DENY        Anywhere (v6)
53/udp (v6)                ALLOW       Anywhere (v6)
```

\pagebreak
