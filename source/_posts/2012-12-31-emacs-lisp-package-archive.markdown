---
layout: post
title: "Emacs Lisp Package Archive"
date: 2012-12-31 23:16
comments: true
categories: Emacs
---

Macでの日本語の文書を読み書きするテキストエディタを探していた。
Facebookでつぶやいていたらいろいろおすすめをいただいたのだが、これだ！！というものがなかった。
それで Emacs に戻ろうと思った。

ほぼ三年弱ぶりくらいに Emacs に戻ってきたのだが
[ELPA](http://emacswiki.org/emacs/ELPA)
というパッケージマネージャがデフォルトで付いてきていて、ものすごく導入障壁が下がっていたのでメモしておく。

<!-- more -->

Mac OS X なので Emacs 自体は
[Emacs For Mac OS X](http://emacsformacosx.com/)
からダウンロードした。
他のアプリと同じようにインストールできる。簡単。

おもむろに `M-x list-packages` とこんな画面が出てくる。

![M-x list-packages](/images/20121231/list-packages.png)

青い下線があるところに移動して return を押すとこんなかんじでパッケージの説明が出てくる。

![M-x list-packages](/images/20121231/show.png)

あとは `Install` と書かれているところに移動して return を押せばインストールが完了する。
簡単！

いくつか公開レポジトリがあるらしく以下のように設定しておけば複数のレポジトリからパッケージがインストールできる。

```
  (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                           ("marmalade" . "http://marmalade-repo.org/packages/")
                           ("melpa" . "http://melpa.milkbox.net/packages/")))
```

上の３つを入れた状態で `list-packages` すると現時点で 1000 程度のパッケージがリストされます。
これからもっと増えていくでしょう。

perl でいうところの CPAN が Emacs にできたということですね。素晴らしいです。
