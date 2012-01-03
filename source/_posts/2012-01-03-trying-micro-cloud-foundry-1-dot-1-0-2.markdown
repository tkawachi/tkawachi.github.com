---
layout: post
title: "Trying Micro Cloud Foundry 1.1.0 その2"
date: 2012-01-03 19:31
comments: true
categories: CloudFoundry
---
[前回](http://tkawachi.github.com/blog/2012/01/03/trying-micro-cloud-foundry-1-dot-1-0/)
は残念ながらインストールの途中で止まってしまいましたが、解決方法がわかりました。

デフォルトで Bridge network になっているのですが、私の環境
(VMware 4.1.1, Mac OS X Lion, WiFi)では VM で network が利用不可のようです。
昔から無線で Bridge networking はハマることが多いです。
以下の手順で回避できました。
(
[ここ](http://support.cloudfoundry.com/entries/20382148-unable-to-cloudfoundry-com)
や
[ここ](http://support.cloudfoundry.com/entries/20387172-unable-to-contact-cloudfoundry-com-to-redeem-configuration-token)
を参考にしました。
)
<!-- more -->

1. 立ち上げて password 設定、network 設定で DHCP を指定、proxy を none に指定
1. ここで Alt+F2 を押して別コンソールに移動。`root` ユーザでログイン。パスワードは前ステップで指定したもの。
1. VMware の設定で Network Adapter を NAT に設定。
1. `/etc/init.d/networking restart` を実行。IP が取れることを確認。
1. Alt+F1 を押して元のコンソールに移動。続きを実行。

今度は数分で完了しました。

Network につながらない場合のメッセージを見て、つながらなくても動くと理解しましたが、そうではないようです。

続いては Host から `vmc` コマンドです。

{% codeblock %}
$ vmc target http://api.kawachi.cloudfoundry.me
Successfully targeted to [http://api.kawachi.cloudfoundry.me]

$ vmc register
Email: hoho@fufu.com
Password: ******
Verify Password: ******
Creating New User: OK
{% endcodeblock %}

`api.kawachi.cloudfoundry.me` は `kawachi.cloudfoundry.me` の CNAME で、
`kawachi.cloudfoundry.me` は VM が持つ IP アドレスになっているようです。

あとは `cloudfoundry.com` と同様に利用出来るとのこと。