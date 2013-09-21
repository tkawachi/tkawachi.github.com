---
layout: post
title: ActiveRecord のモデルを整理する7つのパターン
date: 2013-09-21 21:18
comments: true
categories: Ruby Rails ActiveRecord DesignPattern
---


[7 Patterns to Refactor Fat ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/)
という記事があり、読もう読もうと思いつつ1年くらい経ってしまった。
ようやく読んだので理解した内容を書いておく。
コード例は元記事のもの。

<!-- more -->

Rails で thin controller, fat model を心がけていると、model がマジで激太りしてヤバくなる。
実際に自分が仕事で書いている rails アプリも激太りしててヤバい。
この blog の筆者が作っている [CodeClimate](https://codeclimate.com/) で C 判定をもらう程度には肥満体型になっている。

## Mixinに抜き出さない!

Model が太ってきた時に考えるのは `ActiveSupport::Concern` を使って感心事を抜き出して、Mixin にすることだと思う。
実際に手元のアプリでも `models/concerns/` なんていうディレクトリがあったりする。

でもこれはアンチパターン。
Mixin は継承と同じように複雑さを増す。
やってみると、さほど綺麗に分けられないんだよね。
記事では mixin はするな、と書いてある。

ここからがパターンの紹介。

## 1. Value object の抽出

[Value object](http://en.wikipedia.org/wiki/Value_object)
は値が等しければ等しいとされるようなオブジェクトで、だいたいは immutable。
この value object を抜き出して、関連するロジックを抜き出したクラスに移す。

どんなときに使うか？
属性に強く結びついたロジックがあるとき。

例として挙げられているのは、電話番号、お金など。
CodeClimate には AからF の値をとる `Rating` value object があるらしい。

    class Rating
      include Comparable
    
      def self.from_cost(cost)
        if cost <= 2
          new("A")
        elsif cost <= 4
          new("B")
        elsif cost <= 8
          new("C")
        elsif cost <= 16
          new("D")
        else
          new("F")
        end
      end
    
      def initialize(letter)
        @letter = letter
      end
    
      def better_than?(other)
        self > other
      end
    
      def <=>(other)
        other.to_s <=> to_s
      end
    
      def hash
        @letter.hash
      end
    
      def eql?(other)
        to_s == other.to_s
      end
    
      def to_s
        @letter.to_s
      end
    end

`cost` から rating を計算するロジックと、比較ロジックがこのクラスに抜き出されている。
`#hash`, `#eql?` を定義しておくと、hash key として使うことができる。

ActiveRecord 側。
`rating` は DB に保存された値から計算される値みたい。

    class ConstantSnapshot < ActiveRecord::Base
      # …
    
      def rating
        @rating ||= Rating.from_cost(cost)
      end
    end

Value object として抜き出せるものがあれば、間違いなく抜き出したほうがいいね。

## 2. Service object の抽出

以下の基準の１つ以上に合致したときには service object の抜き出しを薦めている。

* アクションが複雑なとき
* アクションが複数のモデルに触るとき
* アクションが外部サービスとやりとりするとき
* アクションがモデルの主な関心事ではないとき
* アクションを実行するのにいくつもの方法があるとき（GoFのストラテジパターン）

以下の例はユーザ認証を行う service object。

    class UserAuthenticator
      def initialize(user)
        @user = user
      end
    
      def authenticate(unencrypted_password)
        return false unless @user
    
        if BCrypt::Password.new(@user.password_digest) == unencrypted_password
          @user
        else
          false
        end
      end
    end

ここで `user` がモデルで、認証というアクションを service object として抽出している。

結局のところ「複雑なメソッド（群）を見つけたら別のクラスにしましょう」ということかな。

## 3. Form object の抽出

フォームの submit で複数のモデルが更新される場合などに使うパターン。
以下の例は `User` と `Company` の両方を更新する。

    class Signup
      include Virtus
    
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
    
      attr_reader :user
      attr_reader :company
    
      attribute :name, String
      attribute :company_name, String
      attribute :email, String
    
      validates :email, presence: true
      # … more validations …
    
      # Forms are never themselves persisted
      def persisted?
        false
      end
    
      def save
        if valid?
          persist!
          true
        else
          false
        end
      end
    
    private
    
      def persist!
        @company = Company.create!(name: company_name)
        @user = @company.users.create!(name: name, email: email)
      end
    end

`Signup` クラスは [Virtus](https://github.com/solnic/virtus) を使うことで、
ActiveModel のように属性を持つことができる。
[`ActiveModel::Naming`](http://api.rubyonrails.org/classes/ActiveModel/Naming.html)と
[`ActiveModel::Conversion`](http://api.rubyonrails.org/classes/ActiveModel/Conversion.html)は、つけとくと良いことがあるみたい。
[`ActiveModel::Validations`](http://api.rubyonrails.org/classes/ActiveModel/Validations.html) を include することで validation も掛けられる。

## 4. Query object の抽出

複雑なクエリを発行するときは query object を使うといいかも。
放置されたアカウントを探す query object の例。

    class AbandonedTrialQuery
      def initialize(relation = Account.scoped)
        @relation = relation
      end
    
      def find_each(&block)
        @relation.
          where(plan: nil, invites_count: 0).
          find_each(&block)
      end
    end

コンストラクタに渡されているのは `ActiveRecord::Relation` のインスタンス。
他の条件がついた relation を渡すと、クエリを組み立てることができる。

    old_accounts = Account.where("created_at < ?", 1.month.ago)
    old_abandoned_trials = AbandonedTrialQuery.new(old_accounts)

この手のクラスは隔離した状態でのテストを頑張らず、DBにアクセスする形でテストしたほうがいい。

## 5. View object の導入

表示に限ったロジックを書いている場合には、それを抜き出すことを考える。
「もし別のインターフェース（例えば音声コントロールのUI）を実装するときに必要かな？」と考えて No なら view object が向いてる。
以下は Code Climate のドーナツチャートの例。

    class DonutChart
      def initialize(snapshot)
        @snapshot = snapshot
      end
    
      def cache_key
        @snapshot.id.to_s
      end
    
      def data
        # pull data from @snapshot and turn it into a JSON structure
      end
    end

## 6. Policy object の抽出

読み込みポリシーに特化したオブジェクト。
ビジネスルールをひとつカプセル化する。

Service object に似ているが、service object は操作、 policy object は読み込みを担当。
Query object にも似ているが、query object は SQL 発行、 policy object はメモリ上のドメインモデル読み込みを担当する。

    class ActiveUserPolicy
      def initialize(user)
        @user = user
      end
    
      def active?
        @user.email_confirmed? &&
        @user.last_login_at > 14.days.ago
      end
    end

上記の例は、だれが "active?" か、という定義を与えている。

## 7. Decorator の抽出

既存の機能の上に機能を足したいときに使うパターン。
たとえばコメント書き込み時に、Facebook wall へもポストするような時に使う。

    class FacebookCommentNotifier
      def initialize(comment)
        @comment = comment
      end
    
      def save
        @comment.save && post_to_wall
      end
    
    private
    
      def post_to_wall
        Facebook.post(title: @comment.title, user: @comment.author)
      end
    end