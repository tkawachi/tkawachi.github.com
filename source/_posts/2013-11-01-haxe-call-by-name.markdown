---
layout: post
title: Haxe で call-by-name したい
date: 2013-11-01 19:18
comments: true
categories: Haxe
---

先日 Haxe で Option 関連の関数を定義した時、 `getOrElse()` は次のような定義にしていた。

    public static function getOrElse<A>(opt: Option<A>, els: A) {
      return switch (opt) {
      case Some(v): v;
      case None: els;
      }
    }

scala.Option の `getOrElse()` ぽく使いたかったのだが、実際に使ってみるとなんか違う。

    opt.getOrElse(sideEffectFunction());

上で `sideEffectFunction()` は何らかの副作用をもつ関数だ。
Scala の場合、 `opt` に値が入っていた場合には `sideEffectFunction()` は評価されない。
副作用も発生しない。
上で定義した Haxe 用 `getOrElse()` では `opt` の内容によらず `sideEffectFunction()` が評価され、副作用が発生する。

関数を呼び出すときには、まず引数を評価してから関数の実行に移るので、当たり前といえば当たり前だった。

<!-- more -->

Scala には call-by-name が言語上用意されているおり、
scala.Option の `getOrElse()` はこれを利用している。
型を確認すると `final def getOrElse[B >: A](default: ⇒ B): B` となっている。
`⇒ B` が引数の型だが `⇒` を付けることにより、関数呼び出し前には評価されず、関数内で `default` を参照したところで評価されるようになっている(call-by-name)。
なお `[B >: A]` は型の境界で、B は A の subtype であることを表している。
いいなあ。Scala。

## Using callback

さて Haxe には call-by-name が無い。
JavaScript も call-by-name が無いが、彼らは callback でそれを代用する。
Haxe でも同じようにできる。

    public static function getOrElse<A>(opt: Option<A>, els: Void -> A) {
      return switch (opt) {
      case Some(v): v;
      case None: els();
      }
    }

`els` 部を関数渡すようにしておけば、実際に `opt` が `None` のときだけ `els` を評価することができる。
このとき呼び出し元は以下のようになる。

    opt.getOrElse(function() { return sideEffectFunction(); });
    // function が return ひとつだけのときは以下のように省略できるが、まだ長い。
    opt.getOrElse(function() return sideEffectFunction());

Haxe では関数リテラルを短く書く方法がなく、return を省略できないため長ったらしい。
仮にこれが CoffeeScript だったとすると、

    opt.getOrElse(-> sideEffectFunction())

と書くことが出来ただろう。
しかしないものねだりをしてもしょうがない。

## Using macro

もうすこし考えてみたところ、macro 機能を使えば scala ぽいことができることに気がついた。
Macro はコンパイル時に実行されるコードで、プログラムを変更することができる。
Macro というと「怖い。黒魔術！」と身構えてしまうかもしれないが、ひどく怖いわけではない。

プログラムをコンパイルするときはテキストを読み込んで抽象構文木を作る。
C の macro はテキストの段階で置き換えを行うが、 Haxe の macro は抽象構文木の段階で変換を行う。
C では C の文法ではないテキストを macro で処理することができる。
Haxe では、まず抽象構文木を作る必要があるので、元々存在しない文法の文字列は macro を使ってどうこうできない。
[Haxe の macro 説明ページ](http://haxe.org/manual/macros)では
「文法が崩れないので解読不能にならない。嬉しいよね！」と主張している。
なお、Scala の macro も Haxe と同じ。
[Wikipediaによると](http://goo.gl/2D99Nl) それぞれ Text substitution macros と Syntactic macros という名前で呼ばれるらしい。

Macro を使って書いたオレオレ `getOrElse()` は以下のとおり。

    import haxe.macro.Expr;
    
    macro public static function getOrElse(opt: Expr, els: Expr) {
      return macro switch ($opt) {
      case Some(v): v;
      case None: $els;
      }
    }

関数宣言の頭に `macro` と付けることで、`getOrElse()` が macro であることを示している。
Macro 引数の型は基本的に `haxe.macro.Expr` 型であり、これは抽象構文木上の式を表す。
木上で式を式に変換するわけだから、戻り値も `Expr` 型だ。
`return` の次にある `macro` は、以降の式を `Expr` に変えてくれる便利なもの。
`opt` や `els` の参照は、`$` prefix を付けて行う。
正直、まだ完全にわかった気はしていないが、 `getOrElse()` の定義はこれで十分。

呼び出し方は scala と同じ

    opt.getOrElse(sideEffectFunction());

となる。
`getOrElse()` は macro なので、上の呼び出しはコンパイル時に以下に展開される。

    // opt.getOrElse(sideEffectFunction()); が以下に置き換えられる。
    switch (opt) {
      case Some(v): v;
      case None: sideEffectFunction();
    };

展開結果を見るとわかるように `opt` が `Some(v)` の時には `sideEffectFunction()` は評価されない。やった。Scala ぽくなった。

なお、macro 引き数の `els` は macro 定義内で何度でも参照でき、各々が `sideEffectFunction()` に展開されるため、評価回数が複数回になりうるというところは call-by-name と同じだ。

### まって、それ type safe じゃなくない？

むぐぐ。
たしかに `switch` に展開するだけなので `els` に対する型の制約はない。
Macro でなんとか出来そうな気もするが将来の課題ということに。

## 再び callback

Callback での不満点は無名関数の記法が長いということだったので、macro でそれを解決すれば満足できるかもしれない。
ただし Haxe の文法にないものは macro でどうしようもないので `-> sideEffectFunction()` のような書き方はできない。

例えばこんな感じ。

    macro public static function fn(e: Expr) {
      return macro function() { return $e; };
    }

を mixin すれば callback 版 `getOrElse()` は以下のように呼び出せる。

    opt.getOrElse(sideEffectFunction().fn());

ここが妥協点かなあ。

## まとめ

* Haxe の macro を使うと抽象構文木レベルでプログラムを変更できる
* Haxe にも call-by-name あったらいいのに

