---
layout: post
title: "Open sources used by spotify"
date: 2012-06-25 00:49
comments: true
categories: 
---

US などの iTunes store からダウンロードできる [Spotify](http://www.spotify.com/) の iOS アプリの出来がとても良い。
アプリ内に用意されている Lisence のページを見ていたら、利用している open source ソフトウェアの一覧が並んでいたので、ちゃんと出来てるアプリに使われているものはきっとちゃんとしているだろうということでメモしておく。

* [Boost](http://www.boost.org/)
* [Expat](http://expat.sourceforge.net/)
* [FastDelegate](http://www.codeproject.com/Articles/7150/Member-Function-Pointers-and-the-Fastest-Possible) C++ の member function pointer に代わる何か？
* [giflib](http://sourceforge.net/projects/giflib/) GIF
* [libjpeg](http://libjpeg.sourceforge.net/) JPEG
* [libpng](http://www.libpng.org/pub/png/libpng.html) PNG
* [libogg](http://xiph.org/ogg/) Ogg
* [libvorbis](http://xiph.org/vorbis/) Vorbis
* [Tremolo](http://wss.co.uk/pinknoise/tremolo/) Tremolo is an ARM optimised version of the Tremor lib from xiph.org. For those that don't know, the Tremor lib is an integer only library for doing Ogg Vorbis decompression.
* [Mersenne Twister](http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/mt.html) Mersenne Twister(以下MT)は、松本眞 ・西村拓士（アルファベット順）により1996年から1997年に渡って 開発された疑似乱数生成アルゴリズムです。
* [Snd](https://ccrma.stanford.edu/software/snd/) Snd is a sound editor. Spotify では resampling にコードを流量。
* [zlib](http://zlib.net/)
* [NSIS](http://nsis.sourceforge.net/Main_Page) Windows のインストーラ作成システム。
* [Windows Template Library](http://sourceforge.net/projects/wtl/) Windows Template Library (WTL) is a C++ library for developing Windows applications and UI components. It extends ATL (Active Template Library) and provides a set of classes for controls, dialogs, frame windows, GDI objects, and more.
* [Growl](http://growl.info/)
* [Lua](http://www.lua.org/)
* [Nu](http://programming.nu/index) Nu is an interpreted object-oriented language. Its syntax comes from Lisp, but Nu is semantically closer to Ruby than Lisp. Nu is implemented in Objective-C and is designed to take full advantange of the Objective-C runtime and the many mature class libraries written in Objective-C.
* [SBJSON](http://stig.github.com/json-framework/)
* [ASIHTTPRequest](http://allseeing-i.com/ASIHTTPRequest/)
* [MAObjCRuntime](https://github.com/mikeash/MAObjCRuntime) MAObjCRuntime is an ObjC wrapper around the Objective-C runtime APIs. If that's confusing, it provides a nice object-oriented interface around (some of) the C functions in /usr/include/objc.
* [Google Breakpad](http://code.google.com/p/google-breakpad/) An open-source multi-platform crash reporting system
* [iCarousel](http://zendold.lojcomm.com.br/icarousel/) iCarousel is an open source (free) javascript tool for creating carousel like widgets.
* [MBProgressHUD](https://github.com/jdg/MBProgressHUD) MBProgressHUD is an iOS drop-in class that displays a translucent HUD with an indicator and/or labels while work is being done in a background thread
* [KKGridView](https://github.com/kolinkrewinkel/KKGridView) High-performance iOS grid view (MIT license). iOS6 では iOS SDK に類似の view controller を入れたので不要に。
* [KissXML](https://github.com/robbiehanson/KissXML) KissXML provides a drop-in replacement for Apple's NSXML class culster in environments without NSXML (e.g. iOS).
* [ProtobufObjc](https://github.com/booyah/protobuf-objc)
* [Facebook](https://github.com/facebook/facebook-ios-sdk)
* [Chronium](http://www.chromium.org/)
* [CEF](http://code.google.com/p/chromiumembedded/) The Chromium Embedded Framework (CEF) is an open source project founded by Marshall Greenblatt in 2008 to develop a Web browser control based on the Google Chromium project. CEF currently supports a range of programming languages and operating systems and can be easily integrated into both new and existing applications.

Mac 版 Spotify のブラウザっぽいものは CEF なのかな。

Google Breakpad, Nu, MAObjCRuntime, KKGridView あたりはすぐ使うかも。用調査。
