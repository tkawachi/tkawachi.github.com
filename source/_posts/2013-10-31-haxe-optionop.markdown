---
layout: post
title: Haxe で Option用の関数を定義してみた話
date: 2013-10-31 20:35
comments: true
categories: Haxe JavaScript
---

最近 JavaScript で何かを書くことになって困っている。
JavaScript はそれなりに仕事で触れて、それなりに理解はしているが、どうにも好きになれない。
CoffeeScript もそれなりに触れたが、短く書けて式中心の記法ができるものの、それ以外は JavaScript と同じ。
何も変わっていない。

僕の問題（苦手）意識は [The JavaScript Problem](http://www.haskell.org/haskellwiki/The_JavaScript_Problem)
によく表されている。

1. JavaScript sucks.
2. We need JavaScript.

もうちょっとマシな言語で書きたいと常々思っていた。

AltJS のなかで TypeScript は触ったが、Haxe は触っていなかった。
理由は「Haxe が吐き出す JavaScript はとても人間が読めるものじゃない」とどこかで聞いていたから。
いざって時には生成された JavaScript が読める形じゃないと困る。

今回ふとしたきっかけで Haxe を触ってみた。
さわってみるとかなり好感触。
出力された JavaScript はそんなに変なことになってなくて普通に読める。
やはり自分で触ってみないとダメだな。
代数的データ型があるなど TypeScript より型機能が強い感じ。

<!-- more -->

本題。
Scala でいうところの `scala.Option` に対応する型として Haxe には `haxe.ds.Option` という enum がある。
ただし Scala の case object と違い、Haxe の enum にはメソッドが定義できない。
最初は `switch case` 書いていた。

    var opt: Option<Int> = ...;
    switch(opt) {
    case Some(v): trace(v);
    case None: trace('None');
    }

的な。
これでも悪くないが Scala ぽく書きたかったので、それっぽくできないか考えてみた
（きっと他の人がどこかでやってる気がするけど）。

Haxe の [using mixin](http://haxe.org/manual/using) を使えば同じようなことができそう。
次のようなものを作って

    import haxe.ds.Option;
    class OptionOp {
      public static function map<A,B>(opt: Option<A>, f: A -> B): Option<B> {
        return switch (opt) {
        case None: None;
        case Some(v): Some(f(v));
        };
      }
    
      public static function newOption<A>(arg: A): Option<A> {
        return if (arg != null) Some(arg) else None;
      }
    }

こんな感じに使う。

    import haxe.ds.Option;
    using OptionOp;
    
    var x = 123.newOption(); // Scala の Option(123) 的な。
    x.map(function(v) { return v * 2; }); // Scala の x.map(_ * 2) 的な。

他にもいろいろ追加したのが[こちら](https://gist.github.com/tkawachi/7208040)。

関数リテラル書くのに毎度 `function` と書くのは長いが、まあまあ快適に書ける。
コンパイルするとこんな感じになる。

    var x = OptionOp.newOption(123);
    OptionOp.map(x,function(v) {
            return v * 2;
    });    

「えー。関数の呼び出しが多くて遅そう」という人は `inline` 化することもできる。
`map()`, `newOption()` の定義を `public static inline function ...` とするとこんな感じの出力に変わる。

    var x;
    x = haxe.ds.Option.Some(123);
    switch(x[1]) {
    case 1:
            haxe.ds.Option.None;
            break;
    case 0:
            var v = x[2];
            haxe.ds.Option.Some(v * 2);
            break;
    }

`Some()` 関数の呼び出しは残っているものの、 `map` 関数とその第二引き数で渡した関数の呼び出しは展開された。
これくらいなら速度的にも許容出来る人が多いんじゃない？
読みにくいから僕は inline 化しないけど。

Haxe でどうすればいいのかなと思っているのは Scala の for に相当するもの。
複数の Option があるとき全てが存在するときに何かをするには、 Scala の for を使えば

    for (v1 <- opt1; v2 <- opt2) yield { v1 と v2 の計算 }

みたいに書けるのだが、現在の自分の Haxe 知識レベルだと次のようになる。

    opt1.flatMap(function(v1) {
        return opt2.map(function(v2) { return v1 と v2 の計算 });
    });

なんか上手い書き方無いかなあ。
[monax](https://github.com/sledorze/monax) 使えばうまくかけるんだろうか？

## まとめ

JavaScript にアレルギーがあるひとは Haxe 触ると癒されるかも。
