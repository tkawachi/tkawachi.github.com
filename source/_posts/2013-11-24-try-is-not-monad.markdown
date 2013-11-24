---
layout: post
title: Try はモナドじゃない
date: 2013-11-24 21:19
comments: true
categories: Scala
---

[Principles of Reactive Programming](https://www.coursera.org/course/reactive)
最初週の講義で言ってたこと。
忘れそうなのでメモ。

<!-- more -->

モナドであるためにはモナド則を満たさねばならない。
モナド則は以下の３つ。

* Associativity: `(m flatMap f) flatMap g == m flatMap (x => f(x) flatMap g)`
* Left unit: `unit(x) flatMap f == f(x)`
* Right unit: `m flatMap unit == m`

ちなみにすごいHaskell本でモナド則は次のように書かれている。

* 結合法則: `(m >>= f) >>= g` と `m >>= (\x -> f x >>= g)` が等価
* 左恒等性: `return x >>= f` と `f x` が等価
* 右恒等性: `m >>= return` と `m` が等価

`flatMap` を `>>=` に、 `unit` を `return` に読みかえれば同じ。
同じモナド則の説明なので当たり前といえば、当たり前だけど。
覚えるのが大変だから名前は揃えて欲しかったなあ、とは思う。
`>>=` は bind と読むらしいので、 flatMap は bind、 return は unit。

で、Scala の Try がモナドじゃないというのは、Left unit (左恒等性) を満たさないから。
任意の `f` と `expr` において、`Try(expr) flatMap f` が `f(expr)` と等しければ、
left unit が満たされていると言える。
しかし、`f` または `expr` が例外を投げた時にこれらが等しくならない。
`Try(expr) flatMap f` では(fatal 以外の)例外が発生することはなく `Failure` 型の
戻り値になるのに対し、`f(expr)` は例外が発生する。
よって Try はモナドではない。

ああ、残念。Try はモナドでは無かったか。

でも、 left unit を満たしてなくても `for` 式では便利に使えるからいいんだよ。
と Odersky 先生はおっしゃっておられた。

正直なところ、モナド則を満たしているとどれだけ嬉しいのかよくわかってない。
for comprehension で便利に使えればそれでいいじゃん、くらいの低い認識しかない。
実際このコースの３週目の講義を聞いているところだが、「Try は正確にはモナドじゃないけど、
モナドみたいなもんだから、これ以降モナドって呼ぶね」ということになっている。
