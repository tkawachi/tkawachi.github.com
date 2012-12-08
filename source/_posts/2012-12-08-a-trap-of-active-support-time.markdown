---
layout: post
title: ActiveSupport 日時計算の罠
date: 2012-12-08 11:03
comments: true
categories: ActiveSupport Ruby Rails
---

ActiveSupport の日時計算はとても便利です。直感的な記法でスラスラ書けちゃいます。
でもハマるポイントもありますので注意してください。
というか昨日僕がやらかしたことの告白です。

下のコードを見てください。

``` ruby
t1 = Time.new(2012, 12, 1)

t2 = t1 + 1.day
t2 - t1 == 1.day # => true

t3 = t1 + 1.month
t3 - t1 == 1.month # => false
```

a = b + c だったら普通 a - b = c だろうと思うのですが、最後の式は false を返します。
なぜだかわかりますか？

<!-- more -->

`t1` は 2012年1月1日ですから、`t3 = t1 + 1.month` によって `t3` には１か月後の 2012年1月2日が入ります。
具体的には
[Date#advance](https://github.com/rails/rails/blob/3-2-stable/activesupport/lib/active_support/core_ext/date/calculations.rb#L108-L116)
の中で `Date#>>` を使って１か月後の日付が計算されています。

`Time` インスタント間の引き算はふたつの時刻間の秒数を返します。
`t3 - t1` は 2012年1月1日から2012年2月1日までの秒数である `2678400.0` を返します。
これと `1.month` を比較するのですが、`1.month` は `30.days` つまり `2592000` 秒となります。

足す時は1ヶ月(2012年1月1日に足す場合は31日間)なのに、比較時は30日間と比較していたために等式が成り立たないということでした。
たしかに時刻差だけを与えられた場合、それが何ヶ月分かはわからないですよね。

month 以外の `Duration` である days, minutes, seconds では単位時間が常に同じであるため、このような症状はおきません。
year に関してはうるう年の時に同じ症状が発生します。

わかってしまえばなんともないが、知らないとハマりやすいポイントでした。