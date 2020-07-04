[English README](README.md)

# Rclex
ElixirによるROS 2クライアントライブラリです．
ROS 2共通階層であるRCL（ROS Client Library）APIをElixirコードから呼び出すことで基本的なROS 2の振る舞いをさせています．
またノード間の出版購読通信およびそれに付随するコールバック関数をプロセスモデルの一つであるタスクに実行させることで軽量にしています．
これにより，メモリへの負荷を抑えつつ，また耐障害性を高めてノードを大量に生成，通信させることが可能になっています．

# ROS 2とは

ROS（Robot Operating System）というロボット開発支援フレームワークの次世代版です．
ROS，ROS 2ともに，機能単位をノードと表現し，ノードを複数組み合わせて所望のさまざまなロボットアプリケーションが作成できます．
またノード間通信には出版購読通信が主に用いられ，パブリッシャとサブスクライバがトピックという名前でデータを識別してやりとりしています．

ROSからの大きな違いとして，通信にDDS（Data Distribution Service）プロトコルが採用されたこと，そしてライブラリが階層構造に分けられ，様々な言語でROS 2クライアントライブラリを開発できるようになったことです．これにより，Elixirでもロボットアプリケーションを開発できるようになりました．

詳しくはROS 2の[公式ドキュメント](https://index.ros.org/doc/ros2/)を参照ください．


# 使い道
現時点では以下のことができるよう，Rclex APIを提供しています．
1. 同一トピックに対して，複数のパブリッシャおよびサブスクライバを大量に作成できる．
2. パブリッシャ，トピック，サブスクライバが1つずつのペアを大量に作成できる．

# 動かし方
[こちら](https://github.com/tlk-emb/rclex_samples)を参照してください．サンプルコードとともに使い方を記しています．

## 動作環境

下記の環境で動作を確認しています

- Ubuntu 18.04.4 LTS
- ROS 2 [Dashing Diademata](https://index.ros.org/doc/ros2/Releases/Release-Dashing-Diademata/)
- Elixir 1.9.1-otp-22
- Erlang 22.0.7

他の環境でも動作が確認できたら，ぜひお知らせいただけますと幸いです．

## インストール方法

`rclex`は[Hexパッケージとして公開](https://hex.pm/docs/publish)しています．

`mix.exs`の依存関係に`rclex`を追加することで，ご自身のプロジェクトにて使用することができます．

```elixir
def deps do
  [
    {:rclex, "~> 0.3.1"}
  ]
end
```

ドキュメントは[ExDoc](https://github.com/elixir-lang/ex_doc)で生成されて[HexDocs](https://hexdocs.pm)に公開されています．  
[https://hexdocs.pm/rclex](https://hexdocs.pm/rclex)をご参照ください．

