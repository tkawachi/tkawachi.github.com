---
layout: post
title: Bootswatchのテーマをtwitter-bootstrap-railsで使う
date: 2013-01-04 18:12
comments: true
categories: LESS Bootstrap
---

美的センスに乏しい私のようなプログラマにとってTwitter bootstrapが便利なことは言うまでもありませんが、知っている人には一見して「あ、Bootstrapだ」とわかるサイトになってしまいます。
これ自体は別に悪いことはないと思うのですが、他のサイトと見分けの付かないサイトになってしまうのは良くないですよね。

そこでbootstrap用のテーマを入れよう、となるわけです。
テーマを入れることで色・フォントなどが変更されるので、bootstrap臭が軽減されます。

bootstrap theme などで検索すると有償・無償を含めテーマを取り扱っているサイトが見つかると思いますが、今回は [Bootswatch](http://bootswatch.com/) を twitter-bootstrap-rails と共に使う方法をメモします。
bootstrap-sass, sass-twitter-bootstrap, less-rails-bootstrap の人は別の方法があると思います。

<!-- more -->

まず [Bootswatch の Gallery](http://bootswatch.com/#gallery) から使いたいテーマを選びます。
`vendor/assets/stylesheets/bootswatch/` ディレクトリを作り、選んだテーマの Download ボタンから `variables.less` と `bootswatch.less` をダウンロードして、このディレクトリに保存します。

`app/assets/stylesheets/` ではなく `vendor/assets/stylesheets/` 以下に `bootswatch` ディレクトリを作成して保存します。
なぜなら `app/assets/stylesheets/application.css.scss` にはデフォルトで ` *= require_tree .` という行があり、`app/assets/stylesheets/` 以下にある `.less` ファイルはすべて require されてしまうからです。
`variables.less`, `bootswatch.less` は `@import` するものであって、require するとエラーになります。
それに `vendor` というのはサードパーティ製のアレヤコレヤを置くところなので、きっとこっちが正解でしょう。

あとは `bootstrap_and_overrides.css.less` で `@import “twitter/bootstrap/responsive”;` の行のあとに以下の２行を付け足します。

```
@import “bootswatch/variables.less”;
@import “bootswatch/bootswatch.less”;
```

これでいける(少なくとも僕は使えてる)と思うんですが、ダメだったら教えて下さい。

参考

* [Customizing Twitter Bootstrap On Rails 3](http://bobonrails.com/post/29340795516/customizing-twitter-bootstrap-on-rails-3)