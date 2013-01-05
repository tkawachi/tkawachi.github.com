---
layout: post
title: "Homebrew RMagick"
date: 2013-01-05 14:38
comments: true
categories: Ruby RMagick Homebrew
---

Homebrew で ImageMagick をインストールして RVM 環境の ruby に rmagick gem を入れようとしたら意外に苦労したのでメモ。

<!-- more -->

最終的な手順

1. `brew update`
2. `brew install ghostscript imagemagick`
3. `ln -s /usr/local/lib/libMagickCore-Q16.dylib /usr/local/lib/libMagickCore.dylib`
4. `gem install rmagick`
5. `rm /usr/local/lib/libMagickCore.dylib`

ハマりポイント

* brew では `MagickCore-Q16` という名前でライブラリがインストールされる。
  RMagick の [extconf.rb](https://github.com/rmagick/rmagick/blob/master/ext/RMagick/extconf.rb#L207) では `MagickCore`, `Magick`, `Magick++` という
  名前でライブラリの存在を確認しているため、ここで落ちる。
  `-Q16` ってなんじゃ！
  * → `/usr/local/lib/libMagickCore.dylib` に symlink しちゃう。
    `MagickCore`, `Magick`, `Magick++` のうち一つだけあればチェックは通るので
    `libMagickCore.dylib` だけで OK。
    また gem のインストールが終わったら不要なので symlink 消しとく。
* rmagick gem のインストールが途中で止まる。ghostscript 入ってないと途中で止まるっぽい。。
  * → brew で ghostscript も入れる。
