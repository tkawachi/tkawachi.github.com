---
layout: post
title: Rails で TypeScript を動かそうとして失敗した記録
date: 2012-12-09 11:27
comments: true
categories: TypeScript Rails
---

Microsoft 発の型付き JavaScript こと TypeScript が人気ですね。
[typescript-rails](https://github.com/klaustopher/typescript-rails) という gem があったので、動くのか試してみました。

結論から言っておくと、他のスクリプトやライブラリを参照する TypeScript をコンパイルすることが今回はできませんでした。

<!-- more -->

``` sh
$ rails new typescript-rails-test -T
$ echo 'gem "typescript-rails"' >> Gemfile
$ bundle
$ bundle exec rails g controller test index
      create  app/controllers/test_controller.rb
       route  get "test/index"
      invoke  erb
      create    app/views/test
      create    app/views/test/index.html.erb
      invoke  helper
      create    app/helpers/test_helper.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/test.js.coffee
      invoke    scss
      create      app/assets/stylesheets/test.css.scss
$ rm app/assets/javascripts/test.js.coffee
$ echo 'alert("Hello TypeScript")' > app/assets/javascripts/test.js.ts
$ bundle exec rails s
```

これで http://localhost:3000/test/index にアクセスすると、正しく alert が表示される。
いいぞ。

次に JQuery が使ってみたい。
``` javascript app/assets/javascripts/test.js.ts
$(function() {
  alert("document ready")
})
```

うーむ。エラーがおきた。

``` text
SyntaxError: (4,1): The name '$' does not exist in the current scope
  (in /Users/kawachi/gitworks/typescript-rails-test/app/assets/javascripts/test.js.ts)
```

[Issue #5](https://github.com/klaustopher/typescript-rails/issues/5)
に報告されている問題と同一。
`/// <reference path="jquery.d.ts" />` という行をいれて `$` の存在を TypeScript compiler に知らしめねばならないらしいが、これが今のところできないようだ。

[https://github.com/TimothyKlim/typescript-ruby/issues/1](https://github.com/TimothyKlim/typescript-ruby/issues/1)
によれば、compiler 内の IO class が利用している CommonJS の機能を ExecJS が隠してしまっているのが原因とのこと。
ExecJS を経由せずに直接 Node.js を叩けばいいのでは、と。

これが ExecJS から node を叩くときにソースコードをラッピングするものだが、
よく見ると module, exports, require, console が undefined にされていることがわかる。(`result = program();` のところで引数に何も渡されていない)
隠されている CommonJS の機能とはきっとこのことを言っているのだろう。


``` javascript execjs/support/node_runner.js
(function(program, execJS) { execJS(program) })(function(module, exports, require, console) { #{source}
}, function(program) {
  var output, print = function(string) {
    process.stdout.write('' + string);
  };
  try {
    result = program();
    if (typeof result == 'undefined' && result !== null) {
      print('["ok"]');
    } else {
      try {
        print(JSON.stringify(['ok', result]));
      } catch (err) {
        print('["err"]');
      }
    }
  } catch (err) {
    print(JSON.stringify(['err', '' + err]));
  }
});
```

[このへん](https://github.com/sstephenson/execjs/issues/91)
をみると ExecJS の作者は、副作用を与えるこれらの機能を ExecJS に取り込むつもりは毛頭ないようだ。

上のコードを手元で少し書き換えて module, exports, require を書き潰さないようにしてみたが、やはり同じエラーが出た。
ということは、これらの関数が undefined になっていることが直接の理由ではないということか。

[JavaScript 処理系 Rhino で TypeScript コンパイラのビルドを試してみた](http://vividcode.hatenablog.com/entry/ts/run-on-rhino)
によると TypeScript がサポートしているのは Node.js と JScript だけなので、Node.js の存在を前提として TypeScript compiler を動かすモジュール作ったほうが早そうな感じ。

時間が取れたら作りたいな。
