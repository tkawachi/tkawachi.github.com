---
layout: post
title: テストデータのセットアップに trait を使う
date: 2013-09-23 23:59
comments: true
categories: Scala
---

9月半ばから始まった
[Functional Programming Principles in Scala](https://www.coursera.org/course/progfun)
を受講している。
課題内のテストの書き方でこうやるのか、というところがあったのでメモ。

テストケース間でデータを共有したいときがある。
たとえば以下の例では `data1` と `data2` が共通なので共通化したくなる。

    class FooSuite extends FunSuite {
        test("test A") {
            val data1 = new FooData(…)
            val data2 = new FooData(…)
            // tests with data1 and data2
        }
    
        test("test B") {
            val data1 = new FooData(…)
            val data2 = new FooData(…)
            // another tests with data1 and data2
        }
    }

普通は以下のようにメンバ変数にしたくなると思う。

    class FooSuite extends FunSuite {
        val data1 = new FooData(…)
        val data2 = new FooData(…)

        test("test A") {
            // tests with data1 and data2
        }
    
        test("test B") {
            // another tests with data1 and data2
        }
    }

この方法は少し問題がある。

* `new FooData(…)` が例外を出した場合に、`FooSuite` のインスタンス化に失敗するという問題がある
* `FooData` が mutable な場合に、前に実行したテストの内容により結果が変わる可能性がある

課題のテストケースでは trait を使って以下のようにしていた。

    class FooSuite extends FunSuite {
        trait TestData {
            val data1 = new FooData(…)
            val data2 = new FooData(…)
        }

        test("test A") {
            new TestData {
                // tests with data1 and data2
            }
        }
    
        test("test B") {
            new TestData {
                // another tests with data1 and data2
            }
        }
    }

各テスト内で `TestData` trait を継承した無名クラスを作り、無名クラスのコンストラクタ内でテストを実行する。
こうすることで `new FooData(…)` の実行はテスト実行時になり、各テストごとにデータが初期化されるので、上にあげた問題が解消する。

[Sharing fixtures](http://www.scalatest.org/user_guide/sharing_fixtures) をみると他の方法もいろいろある。
一番上にある Calling get-fixture methods が一番単純ぽい。
この方法で例を書き換えるとこうなる。

    class FooSuite extends FunSuite {
        def fixture = new {
            val data1 = new FooData(…)
            val data2 = new FooData(…)
        }

        test("test A") {
            val f = fixture
            // tests with f.data1 and f.data2
        }
    
        test("test B") {
            val f = fixture
            import f._
            // another tests with data1 and data2
        }
    }

無名クラスのメンバとしてテストデータを作る。
こっちのほうがインデント少なくていいかも。
`import f._` すれば `f.` prefix 要らないしね。
`new` のあとクラス名無くてもコンパイル通るんだ… 知らなかったよ。
