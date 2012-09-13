---
layout: post
title: "Sending git revision to Exceptional.io"
date: 2012-09-13 20:44
comments: true
categories: 
---

[Exceptional.io](https://www.exceptional.io) は Ruby アプリケーションで起きた例外を集約して管理するサービスだ。

例外が起きた時に困るのが、それってどのバージョンで起きたバグ？ってことがわからないこと。
日付が記録されているので調べればわからなくはないけど、面倒だよね。

Exceptional.io では付加情報を付け加えて送ることができるので、以下の utility class をつかって git の revision 情報を取得し、それを送るようにしてみた。

{% gist 3713816 %}

あとは

``` ruby
Exceptional.context({git_revision: GitUtil.revision})
```

こんな感じのコードを例外送出前に呼んでおくと、付加情報と共に送られていく。

これでどのコミットからどのコミットまで例外が起きてたかわかるようになった。便利便利。