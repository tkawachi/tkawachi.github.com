---
layout: post
title: "ScalaTestでMockito"
date: 2013-08-26 10:14
comments: true
categories: Scala ScalaTest Mockito
---

ScalaTestでMockitoを使うためのお勉強ノート

## Setup

`build.sbt` に追加。

    libraryDependencies ++= Seq(
      "org.scalatest" %% "scalatest" % "1.9.1" % "test",
      "org.mockito" % "mockito-core" % "1.9.5" % "test"
    )

テストで `MockitoSugar` を mixin し、以下の import 行を追加。

    import org.mockito.Matchers._
    import org.mockito.Mockito._

## Mock作成

    // ClassToMock のモックを作成
    val m = mock[ClassToMock]

作ったモックはデフォルトで全メソッドコールに対して `null` を返す。
メソッドの戻り値として`null`ではなくモックを返したい時は次のようにする。

    // メソッド呼び出しでモックを返すモック
    mock[ClassToMock](RETURNS_MOCKS)
    // 返されたモックもモックを返すモック
    mock[ClassToMock](RETURNS_DEEP_STUBS)

## 引数に応じて戻り値を変える

`when(メソッド呼び出し).thenReturn(戻り値)` で登録する。
メソッド呼び出し部の引き数には `any` で任意の型の任意の値に、`anyString`, `anyBoolean`, `anyByte`, `anyChar`などで基本的な型の任意の値に `anyVararg` で任意の可変引き数にマッチさせることができる。

    // m.method1(何か) が呼ばれたら 10 を返す
    when(m.method1(any)).thenReturn(10)

引数が２つ以上あり、いずれかで `any` などのマッチャーを使った場合には、他の引き数もマッチャーにする必要がある。
オブジェクトが等しいことを示すマッチャーは `eq(obj)` で作れる。

後から登録したものが先にマッチするので、条件のゆるいもの（マッチ範囲が広いもの）を先に書く。

### １回目、２回目で違う値を返す

`thenReturn()` の可変引き数版を使う

    // 最初は 10, 次は 20, それ以降はずっと 30 を返す
    when(m.method1()).thenReturn(10, 20, 30)

## 例外を起こす

    // method1() が呼ばれたら例外を起こす
    when(m.method1()).thenThrow(new RuntimeException("Gau gau"))

`thenReturn` と同じように１回目、２回目で違う例外を起こすことも可能。
むしろ `thenReturn` と組み合わせることができる。

    when(m.method1())
      .thenReturn(10, 20) // １回目は10, ２回目は20を返す
      .thenThrow(new FooException, new BarException) // ３、４回目は例外
      .thenReturn(30) // ５回目以降は30を返す

## オブジェクトの一部をモックする(spy)

`mock[ClassToMock]` はフルのモック。一部だけモックしたい場合はこっち。`spy`と呼ぶ。

    // obj は普通のオブジェクト
    val s = spy(obj)
    // s.method1(何か) が呼ばれたら obj の実装を使わずに 10 を返す。
    doReturn(10).when(s).method1(any[ClassOfArg])

`thenReturn` が `doReturn` になって順番が代わり、メソッド呼び出しも `when` の外に出す。
`thenReturn`の書き方では実際のメソッドが呼ばれるので、呼ばれては困るときにこちらの書き方をする。

この記法の場合は `any` を使うときに型を指定しなければならなかった
（理由はわかってない）。

## メソッドが呼び出されたことを確認する(verify)

`when()`, `thenReturn()`, `doReturn()` などは関数呼び出しの前に用意する。
用意したものがテスト中で呼び出されなくても問題ない。

呼び出されたことを確認するには `verify()` を使う。

    // テストを実行
    m.method1(123);
    // method1() が何らかの整数引き数で呼び出されたことを確認
    verify(m).method1(anyInt);

複数回呼び出されたことを確認するときは、`verify()`の第二引き数で回数指定をする。

    // 2回呼び出されたことを確認
    verify(m, times(2)).method1(anyInt)
    // 少なくとも2回
    verify(m, atLeast(2)).method1(anyInt)
    // 多くとも3回
    verify(m, atMost(3)).method1(anyInt)

### 呼び出されてないことを確認する

`never` を使う。

    // 一度も呼ばれてないことを確認
    verify(m, never).method1(anyInt)

## より進んだ使い方

[Mockitoのドキュメント](http://docs.mockito.googlecode.com/hg/latest/org/mockito/Mockito.html)
に書いてある。