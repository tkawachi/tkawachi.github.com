---
layout: post
title: RailsでTypeScript、再び
date: 2013-04-25 23:22
comments: true
categories: TypeScript Rails
---

Google で typescript rails と検索すると去年12月に書いた「[Rails で TypeScript を動かそうとして失敗した記録](http://tkawachi.github.io/blog/2012/12/09/trying-typescript-rails-out/)」というエントリが2番目に出てくる日々が続いている。
「TypeScriptをRailsで使いたい」と思った人たちは、検索結果を見て、ああ動かないのかと思うのだろう。

あれから状況は少しだけ改善した。
typescript-rails gem で `/// <reference>` が一部使えるようになった。
というか使えるようにする [patch](https://github.com/klaustopher/typescript-rails/pull/6) を出した。

この patch により、`node` コマンドをインストールしてあることが前提になったので注意されたし。

サンプルを作ろうと思い
[test.js.ts.erb](https://github.com/tkawachi/typescript-rails-sample/blob/051838b7/app/assets/javascripts/test.js.ts.erb)
を書いてみた。
`.js.ts` ファイルや `.d.ts` ファイルを参照できるようになっていることがわかると思う。
サンプル内でやっているように `jquery.d.ts` を参照して、 jQuery も使えるようになった。

一方で以下の問題が残っている。
TypeScript compiler に渡る際に違うディレクトリにコピーされるため、参照先を絶対パスで指定している。そのため `.erb` suffix を付ける必要がある。
また参照先の拡張子が `.js.ts`, `.d.ts` ならば大丈夫だが `.js.ts.erb` の場合、compiler が参照してくれない。

これらの問題を解消しないとちょっと本格利用はできないかなあ。
また時間がとれたらなんとかしたい。