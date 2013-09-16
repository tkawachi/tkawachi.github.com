---
layout: post
title: "sbt build definition"
date: 2013-09-16 22:17
comments: true
categories: Scala sbt
---

[始める sbt](http://scalajp.github.io/sbt-getting-started-guide-ja/)
を以前読んだときは
[.sbt ビルド定義](http://scalajp.github.io/sbt-getting-started-guide-ja/basic-def/)
のところでぐっと難しくなってよくわからなくなった。
今日復習したのでメモ。

最初にまとめ。

* `key := value` は新しい設定項目を追加する関数のようなもの(`Setting[T]`)を定義する。
* `Setting[T]` の入力は変更されない。
* `.sbt` を読み込むと `Setting[T]` のリストができる。`Setting[T]` のリストは、依存関係を考慮してソートされた後に適用される。
* `.sbt` の空行で区切られた塊は Scala の式。文ではないので `val`, `object`, `class` などは書けない。
* `key := value` は `key.:=(value)` といったメソッド呼び出しを別の書き方にしたもの。
* sbtデフォルトの設定項目は
  [`sbt.Keys`](https://github.com/sbt/sbt/blob/0.13/main/src/main/scala/sbt/Keys.scala)
  に定義されている。
* `TaskKey[T]` は毎回計算されるキー。
* sbtコンソールでアクセスするときは `SettingKey[T]`, `TaskKey[T]` などを呼び出す際の第一引き数文字列を使う。
* キーの詳細はsbtコンソールから `inspect` で確認できる。

<!-- more -->

`Setting[T]` は、設定を入力に与えると、新しいキーと値のペアを追加したり、既存のキーを新しい値で追加したりといった変換を表す。
変換っていうのは、なにかを入力されたら、それを変更した結果を返すということで、関数みたいな概念で捉えればいいのだろう。
`Setting[T]`は関数型の精神に則り、入力値は変更しない。

`.sbt` ファイル中の `key := value` は変換(`Setting[T]`)を定義している。
たとえば `name := "hello"` とあれば、キーが`name`で値が`"hello"`のペアを追加・上書きする変換を定義する。
`T` は設定値の型なので、この場合は `Setting[String]` が定義されたことになる。

`.sbt` ファイルには変換が沢山含まれているので、結果として変換(`Setting[T]`)のリストができる。

`Setting[T]` のリストに、sbt のデフォルトの設定を入力すると、`.sbt`ファイルが反映された設定が得られる。
`Setting[T]`が入力値を変更しないのでsbtのデフォルトの設定は変更されない。


`.sbt` ファイルで `name := "hello"` と書いたら、`name.:=("hello")` のこと。
`key` の型は `SettingKey[String]` で、 `:=` は `String` を引数にとり `Setting[String]` を返す。
間違った型の値を代入しようとした場合には(例：`name := 1`)、型チェックでエラーになる。

`:=` メソッドの他にも `+=` （リストへの要素追加）などがある。

sbtに用意されている設定項目（キー）は
[`sbt.Keys`](https://github.com/sbt/sbt/blob/0.13/main/src/main/scala/sbt/Keys.scala)
object に `SettingKey[T]` 型で定義されている。
`.sbt`ファイルの内容が評価される時は `import sbt.Keys._` された状態なので、 `sbt.Keys._` はパッケージ修飾なしに参照できる。
[`sbt.Keys`](https://github.com/sbt/sbt/blob/0.13/main/src/main/scala/sbt/Keys.scala)
は重要。
設定項目を探すときにちょくちょく参照することになる気がする。

たとえば `name` はこんな感じ。

    val name = SettingKey[String]("name", "Project name.", APlusSetting)

前述のように`SettingKey[String]`であることがわかる。

[`sbt.Keys`](https://github.com/sbt/sbt/blob/0.13/main/src/main/scala/sbt/Keys.scala)
には `SettingKey[T]` 型以外にも、 `TaskKey[T]`, `InputKey[T]`, `AttributeKey[T]` 型の値が定義されてる。
`compile` のように sbt コンソールから入力するたびに実行してくれないと困るものは 
`TaskKey[T]` として定義されている。
たとえば `compile` はこんな感じ。

    val compile = TaskKey[Analysis]("compile", "Compiles sources.", APlusTask)

`SettingKey[T]`は一度計算されると結果が保持される。
`TaskKey[T]`は毎回計算される。
`SettingKey[T]`は`TaskKey[T]`に依存できない。

`InputKey[T]`, `AttributeKey[T]` はまだ知らない。

sbtコンソールから入力するのはキーコンストラクタの第一引き数の文字列。

    val scalacOptions = TaskKey[Seq[String]]("scalac-options", "Options for the Scala compiler.")

とあったら `scalac-options` がsbtコンソールから入力時に指定する文字列になる。
`sbt.Keys` に CamelCase で定義されたものは大体コンソール入力時には小文字、ハイフン区切りになっている。

キーに関する情報はsbtコンソールから `inspect キー名` で得られる。

`.sbt` ファイルの先頭に `import` 文を複数行書ける。`import` 文の間は空行をあけなくていい。
他の `SettingKey[T]` を参照するときに使うのかな。
