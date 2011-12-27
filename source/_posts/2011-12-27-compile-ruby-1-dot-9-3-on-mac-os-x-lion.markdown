---
layout: post
title: "Compile ruby 1.9.3 on Mac OS X Lion using RVM"
date: 2011-12-27 23:52
comments: true
categories: [Ruby, Lion]
---
仕事で Ruby を使うことになったので、家の Lion ちゃんにも ruby インストール
しとこうと思ったらエラーになる。
rvm の version は 1.10.0。

```
$ rvm install 1.9.3
Installing Ruby from source to: /Users/kawachi/.rvm/rubies/ruby-1.9.3-p0, this may take a while depending on your cpu(s)...

ruby-1.9.3-p0 - #fetching
ruby-1.9.3-p0 - #extracted to /Users/kawachi/.rvm/src/ruby-1.9.3-p0 (already extracted)
Fetching yaml-0.1.4.tar.gz to /Users/kawachi/.rvm/archives
Extracting yaml-0.1.4.tar.gz to /Users/kawachi/.rvm/src
Configuring yaml in /Users/kawachi/.rvm/src/yaml-0.1.4.
Compiling yaml in /Users/kawachi/.rvm/src/yaml-0.1.4.
Installing yaml to /Users/kawachi/.rvm/usr
ruby-1.9.3-p0 - #configuring
ERROR: Error running ' ./configure --prefix=/Users/kawachi/.rvm/rubies/ruby-1.9.3-p0 --enable-shared --disable-install-doc --with-libyaml-dir=/Users/kawachi/.rvm/usr ', please read /Users/kawachi/.rvm/log/ruby-1.9.3-p0/configure.log
ERROR: There has been an error while running configure. Halting the installation.
```

`~/.rvm/log/ruby-1.9.3-p0/configure.log` はこんな感じ。

```
[2011-12-27 23:50:52]  ./configure --prefix=/Users/kawachi/.rvm/rubies/ruby-1.9.3-p0 --enable-shared --disable-install-doc --with-libyaml-dir=/Users/kawachi/.rvm/usr 
configure: WARNING: unrecognized options: --with-libyaml-dir
checking build system type... x86_64-apple-darwin11.2.0
checking host system type... x86_64-apple-darwin11.2.0
checking target system type... x86_64-apple-darwin11.2.0
checking whether the C compiler works... no
configure: error: in `/Users/kawachi/.rvm/src/ruby-1.9.3-p0':
configure: error: C compiler cannot create executablesSee `config.log' for more details
```

`CC=gcc` を指定すると少し変わる。
<!-- more -->

```
$ CC=gcc rvm install 1.9.3
ERROR: The provided CC(gcc) is LLVM based, it is not yet fully supported by ruby and gems, please read `rvm requirements`.
```

`rvm requirements` を読むといろいろ書いてある。


```
  Notes for Darwin ( Mac OS X )
    For Snow Leopard: Xcode Version 3.2.1 (1613) or later, such as 3.2.6 or Xcode 4.1.
    [ Please note that Xcode 3.x will *not* work on OS X Lion. The 'cross-over' is Xcode 4.1. ]

    You should download the Xcode tools from developer.apple.com, since the Snow Leopard dvd install contained bugs.
    You can find Xcode 4.1 for OS X Lion at:
    https://developer.apple.com/downloads/download.action?path=Developer_Tools/xcode_4.1_for_lion/xcode_4.1_for_lion.dmg

    ** Lion Users: Xcode Version 4.2.x for OS X Lion works only for ruby 1.9.3-p0 (or higher).
                   It currently fails to build several other rubies and gems, as well as several Homebrew and
                   Macports packages. Xcode Version 4.1 (4B110) works.
    ** NOTE: Currently, Node.js is having issues building with osx-gcc-installer. This is _not_ an RVM issue. This is
       because Node.js depends on the Carbon headers. ox-gcc-installer does not install these to the system.
       This issue only affects users using osx-gcc-installer, and not Xcode. The only fix is to install Xcode over osx-gcc-installer.

    For MacRuby: Install LLVM first.
    For JRuby:  Install the JDK. See http://developer.apple.com/java/download/  # Current Java version 1.6.0_26
    For IronRuby: Install Mono >= 2.6
		For Ruby 1.9.3: Install libksba # If using Homebrew, 'brew install libksba'
```

なんかいろいろ書いてある。
自分の環境 (Lion, Xcode 4.2.1) に関連しそうなのは、

* Lion で Xcode 4.1 だとうまくいく
* Lion の Xcode 4.2 でコンパイルできるのは ruby 1.9.3-p0 とそれ以降
* Ruby 1.9.3 をインストールする前に libksba をインストールせよ

たしかに Xcode 4.2 なので LLVM しかないけど、
ruby 1.9.3-p0 はコンパイルできるんじゃないの？
RVM で止められてる気がする。。。

`~/.rvm/scripts/functions/build` を参照すると、
`CC` 環境変数が存在するときは `--version` 付きで実行して LLVM だったら `exit 1` してる。

```
--- .rvm/scripts/functions/build.orig   2011-12-28 00:29:10.000000000 +0900
+++ .rvm/scripts/functions/build        2011-12-28 00:29:32.000000000 +0900
@@ -29,7 +29,7 @@
       else
         rvm_error "The autodetected CC(${CC:-}) is LLVM based, it is not yet fully supported by ruby and gems, please read \`rvm requirements\`, and set CC=/path/to/gcc ."
       fi
-      exit 1
+      #exit 1
     fi
 
   fi
```

とりあえず上記のとおりコメントアウトしてみたら
`$ CC=gcc rvm install 1.9.3` で compile できた。

正しいやり方でないような気はするけど、まいっか。