---
layout: post
title: Scalaのimplicit
date: 2013-09-28 22:16
comments: true
categories: Scala
---

Scala の implicit のお勉強メモ。

## なぜ implicit を使いたくなるか？

コード片を見ただけではわからなくなるので、暗黙的な記述はあまり使わない方がいいんじゃないかと個人的に思うのだけど。
それでも便利な使い道があるから使われているみたい。

今自分が知っているところで次のパターンがあるみたい。
他の便利な使い方もきっとあるんじゃなかろうか。

* 既存のクラスを変更せずにメソッドを追加したいとき (pimp my library pattern)。 implicit な関数, implicit なクラスを使う。
* 型パラメータ情報を実行時に使いたいとき。implicit パラメータをつかう。
* 共通のインタフェースを持たないクラス群に、共通のインタフェースをあとづけするとき (CONCEPT pattern)。implicit パラメータをつかう。

### pimp my library pattern

既存クラスに対してメソッドをあと付けしたいときに使う。
既存クラスが自分のメンテナンスできる範囲で書き換えてOKならこのパターン使わなくていいと思う。
既存クラスがサードパーティライブラリから提供されている場合など、書き換えられない、書き換えるのが面倒ときに使う。

やり方は 2.9 以前の場合は

1. 既存クラスをクラスのラッパークラスを定義する
2. 既存クラスからラッパークラスへの暗黙的変換関数を定義する(implicit 関数)

(pimp my library pattern)で、2.10 以降の場合は [implicit class](http://docs.scala-lang.org/overviews/core/implicit-classes.html) が導入されたのでこれを使うんだと思う。

ここでは `Int` 型に関数 `f1` をあと付けしたいとする。

#### pimp my libarary pattern

pimp my library pattern ではまずラッパークラスを定義して、

    class MyRichInt(x: Int) {
        def f1 = …
    }

暗黙的変換関数を定義する。

    object MyRichInt {
        implicit def intToMyRichInt(x: Int) = new MyRichInt(x)
    }

使う時は暗黙的変換関数を import すれば、メソッドが増えたように感じる。

    import MyRichInt._
    123.f1 // new MyRichInt(123).f1 相当


#### Implicit class

Implict class 2.10 から導入された機能。
pimy my library pattern が簡単に書けるようになった感じ。
こんな感じで定義。

    object Helpers {
        implicit class IntWithF(x: Int) {
            def f1 = …
        }
    }

使う時は import する。
既存クラスに存在しないメンバを呼び出した場合に、暗黙的に変換できるクラスにメンバがあれば、コンパイラさんが変換→呼び出しという風にしてくれる。

    import Helpers._
    123.f1 // new IntWithF(123).f1 相当

これでプログラマ的には既存の Int 型には無かったメンバ `f1` が増えたかのように扱える。

関連する項目として
[value class](http://docs.scala-lang.org/ja/overviews/core/value-classes.html)
がある。
これを一緒に使えば暗黙変換するとき `new` されなくなる（メモリ割り当てされなくなる）ので
使えるときは使うのがいい。
頻繁に使われるものの場合は速くなりそう。

### 型パラメータ情報を実行時に使いたいとき

JVMは型パラメータをコンパイル時に消しちゃうので実行時には型パラメータの情報は使えない。
`def f[A] = new A // 間違い` とかしたいときに困る。

そんなときは最後の引き数リストに implicit な `ClassTag` を受け取るようにすればいいみたい。

    def f[A](implicit c: ClassTag[A]) = c.runtimeClass.newInstance().asInstanceOf[A]

`c` 経由でインスタンスを作ったり出来る。
呼び出し時は `c` を渡す必要はない。
`f[Int]` などとして呼び出せる。

### CONCEPT pattern

既存のクラス群が共通インタフェースを持ってたらひとつの関数で同じように処理できるのに、、ってときに使うパターン。
既存のクラスが書き換えられるなら、インタフェースを新規に作って実装しちゃってもいいんじゃないかと思わなくもないけど、アルゴリズムに関連する部分は分けておきたいなんてこともあるのかもしれない。

この共通インタフェースのことを concept っていうらしい。

`Int` と `String` が両方共 `double` っていう関数を持っていたら、ステキなアルゴリズム（関数）がかけるのになあ、とする。

    trait DoubleConcept[A] {
        // 共通インタフェース
        def double(v: A): A
    }
    implicit val doubleInt = new DoubleCondept[Int] {
        // Int の double 定義
        def double(v: Int) = v * 2
    }
    implicit val doubleString = new DoubleConcept[String] {
        // String の double 定義
        def double(v: String) = v + v
    }
    
    def suteki[A](v: A)(implicit c: DoubleCondept[A]) = … // c.double(v) を使ったステキアルゴリズム
    
    suteki(123) // suteki(123)(doubleInt) 相当
    suteki("ABC") // suteki(ABC)(doubleString) 相当

型ごとの共通インタフェース実装を implicit val として定義しておいて、 implicit なパラメータリストでそれを暗黙的に渡す。
暗黙的過ぎて難しい。

ともあれ `suteki` 関数のなかでは `Int` と `String` が両方共 `double` という共通操作を持っているという前提で関数がかける。
`suteki`関数呼び出し時の `v` 引き数の型により、`c` が `doubleInt` なのか `doubleString` なのかはコンパイラが選択してくれる。

## 雑感

Scala の implicit は黒魔術。
使いたくなるパターンは多くなさそうなので用途を抑えておけば理解しやすい。
