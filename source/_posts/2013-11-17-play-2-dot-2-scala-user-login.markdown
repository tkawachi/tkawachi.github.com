---
layout: post
title: "Play framework 2.2.1 scala でユーザ登録"
date: 2013-11-17 18:36
comments: true
categories: Play Scala SecureSocial
---

Play framework 2.x を触り始めていて、まず最初にユーザ登録とログインを
扱いたいと思った。
Rails であれば devise で、というところだが、Play ではどうなっているのだろう？

Sample としてついてくる zentask や、
「play scala ユーザ登録」でググって上の方に出てくる
[ペ](http://akiomik.hatenablog.jp/entry/2013/02/07/211054)
[ー](http://how-to-use-playframework-20.readthedocs.org/en/latest/subdocs/initial_create_application.html)
[ジ](http://d.hatena.ne.jp/sy-2010/20110517/1305650450)
を見ると、いずれもパスワードを生で保存している。

パスワードは生で保存していると何かの拍子に痛い目に合うので、真似したくない。
きっと Rails の devise みたいに再利用できるコンポーネントがあるだろうから、
それを使いたい。

Google+ のコミュニティで訪ねてみたところ[SecureSocial](http://securesocial.ws/) と 
[play2-auth](https://github.com/t2v/play2-auth)
を教えてもらった。
SecureSocial を試してみる。

<!-- more -->

Play は 2.2.1, Scala でやる。

プロジェクト作成。アプリ名はログインしたいだけだから `just-login` にする。

    $ play new just-login

http://securesocial.ws/guide/installation.html に従って進めていく。

project/Build.scala を追加。

    import sbt._
    import Keys._
    
    object ApplicationBuild extends Build {
        val appName         = "just-login"
        val appVersion      = "1.0-SNAPSHOT"
    
        val appDependencies = Seq(
            "securesocial" %% "securesocial" % "2.1.2"
        )
        val main = play.Project(appName, appVersion, appDependencies).settings(
            resolvers += Resolver.url("sbt-plugin-releases", new URL("http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/"))(Resolver.ivyStylePatterns)
        )
    }

重複した情報になるので、 build.sbt からは `name` と `version` を削除した。

conf/route にルーティング追加。それっぽいエンドポイントが一式備わってて、それっぽい感じ。

    # Login page
    GET     /login                      securesocial.controllers.LoginPage.login
    GET     /logout                     securesocial.controllers.LoginPage.logout
    
    # User Registration and password handling 
    GET     /signup                     securesocial.controllers.Registration.startSignUp
    POST    /signup                     securesocial.controllers.Registration.handleStartSignUp
    GET     /signup/:token              securesocial.controllers.Registration.signUp(token)
    POST    /signup/:token              securesocial.controllers.Registration.handleSignUp(token)
    GET     /reset                      securesocial.controllers.Registration.startResetPassword
    POST    /reset                      securesocial.controllers.Registration.handleStartResetPassword
    GET     /reset/:token               securesocial.controllers.Registration.resetPassword(token)
    POST    /reset/:token               securesocial.controllers.Registration.handleResetPassword(token)
    GET     /password                   securesocial.controllers.PasswordChange.page
    POST    /password                   securesocial.controllers.PasswordChange.handlePasswordChange
    
    # Providers entry points
    GET     /authenticate/:provider     securesocial.controllers.ProviderController.authenticate(provider)
    POST    /authenticate/:provider     securesocial.controllers.ProviderController.authenticateByPost(provider)
    GET     /not-authorized             securesocial.controllers.ProviderController.notAuthorized

次に `conf/play.plugins` を作成し、以下の内容を記述。
ユーザ名とパスワードでログインしたいだけなので、
Twitter やら Facebook やらでログインするためのプラグインはざっくり削る。

    1500:com.typesafe.plugin.CommonsMailerPlugin
    9994:securesocial.core.DefaultAuthenticatorStore
    9995:securesocial.core.DefaultIdGenerator
    9996:securesocial.core.providers.utils.DefaultPasswordValidator
    9997:securesocial.controllers.DefaultTemplatesPlugin
    9998:service.UserServiceImpl
    9999:securesocial.core.providers.utils.BCryptPasswordHasher
    10004:securesocial.core.providers.UsernamePasswordProvider

`9998:service.UserServiceImpl` の行に書いた `service.UserServiceImpl` は
自分の環境に合わせて実装する必要がある。

[InMemoryUserService.scala](https://github.com/jaliss/securesocial/blob/master/samples/scala/demo/app/service/InMemoryUserService.scala)
の内容をコピってきて、パッケージ名を `service` に、クラス名を `UserServiceImpl` に
変えて、 `app/service/UserServiceImpl.scala` として保存する。

http://securesocial.ws/guide/configuration.html にのっとって
`conf/application.conf` に `smtp` の設定と、 `include "securesocial.conf"` を書く。
`conf/securesocial.conf` は `Sample configuration` の内容を書く。
`assetsController=controllers.ReverseMyCustomAssetsController` は
Asset のコントローラを自前で作っているときだけ必要ぽいので、コメントアウトする。

[MailerPlugin のソース](https://github.com/typesafehub/play-plugins/blob/master/mailer/src/main/scala/com/typesafe/plugin/MailerPlugin.scala)
を眺めるとわかるように `smtp.mock = true` を設定しておけば実際のメールは送信されず、
コンソールにメールの内容が出力される。

    smtp {
        ... 他の設定
        mock = true
    }

ここまでで、ユーザ登録とログイン、ログアウト、パスワード忘れが実現できた。
パスワードが生で保存されることはなく、`BCryptPasswordHasher` によって生成された hash が格納される。

UserService はメモリ上じゃなく、DBへ格納するように実装することになる。
その際は
https://github.com/jaliss/securesocial/pull/163/files
のコードが参考になりそうだった。

## まとめ

* [SecureSocial](http://securesocial.ws/) を使えば Play 2.2 + scala でユーザ登録・ログイン・パスワード忘れが簡単に実現できる
* Rails の devise のように DB の schema は出してくれないので、比べると少し面倒かな...

