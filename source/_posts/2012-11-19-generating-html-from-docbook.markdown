---
layout: post
title: "Generating HTML from DocBook"
date: 2012-11-19 00:28
comments: true
categories: DocBook
---

これまで DocBook には縁がなかったのですが、とある DocBook 形式の .xml ファイルを HTML に変換したくなりました。
DocBook project で用意されている xslt を xlstproc コマンドであててあげれば良いようです。

今作業している MacOS X (Mountain Lion) には xsltproc が /usr/bin/ にインストールされているようです。
DocBook 用の xslt をインストールするのに Homebrew を使います。

```sh
$ brew install docbook
$ xsltproc -o book.html \
  /usr/local/Cellar/docbook/5.0/docbook/xsl-ns/1.77.1/xhtml5/docbook.xsl \
  book.xml
```

こんなかんじで無事に book.xml から book.html を生成することができました。
DocBook って難しくて怖いイメージがあったんですが意外に簡単にでした。