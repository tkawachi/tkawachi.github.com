---
layout: post
title: Play Framework 2.2 Scala 最初の1週間で困った雑多なこと
date: 2013-11-23 21:40
comments: true
categories: Play Scala
---

Play Framework 2.2.1 + Scala を触り始めて一週間くらいたった。
触りながら困った点（というか「疑問に思った」程度のものが多いが）をメモしていたので晒しておく。
雑なメモで無知を晒すのは恥ずかしいが、同じことではまる人がいるかもしれないもんね。

間違っているところがあったらコメントで教えてもらえると大変嬉しいです。

<!-- more -->

## Play 関連

### Q: app/assets/ と public/ の違いは？
A: app/assets は CoffeeScript, LESS など preprocess するもの。public はしないもの。

### Q: bindFromRequest すると Cannot find any HTTP Request here って出るよ。
A: Action の先頭に `implicit request =>` を付ける。
`Action { implicit request => ... }`

Action.apply() がオーバーロードされてて、引数が call by name のもの関数のものがある。

    def apply(block: => Result)
    def apply(block: Request => Result)

`implicit request =>` を付けたときは引数が関数の方。
request は implicit parameter。

### Q: なぜ Cannot find any HTTP Request here というエラーが出るの？
A: `scala.annotation.implicitNotFound` で annotation されているから。

### Q: bindFromRequest がエラーの時、どうやってエラー表示する？
A: `Form#fold` を使う

### Q: view 内で import したい
A: `@import some.package.MyClass`
view の先頭（かつ、パラメータの後！）でしか import 出来ないので注意。

### Q: view 先頭にあるパラメータの型指定で、@import したクラスが使えない
A: どうやらそういうものらしい。パッケージ名フル修飾で書く。

### Q: @helper.inputText() 等で出力される input tag に属性を付けたい（class とか）
A: Symbol -> Any のタプルをずらずらと渡す。

    @helper.inputText(userForm("name"), 'id -> "name", 'size -> 30)

