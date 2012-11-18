---
layout: post
title: "IAMユーザのS3アクセスをフォルダレベルで制限する"
date: 2012-11-18 19:29
comments: true
categories: AWS IAM S3
---

AWS の IAM でユーザを作り、S3 bucket の特定の path 以下にのみアクセスを与えるということを設定したかったのですが、情報を見つけられず時間をつかってしまったので共有しておきます。
(参考: [Giving a user permission to acceess just a folder within a bucket](https://forums.aws.amazon.com/message.jspa?messageID=245525))

現状 AWS では bucket 数上限が 100, IAM ユーザ数制限が 5000 になっています。
利用者1人に 1 IAM ユーザを発行すると 5000 人で使えるわけですが、
bucket 毎に共有設定を行った場合は 100 共有までです。
同一 bucket 内で path を切り替えて共有した場合は bucket 数上限は関係なくなるので嬉しい、というわけです。

まず最初に S3 の IAM policy に関するAWS の公式ドキュメントは
[Using IAM Policies](http://docs.amazonwebservices.com/AmazonS3/latest/dev/UsingIAMPolicies.html)
です。
Bucket レベルの指定は arn:aws:s3:::bucket_name に対して行い、 object レベルの指定は arn:aws:s3:::bucket_name/key_name に対して行います。

同ページ内の Example 5: Allow a partner to drop files into a specific portion of the corporate bucket がやりたいこととほぼ同じ設定になります。

Object レベルの指定で path 以下にアクセスを制限したいときは * が使えます。
my_bucket bucket の shared/ 以下に s3:PutObject を許可するには、以下のような statement を追加します。

```
{
  "Effect":"Allow",
  "Action":"s3:PutObject",
  "Resource":"arn:aws:s3:::my_bucket/shared/*"
}
```

上記は object レベルでの指定になります。
S3を利用するアプリケーションによっては object レベルの API だけではなく bucket レベルでの API も使うものがあります。

Bucket レベルの指定で path 以下にアクセスを制限したいときは Condition, StringLike を使います。
s3:ListBucket, s3:GetBucketLocation を許可するには、以下の様な statement を追加します。

```
{
  "Effect": "Allow",
  "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
  "Resource": "arn:aws:s3:::my_bucket",
  "Condition": {
    "StringLike": {
    "s3:prefix": "shared/*"
  }
}
```

上記の方法でアプリケーションが利用する API に応じて object レベル, bucket レベルの action を許可すれば、今回の目的が達成できます。

なお、S3 すべての action についてこれらの指定で動作することを検証したわけではないので、必要に応じてみなさまご確認ください。
