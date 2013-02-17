---
layout: post
title: 使わないと損なバックエンドサービス
date: 2013-02-17 18:47
comments: true
categories:
---

[slash7](http://slash7.com/company/) の Thomas Fuchs さんが自分たちのサービス 
[Freckle で使っている有償サービス群を紹介](http://mir.aculo.us/2013/02/16/running-a-saas-here-are-some-services-youll-find-useful/)している。
小さいチームでは自分のビジネスのコアに集中し、それ以外の部分に力を分散させるべからずというのはまさにその通り。

紹介されていたサービスは以下のとおり。
知らないサービスもいくつかあるなあ。

<!-- more -->

* [Travis Pro](http://beta.travis-ci.com/)
  ([ドキュメント](http://about.travis-ci.org/docs/user/travis-pro/))
  CI(継続的インテグレーション)サービス。
  Open source 製品は Pro じゃない方が使える。
* [NewRelic](http://newrelic.com/) 性能監視サービス。これは僕も使ってる。
* [Postmark](https://postmarkapp.com/) メール配送サービス。メールを送るならマスト、らしい。メール受信もできるらしい。
  同種のサービスは[沢山ある](http://socialcompare.com/en/comparison/transactional-emailing-providers-mailjet-sendgrid-critsend)。
  例えば[SendGrid](http://sendgrid.com/)。
* [Honeybadger](https://www.honeybadger.io/) Rails用のエラー管理ツール。
  僕は [Exceptional.io](http://www.exceptional.io/) を使っている。
* [DocRaptor](http://docraptor.com/) HTML から PDF を生成するツール。請求書ダウンロードで使っているらしい。
* [Logentries](https://logentries.com/) Log管理サービス。
  複数サーバのログが同じ時系列で見える。検索可能。
  同種のサービスに [Loggly](http://loggly.com/) がある。
* [Dome9](http://www.dome9.com/) ファイアウォール設定サービス。
  iptablesでごにょごにょしなくてもいいらしい。
* [Webmon](http://webmon.com/) と [pingdom](https://www.pingdom.com/)。
  サービスの可用性を測るサービス。
  pingdom のほうは[こういうステータス表示](http://status.letsfreckle.com/)もできるようだ。
* [Dead Man’s Snitch](https://deadmanssnitch.com/) Cron が走ってなかったらメールしてくれるサービス。
* [PagerDuty](http://www.pagerduty.com/) アラートを集めてメールなどで通知するサービス。
  同種のサービスに[OpsGenie](http://www.opsgenie.com/)。
* [Tinfoil](https://www.tinfoilsecurity.com/) と [Trustwave](https://www.trustwave.com/)。
  セキュリティをチェックし、脆弱性がある場合に教えてくれるサービス。
* [KISSmetrics](http://www.kissmetrics.com/)。メトリックスおよびイベントトラッキングサービス。
* [Customer.io](http://customer.io/) お知らせメール送信サービス。

すでに適正価格でやってくれるサービスがある場合、それを使わないで自分で作るのは馬鹿げています。使えるものは使いましょう。

  