---
layout: post
title: "Inside Play! continuation -- JavaFlow"
date: 2011-12-22 21:47
comments: true
categories: 
---

Play! 1.x 系 では version 1.2 から continuation (継続)が導入されました。
これを使ってController処理を一時中断、終わったら再開して応答を返す、なんてことをしているみたいです。
これによって、HTTP処理スレッドは他のリクエストの処理にかかることができ、不要な待ち時間を少なくすることができるようです。
興味深いですね。

Continuation の実装として [JavaFlow](http://commons.apache.org/sandbox/javaflow/) が使われています。
JavaFlow の日本語記事はほとんど見当たらない様子ですので、 Play! の continuation 理解を深めるためにも、JavaFlow を触ってみたいと思います。

## JavaFlow の入手

[Downloadページ](http://commons.apache.org/sandbox/javaflow/downloads.html)
を見てみると、現時点でリリース版は無いことがわかります。(なんと！)
「初版もリリースされていないライブラリを使っていたのか」と思う気持ちを押さえて `svn co` しましょう。

    $ svn co http://svn.apache.org/repos/asf/commons/sandbox/javaflow/trunk/ javaflow

`pom.xml` が含まれているので Maven project ですね。依存関係を全て含んだ .jar を作りたかったので
[ここ](http://stackoverflow.com/questions/574594/how-can-i-create-an-executable-jar-with-dependencies-using-maven)
を参考にして pom.xml を書き換えて `mvn` を実行しました。

	$ svn diff pom.xmlIndex: pom.xml
	===================================================================
	--- pom.xml     (revision 1221696)
	+++ pom.xml     (working copy)
	@@ -128,6 +128,14 @@
	 
	   <build>
	     <plugins>
	+      <plugin>
	+        <artifactId>maven-assembly-plugin</artifactId>
	+        <configuration>
	+          <descriptorRefs>
	+                <descriptorRef>jar-with-dependencies</descriptorRef>
	+          </descriptorRefs>
	+        </configuration>
	+      </plugin>
	       <plugin>     
	         <artifactId>maven-surefire-plugin</artifactId>
	         <configuration>

    $ mvn package assembly:single

`target/commons-javaflow-1.0-SNAPSHOT-jar-with-dependencies.jar` が生成されました。


## JavaFlow を使う2つの方法
JavaFlow を使って continuation を実行するには bytecode を enhance する必要があります。これは推測ですが、Call stack を保存・復元する必要があり、Java に用意されている言語機能ではそれが実現不能だからではないでしょうか。

JavaFlow のドキュメントによると、2つの方法で bytecode を enhance できるようです。

* [JavaFlow の ant task](http://commons.apache.org/sandbox/javaflow/antTask.html) を使ってコンパイル時に enhance する
* `org.apache.commons.javaflow.ContinuationClassLoader` を使って class を load する。

Play! では後者に近い方法を利用しています。
[`play.classloading.enhancers.ContinuationEnhancer`](https://github.com/playframework/play/blob/master/framework/src/play/classloading/enhancers/ContinuationEnhancer.java) が JavaFlow  の `ContinuationClassLoader` と同じようなことをしています。
(Play! には JavaFlow 及び依存ライブラリの .jar が含まれているのですが、ant task も ContinuationClassLoader も何故か .jar 中に存在しなかったため、ソースからコンパイルしたのでした。)

今回は ant task を使ってみようと思います。

## Sample continuation
ここから [JavaFlow の tutorial](http://commons.apache.org/sandbox/javaflow/tutorial.html) 相当のコードを動かしてみます。
compile できるようになるまで案外苦労しました。

`build.xml` はこんな感じ。

    <?xml version="1.0" encoding="UTF-8"?>
    <project name="JavaFlowTest" default="run">
    
      <!-- javaflow の jar file の位置に応じて変更してください -->
      <property name="javaflow-jar" value="lib/commons-javaflow-1.0-SNAPSHOT-jar-with-dependencies.jar" />
    
      <taskdef name="javaflow"
        classname="org.apache.commons.javaflow.ant.AntRewriteTask">
        <classpath>
          <path location="${javaflow-jar}" />
        </classpath>
      </taskdef>
    
      <target name="compile" depends="clean">
        <!--
        複数回 javaflow task で bytecode 変換しようとするとエラーになるようなので
        depends="clean" しておく。
        -->
        <mkdir dir="build/classes"/>
        <javac srcdir="src" destdir="build/classes" classpath="${javaflow-jar}"
          includeantruntime="false" />
        <javaflow srcdir="build/classes" destdir="build/classes">
          <include name="cont/**/*.class" />
        </javaflow>
      </target>
    
      <target name="run" depends="compile">
        <java fork="true" classname="Main">
          <classpath>
            <path location="${javaflow-jar}" />
            <path location="build/classes" />
          </classpath>
        </java>
      </target>
    
      <target name="clean">
        <delete dir="build" />
      </target>
    
    </project>


[JavaFlow のドキュメント](http://commons.apache.org/sandbox/javaflow/antTask.html)
には `<javaflow />` task の attribute は srcdir および dstdir と書いてあるが、そのまま実行するとエラーとなった。dstdir は destdir が正しいようです。後ほどバグレポートしておこう。

`src/cont/MyRunnable.java` は 0 から 9 までを印字します。ただし1回ループを回るごとに `Continuation.suspend()` します。

    package cont;
    import org.apache.commons.javaflow.Continuation;
    
    public class MyRunnable implements Runnable {
      public void run() {
        System.out.println("started!");
        for( int i=0; i<10; i++ )
          echo(i);
      }
      private void echo(int x) {
        System.out.println(x);
        Continuation.suspend();
      }
    }

`src/Main.java` は `cont.MyRunnable` を `Continuation` として実行する。ただし5回実行した後の状態を取っておき、最後にもう一度実行しています。

    import org.apache.commons.javaflow.Continuation;
    import cont.MyRunnable;
    
    public class Main {
      public static void main(String[] args) {
        Continuation beginContinuation = Continuation.startSuspendedWith(new MyRunnable());
        Continuation c = beginContinuation;
        System.out.println("Loop 5 times");
        for (int i = 0; i < 5; i++) {
          c = Continuation.continueWith(c);
        }
        Continuation fifthContinuation = c;
        System.out.println("Run the rest");
        while (c != null) {
          c = Continuation.continueWith(c);
        }
        System.out.println("Run from fifthContinuation again!");
        c = fifthContinuation;
        while (c != null) {
          c = Continuation.continueWith(c);
        }
      }
    }

実行結果はこうなりました。

    $ ant
    …省略…
    run: 
         [java] Loop 5 times
         [java] started!
         [java] 0
         [java] 1
         [java] 2
         [java] 3
         [java] 4
         [java] Run the rest
         [java] 5
         [java] 6
         [java] 7
         [java] 8
         [java] 9
         [java] Run from fifthContinuation again!
         [java] 5
         [java] 6
         [java] 7
         [java] 8
         [java] 9
    
    BUILD SUCCESSFUL
    Total time: 2 seconds

5回回した時点の Continuation オブジェクトをとっておいて後から好きなときに実行出来ることがわかります。

Play! では `await()` 実行時に `Continuation.suspend()` を呼び出しています。
Continuation object を得てから Job などの完了後に再開しているのでしょう。

## java.lang.Error: Internal error が出るんですが…

`await()` は code coverage module の [cobertura](http://www.playframework.org/modules/cobertura) と一緒に使っちゃダメです。
両者共に bytecode を変更するのですが、秘孔を突くと起動時に妙な例外と共に落ちます([レポート済み](https://play.lighthouseapp.com/projects/57987/tickets/1189-continuationenhancer-causes-javalangerror-internal-error-with-cobertura))。v1.3 が修正 milestone とされていますがまだバグは健在のようです。

他の bytecode 変換モジュールを使ってエラーが起きた場合にも、`ContinuationEnhancer` の存在を頭の隅で覚えておくと良いかもしれません。

## 明日は
[@i2key](https://twitter.com/#!/i2key) さんです。お楽しみに！
