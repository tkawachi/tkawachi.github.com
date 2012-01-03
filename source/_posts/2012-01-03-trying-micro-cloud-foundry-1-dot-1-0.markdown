---
layout: post
title: "Trying Micro Cloud Foundry 1.1.0"
date: 2012-01-03 14:19
comments: true
categories: CloudFoundry
---
前々から気になっていた Micro Cloud Foundry を試してみます。
Cloud Foundry は VMware 社が開発している open source の PaaS です。
Micro Cloud Foundry は PaaS 環境を VMware の仮想マシンにまとめたものです。

参考にしたのは [Micro Cloud Foundry Installation & Setup](http://support.cloudfoundry.com/entries/20316811-micro-cloud-foundry-installation-setup)。
<!-- more -->

まず仮想マシンを [Clound Foundry のページ](http://www.cloudfoundry.com/)
からダウンロードします。
1GBあるので結構時間がかかります。
BitTorrent で配布してくれとリクエストをだしておきました。

ダウンロード後、展開して `micro.vmx` を  VMware Fusion 4.1.1 で開こうとするとエラーになる。
どうやら `.vmx` が Steinberg VST Mixer Settings に関連付けられていることが問題のようだ。
以前 Cubase というアプリをインストールしたが、それが干渉している模様。
[VMware のコミュニティページ](http://communities.vmware.com/thread/239695)
を参考にして `micro/` ディレクトリを `micro.vmwarevm/` に改名して
ダブルクリックすることで起動できた。

あとは
[参考ページ](http://support.cloudfoundry.com/entries/20316811-micro-cloud-foundry-installation-setup)
通り、、と行きたいところですが問題発生。

`Enter Micro Cloud Foundry configuration token: ` と聞かれたところで
自分の token を入力しても
`Unable to contact cloudfoundry.com to redeem configuration token`
というエラーが表示される。
ネットワークの設定がうまくいっていないのか、はたまた `cloudfoundry.com` が
ダウンしているのか。
`Configure vcap.me instead?` と聞かれたのでとりあえず y した。

    Micro Cloud Foundry is now bound to localhost (127.0.0.1)
    You must use ssh tunneling to access it
    Press return to continue 

と表示された。return を押して続き。

下の画面のとおり「5分かかるよ」と言われた。

{% img https://lh3.googleusercontent.com/-ScF3kpSyiJ0/TwKwn8CpQiI/AAAAAAAAGSM/n1Lcx5EFHw0/s800/Screen%252520Shot%2525202012-01-03%252520at%25252016.30.13.png %}

がしかし、待っても待っても返ってこない。1時間以上は待ったが。
どうしたことだろう？

とりあえず今回はここまで。次回はなんとか動かしたい。