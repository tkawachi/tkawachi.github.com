---
layout: post
title: jQueryのDeferredとPromise
date: 2013-01-06 00:44
comments: true
categories: jQuery
---

JavaScript(というか CoffeeScript)って90年代にブラウザ上で使われていた頃のイメージが拭えず、どうも気持ち悪くて逃げて回ってたんですが、事情があって最近は渋々書いてます。
JavaScripterの皆様にとっては何を今更だとは思いますが [jQuery.Deferredを使って楽しい非同期生活を送る方法](http://qiita.com/items/3d1cf51d7ae91305eaaa) を読んで Deferred 便利だな、と思ったので理解したところをメモしておきます。

<!-- more -->

## 利用シーン

* `$.get()` ってエラーハンドリングできないのか。使えないなー。と思ったとき
* 複数の AJAX リクエスト(などの非同期処理)を同時に開始して、全部終わったら何かしたいとき。

## Deferred object

キーになるのは
[Deferred object](http://api.jquery.com/category/deferred-object/)
です。

### 状態

Deferred object は状態を持ちます。状態は３つのうちいずれか。

1. 未解決(unresolved)
2. 解決済み(resolved)
3. 拒否済み(rejected)

実装によってはいろいろ呼び名があるみたいですが、jQuery では上のように呼ばれています。
jQuery以外の、例えば CommonJS の
[Promises/A](http://wiki.commonjs.org/wiki/Promises/A)
では unfulfilled, fulfilled, failed がそれぞれの状態に対応します。

状態の遷移は「未解決→解決済み」「未解決→拒否済み」の二種類だけです。
一度、解決済みや拒否済みになったら未解決に戻ったりしませんし、解決済みから拒否済みへ遷移したりもしません。

## 利用者

このオブジェクトの利用者は

* a: 非同期処理をする人
* b: 非同期処理の結果を受ける人

の２人です。
aさんが状態遷移を担当し、bさんがそれに応じて処理を行う役割です。

Deferred object はaさんからbさんへ提供されますが、大抵の場合は Deferred の機能制限版である
[Promise object](http://api.jquery.com/Types/#Promise)
が bさんに渡されます。
状態遷移を起こすのはaさん担当で、bさんがそれをしてはまずいので、Promiseでは状態遷移関連のメソッドが取り除かれています。
Promise は Deferred の `.promise()` メソッドで得られます。

非同期処理の関数コール時の戻り値として a から b に Promise object が渡されます。
処理が終わったら結果を渡すから約束手形(Promise)をもっておいてくれ、というわけですね。

## 解決または拒否へ

aさんは非同期処理が終わったら約束通り結果を渡します。
引数に処理結果を渡して`.resolve()` メソッドを呼び出すことで、解決済み状態へ遷移します。

処理が失敗に終わった場合には `.reject()` を呼びます。

## 約束手形(Promise)の使い方

書いてて思ったのですが、約束手形は一定の期日に支払いをする約束であるのに対して、Promise はいつ処理が完了するかわからないので少し違いました。
どちらかというとカイジの
[その気になれば10年後20年後ということも可能だろう](http://fukumoto.lsx3.net/?%CC%DB%BC%A8%CF%BF%2F%CD%F8%BA%AC%C0%EE%B9%AC%CD%BA#b1869786)
という大金の引換券に似ています。

ともあれ、Promise はその時点では結果が出ていないので、すぐに結果を利用することができません。
代わりに callback を登録しておくことができます。

``` javascript
// 解決済みになったら呼ばれる callback を登録
promise.done(function(data) { dataは処理結果 });
// 拒否済みになったら呼ばれる callback を登録
promise.fail(function() { エラー処理 });
// 解決済みもしくは拒否済みになったら呼ばれる callback を登録
promise.always(function() { 処理 });
```

callback 複数登録する事ができ、登録した順に呼ばれます。例えば `done()` を複数回呼び出して解決済みになったときの callback を複数個登録することができます。

`done()`, `fail()`, `always()` は Deferred の場合は Deferred, Promise の場合は Promise を返すので、method chain でつなげることができます。

## 約束の組み合せ

受け取った Promise/Deferred は `$.when()` で組み合わせることができます。
組み合わせると、渡したものすべてが解決済みになったときに解決済みになる Promise が返されます。
組み合せにより、複数の非同期処理がすべて完了したら何かを実行することができます。

組み合わせた場合、 callback の引数に渡される結果も増えます。
以下のコードで d1, d2 にはそれぞれ promise1, promise2 の結果が渡されます。

``` javascript
$.when(promise1, promise2).done(function(d1, d2) { … });
```

`$.when()` に Defered でも Promise でもない値を渡した場合、解決済みの値として扱われます。

``` javascript
$.when(10, promise).done(function(d1, d2) { … });
```

などとした場合、10は解決済みと見なされ、`promise`が解決済みになり次第、`d1` に 10 が渡されて callback が実行されます。

## $.ajax の戻り値は Deferred

`$.ajax`, `$.get`, `$.post` など AJAX 関数群の戻り値 jqXHR は Deferred と同じインタフェースを備えています。
すなわち `$.when` を使って、複数の AJAX 通信がすべて完了したら次に…をするといったコードが簡潔に書けます。

また `$.get` などはエラーコールバックを引数に取れませんが、戻り値は Deferred ですので、これに `.fail()` を呼び出すことでエラーコールバックを登録することができます。
今まで使えない子だと思っていたのですが、僕が知らないだけでずっと前に使える子になってたんですね。

## まとめ

なんだか長くなってしまった。まとめ。

* Deferred は３状態をもつ
* 解決済み、拒否済みになった時に実行するコールバックを登録できる
* Promise は Deferred の機能制限版 (結果をもらう人向け)
* `$.when` で Deferred/Promise を組み合せられる
* `$.ajax`, `$.get`, etc. の戻り値は Deferred