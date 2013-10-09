---
layout: post
title: Covariantとcontravariant
date: 2013-10-09 23:06
comments: true
categories: scala covariant contravariant invariant
---

今日 [Functional Programming Principles in Scala](https://www.coursera.org/course/progfun) で聞いた話が難しかったのでメモ。

<!-- more -->

## Subtype

書き方として A <: B と書けば A は B の subtype であることを示す。
A >: B と書けば A は B の supertype、言い換えれば B は A の subtype であることを示す。

Subtype とは何か？というのは Liskov substitution principle というので定義されている。
「A <: B であれば、B型の値に対して出来ることならなんでもA型の値に対して出来る」ということらしい。

クラス階層で言えば、 A <: B というのは A が B の subclass または A == B ってこと。

Subtype の概念はクラス階層にとどまらない。
こんな型が定義されていたら、

    class Base
    class Derived extends Base
    type A = Base => Derived
    type B = Derived => Base

A と B の間にクラス階層はないが、B がおける場所には A もおける。
つまり A <: B。
なぜなら

* B の引き数は Derived で A の引数は Base なので、B の引き数ならなんでも A の引き数として使える
* B の戻り値は Base で A の戻り値は Derived なので、A の戻り値ならなんでも B の戻り値として使える

から。

関数の場合は一般に A2 <: A1 かつ B1 <: B2 のときに (A1 => B1) <: (A2 => B2) が成り立つ。
理由は上と同じ。

## Variant

C[T]がパラメータ化された型で A, B が A <: B であるとき、C[A] と C[B] の関係は3パターン。

* C[A] <: C[B] -- このとき C は covariant（共変）
* C[A] >: C[B] -- このとき C は contravarinat（反変）
* C[A] と C[B] の間に subtype の関係なし -- このとき C は invariant（不変）。nonvariant とも言うらしい。

Scala ではタイプパラメタの前に `+` とか `-` とかつけて covariant や contravariant を表現する。何も付けなかったら invariant ね。

    class C[+A] // C は covariant
    class C[-A] // C は contravariant
    class C[A]  // C は invariant

Function object は covariant, contravariant を使ってる。

    trait Function1[-T, +U] {
        def apply(x: T): U
    }

`A => B` は `Function[A, B]` と同じ。
で、`Function1` の T は contravariant, U は invariant ということなので、

    class A1
    class A2 extends A1
    class A3 extends A2

とあったときに `A2 => A2` 型の値は `A3 => A1` 型が求められるところならどこでも使える。

### Java の配列

Java の配列は covariant。

    class Base {…}
    class Derived1 extends Base {…}
    class Derived2 extends Base {…}

が定義されていてると以下の様なことができる。

    Derived1[] a = new Derived1[]{ new Derived1() }
    Base[] b = a
    b[0] = new Derived2()
    Derived1 s = a[0]

1行目は普通。

2行目は super class である `Base` の配列に代入しようとしている。
`a` には `Base[]` 型がきて欲しいが、Java の配列は covariant なので `Base[]` が来れる場所には `Derived1[]` が来ても良い。
なので2行目も通る。

3行目では `b[0]` に値を代入している。
`b[0]` の型は `Base`。
`Derived2` は `Base` の subclass なので問題ない。

4行目では `Derived1` 型の `a[0]` を別の `Derived1` 型の変数に代入している。
これも問題無さそう。

という訳でコンパイルは通る。
でも `a` と `b` は同じ配列を指していて、3行目で `Derived2` 型の値に入れ替えてる。
だから `a[0]` （と`b[0]`）には `Derived2` 型の値が入っているはず。
4行目ではそれを `Derived1` 型の値に代入している。
なにかおかしい。

Javaではコンパイルエラーにはならず、3行目実行時に ArrayStoreException が投げられる。
残念。

## Scala の variance check

Java の（問題含みの）配列を scala 的に表現すると

    class Array[+T] {
        def update(x: T)
    }

となる。
問題は covariant な型パラメータ T がメソッドの引数になっていること。

Scala のコンパイラはこの問題を防ぐために variant check というものを行う。
いろいろ細かいルールはあるそうだが、大まかには以下のとおり。

* covariant な型パラメータはメソッドの戻り値にしか使っちゃダメ
* contravariant な型パラメータはメソッドのパラメタにしか使っちゃダメ
* invariant な型パラメータはどこに使ってもいい

Function1 を見なおしてみるとルールに合致していることが確認できる。

    trait Function1[-T, +U] {
        def apply(x: T): U
    }

contravariant な T はパラメタにきており、covariant な U は戻り値にきている。
問題なし。

Scala では immutable な collection は covariant, mutable な collection は invariant になっているらしい。
きっと Java の例にあるような実行時エラーをコンパイル時に捕まえるにはそうするしか無いんだろうな。

## List を covariant にする話

    trait List[+T] {…}
    object Nil extends List[Nothing] {…}
    class Cons[T] extends List[T] {…}

みたいな感じ。

`Nil` のときの `T` は `Nothing`。
`Nothing` は全ての型の subtype（`Nothing` <: なんでも）。
List は covariant なので `List[Nothing]` <: `List[なんでも]` となる。
どの `T` の `List[T]` に対しても `Nil` を使えるので便利。

リストの先頭に要素を追加する `prepend` メソッドを定義したい。

    trait List[+T] {
        def prepend(elem: T): List[T] = new Cons(elem, this)
    }

一見これで良さそうだが、
`error: covariant type T occurs in contravariant position in type T of value elem`
というコンパイルエラーになる。
Variance check が活躍してる。
たしかに covariant な型パラメータは戻り値にしか使っちゃいけなかったんだ。

正しい定義はこうなる。

    trait List[+T] {
        def prepend[U >: T](elem: U): List[U] = new Cons(elem, this)
    }

これは variance check を通る。U は contravariant で引き数のところに使われているから。
戻り値型は `List[U]` だが U そのものじゃないので contravariant 扱いじゃないんだろう。

    class Base
    class Derived1 extends Base
    class Derived2 extends Base
    def f(xs: List[Derived1], x: Derived2) = xs.prepend(x)

さてこのとき `f()` の戻り値型はなんだろうか？
`prepend()` の戻り値なので `List[U]` 型になるはず。
`xs` が `List[Derived1]` 型なので `T` は `Derived1` で決まり。

`U`を決めるのに型推論が活躍する。
`U` は `x` の型なので `Derived2` だろうか？
しかし  `Derived2` だとすると `U >: T` が満たせない（`Derived2` は `Derived1` の supertype ではない）。
というわけで型推論さんは、`Derived2` と `Derived1` の共通の親である `Base` が `U` だと結論付ける。
したがって `f()` の戻り値型は `List[Base]` ということになる。
