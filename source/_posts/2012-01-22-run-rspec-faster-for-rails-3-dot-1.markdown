---
layout: post
title: "Run rspec faster for Rails 3.1"
date: 2012-01-22 21:07
comments: true
categories: [Rails, Rspec]
---

個人プロジェクトで Rails 3.1 のアプリケーションを書いていたのだが、`rake spec` の
実行が遅くてイライラしていた。
1回の実行に 10 秒程度が掛かっていた。
テスト実行は 0.5 ms 以下で終了していたので、残りの 9.5 s 以上は framework の開始
などに費やされていると想像される。

この状態で皆が満足するはずが無いと思い、少し調べたところ
[spork](http://spork.rubyforge.org/) が求めるもののようだ。
これはテスト用サーバを別プロセスで起動しておき、drb で rspec などによるテスト実行を
キックできるもののようだ。

また [guard-spork](https://github.com/guard/guard-spork) を使えば、
spork を用いたテストの実行をファイル書き換え時に行うことができるようだ。
またテスト結果の通知を Growl で行うことも出来るようだ。
<!-- more -->

## How to setup

Growl でテスト結果を通知するための gem が幾つか存在するのだが、今日(2012/1/22)
の時点では

* `growl` は Growl v1.3 に対応していない
* [`growl_notify`](https://github.com/scottdavis/growl_notify) は deprecated
* `ruby_gntp` は Growl v1.3 とともに動いた

というわけで `ruby_gntp` が良さそうだった。

Gemfile の :development, :test 周りを以下のように変更する。

``` ruby Gemfile
group :development do
  gem 'spork'
  gem 'guard'
  gem 'rb-fsevent', :require => false
  gem 'ruby_gntp'
  gem 'guard-rspec'
  gem 'guard-spork'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.6'
  gem 'webrat'
end
```

以下を実行。

``` sh
$ bundle install
$ spork --bootstrap
```

`spec/spec_helper.rb` が spork によって書き換えられているので編集する。
今までのコードを `Spork.prefork do … end` の中に入れてあげれば OK。
`.rspec` を編集し、`--drb` という行を追加する。

ここまでで spork が動作する。
``` sh
$ spork
# 別のターミナルで
$ rspec .
```

続いて guard の設定。

``` sh
$ bundle exec guard init spork
$ bundle exec guard init rspec
```

これで guard + spork が動作する。

``` sh
$ bundle exec guard start
```

あとはソースコードを書き換えたら自動でテストが実行され、結果が Growl で通知される。

ようやくテストを書くことが出来る。(実は今まで書いてなかった笑)