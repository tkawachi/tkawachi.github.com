---
layout: post
title: "underscore.js in node REPL"
date: 2011-12-25 01:04
comments: true
categories: Node.js
---
underscore.js の挙動を試そうと node をインタラクティブに起動して以下のように試したところ `_` が配列で置き換えられてしまう。

    $ node
    > var _ = require('underscore');
    > _([1,2,3,2,1]).uniq();
    [ 1, 2, 3 ]
    > _
    [ 1, 2, 3 ]

なぜ？どうして？
しばらく悩んじゃいました。

あれこれやっているうちに、以下のように console.log() で結果をだすと問題ないことがわかった。

    $ node
    > var _ = require('underscore');
    > console.log(_([1,2,3,2,1]).uniq());
    [ 1, 2, 3 ]
    > _
    { [Function]
      _: [Circular],
      VERSION: '1.2.3',
    (略)

正解は[これ](http://nodejs.org/docs/latest/api/repl.html#rEPL_Features)！

> The special variable _ (underscore) contains the result of the last expression.

気づいてしまえばなんてこと無いです。

一つ解せないのは expression の評価値が undefined の場合には _ に保持されないっぽいこと。
Node v0.4.7 で確認しました。最新版でどうなっているかは知りません。

    $ node
    > 1
    1
    > _
    1
    > undefined
    > _
    1

まあこの挙動であってくれたおかげで `console.log()` で `_` が置き換えられなかったわけですけどね。