### Q: @helper.inputText() 等で出力される input tag に紐づく label tag の名前を変えたい。
A: '_label -> "ほげ" を追加する。

    @helper.inputText(userForm("name"), '_label -> "ほげ")

`_label` 以外の特別なキーはここ。

http://www.playframework.com/documentation/2.2.x/ScalaCustomFieldConstructors

### Q: submit ボタン表示はどうするんだっけ？
A:

    @helper.form(...) {
      ...
      <button type="submit"></button> // ←ここに直接書く。
    }

### Q: Form の required という表示を消したい。`<dd class="info">Required</dd>`←これ
A: `'_showConstraints -> false` を `@helper.inputFoo()` に渡す。

### Q: war にできる？
A: war にできないぽい。
http://stackoverflow.com/questions/14985783/deploy-play-as-a-war-file-into-a-servlet-container-even-if-it-uses-jpa-heavily

### Q: deploy は?
A: play dist で zip にして展開するのが良さそう

### Q: Controller action の URL を得るには？
A: `routes.MyController.action(arg)`

http://www.playframework.com/documentation/2.2.x/ScalaRouting

### Q: Log の出し方は？
A: `play.api.Logger.info()` など。

## SecureSocial 関連

### Q: ユーザ登録まわりはモジュールある？ Rails の devise みたいな。
A: SecureSocial か play2-auth

* http://securesocial.ws/
* https://github.com/t2v/play2-auth

### Q: SecureSocial で SES からメール送れる？
A: SES の smtp interface で送れる。

### Q: SecureSocail のコントローラの path を view から逆引きするのはどうしたらいいのか?
A: `securesocial.core.providers.utils.RoutesHelper.login()` とか

### Q: SecureSocial で提供されるページとメールは国際化できるか？
A: http://securesocial.ws/guide/views-customization.html の手順でできそう。

### Q: メールアドレスとパスワードで登録したユーザと、Google認証のユーザが別ユーザになる。
統合する方法は用意されているか？
A: 用意されていない。

* https://groups.google.com/forum/#!topic/securesocial/at-qCKXvsE0
* https://github.com/jaliss/securesocial/issues/14

## DB 関連

### Q: evolution で manual rollback するには?
A: できない!

http://stackoverflow.com/questions/10069217/rolling-an-evolution-back

### Q: play-slick 使った時に migration 管理は含まれているのか？
A: evolutions の 1.sql を吐き出してくれる機能はある。

### Q: slick の for で foreach メソッドが無いとか言われる
A: `import scala.slick.driver.MySQLDriver.simple._`
したら通った。どういうこと..

### Q: Slick で JodaTime の DateTime 使いたい。
A: https://github.com/tototoshi/slick-joda-mapper

### Q: Slick で DateTime の大小比較はどうする？
A: < でいいっぽい。
`import com.github.tototoshi.slick.JodaSupport._ `が必要。

### Q: DateTime 比較時にこんなエラーが起きる

    com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ':26:48.548+09:00' at line 1

A: slick-joda-mapper が古かった(0.1.0だった)。0.4.0 にあげたら解消した。

### Q: Slick で発行されている SQL を表示するには?
A: http://stackoverflow.com/questions/14840010/how-do-you-print-the-select-statements-for-the-following-slick-queries によるとできない。

### Q: Slick から value filter is not a member of models.MyModel といわれる。
A: `Query()` でくるむといい。

### Q: play test すると Attempting to obtain a connection from a pool that has already been shutdown. と出る。
A:  http://d.hatena.ne.jp/tototoshi/20130329/1364484806

    FakeApplication(
      additionalConfiguration =
        inMemoryDatabase(name = "default", options = Map("DB_CLOSE_DELAY" -> "-1"))
    )

### Q: `new WithBrowser(app = dbApp)` （dbApp は DB_CLOSE_DELAY 指定した FakeApplication）でエラーになる
A: 第一引き数 webDriver も指定したらエラーでなくなった。（初期化順の問題？）

    new WithBrowser(webDriver = Helpers.HTMLUNIT, app = dbApp) 

### Q: Play で環境によって設定を変える仕組みが用意されているか？
A: `-Dconfig.file` で設定ファイルを切り替える

### Q: play-flyway で本番系 migration はどうやるの?
A: `-Ddb.default.migration.auto=true`

最初まちがって `-Ddb.default.migration.initOnMigrate=true` を指定して悩んでた。

### Q: Play で gzip を有効化できるか？
A: GzipFilter でできるっぽい。

http://www.playframework.com/documentation/2.2.x/GzipEncoding

appDependencies に filters を追加する必要あり。

### Q: Slick で MySQL に接続したら文字化けした
A:  character_set_client, character_set_server が utf8mb4 になっていることを
確認する。

サーバとクライアントのネゴシエーションで決まる。
Slick での character_set_client, character_set_server の確認方法。

    import scala.slick.session.Database
    import Database.threadLocalSession
    import scala.slick.jdbc.{GetResult, StaticQuery => Q}
    
    val jdbcUrl = "jdbc:mysql://localhost:3306/my_db?user=myUser&password=myPassword"
    Database.forURL(jdbcUrl, driver = "com.mysql.jdbc.Driver") withSession {
      val q = "SHOW VARIABLES LIKE 'char%'"
      Q.queryNA[(String, String)](q).foreach(println)
    }

サーバの設定で character_set_server を utf8mb4 に設定し、 JDBC には
characterEncoding=utf8mb4 をつけないのが正解ぽい。
JDBC URL に characterEncoding=utf8mb4 をつけると、例外がおきるので注意。

### Q: Play + Slick で driver に応じて、処理を変えたい。
A: こんな感じ。

    import play.api.db.slick.DB
    import scala.slick.driver.MySQLDriver
    if (DB("default").driver == MySQLDriver) {...}

### Q: MySQL 用に CREATE TABLE に CHARACTER SET 指定をしたいが、テストの H2 でエラー。
A: `/*! */` でくくると良い。

http://stackoverflow.com/questions/15885814/use-mysql-in-dev-prod-and-h2-in-test

`/*! CHARACTER SET utf8mb4 */;`
をつけておくと MySQL でだけ処理され、H2では処理されない。
