[![Hex version](https://img.shields.io/hexpm/v/rclex.svg "Hex version")](https://hex.pm/packages/rclex)
[![API docs](https://img.shields.io/hexpm/v/rclex.svg?label=hexdocs "API docs")](https://hexdocs.pm/rclex/readme.html)
[![License](https://img.shields.io/hexpm/l/rclex.svg)](https://github.com/rclex/rclex/blob/main/LICENSE)
[![ci-all_version](https://github.com/rclex/rclex/actions/workflows/ci.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci.yml)

注：READMEは[英語版](README.md)が常に最新かつ確実です．

# Rclex [Ja]
ElixirによるROS 2クライアントライブラリです．
ROS 2共通階層であるRCL（ROS Client Library）APIをElixirコードから呼び出すことで基本的なROS 2の振る舞いをさせています．
またノード間の出版購読通信およびそれに付随するコールバック関数をプロセスモデルの一つであるタスクに実行させることで軽量にしています．
これにより，メモリへの負荷を抑えつつ，また耐障害性を高めてノードを大量に生成，通信させることが可能になっています．

## ROS 2とは

ROS（Robot Operating System）というロボット開発を支援するプラットフォームの次世代版です．
ROS，ROS 2ともに，機能単位をノードと表現し，ノードを複数組み合わせて所望のさまざまなロボットアプリケーションが作成できます．
またノード間通信には出版購読通信が主に用いられ，パブリッシャとサブスクライバがトピックという名前でデータを識別してやりとりしています．

ROSからの大きな違いとして，通信にDDS（Data Distribution Service）プロトコルが採用されたこと，そしてライブラリが階層構造に分けられ，様々な言語でROS 2クライアントライブラリを開発できるようになったことです．これにより，Elixirでもロボットアプリケーションを開発できるようになりました．

詳しくはROS 2の[公式ドキュメント](https://index.ros.org/doc/ros2/)を参照ください．

## 対象とする環境

### ホスト（開発環境）とターゲット（実行環境）が同一の場合

現在，下記の環境を主な対象として開発を進めています．

- Ubuntu 22.04.3 LTS (Jammy Jellyfish)
- ROS 2 [Humble Hawksbill](https://docs.ros.org/en/humble/Releases/Release-Humble-Hawksbill.html)
- Elixir 1.15.5-otp-26
- Erlang/OTP 26.0.2

ROS 2にはHumbleの利用を強く推奨します．
FoxyとGalacticもCI対象としていますが，これらはすでにEOLとなっています．

動作検証の対象としている環境は[こちら](https://github.com/rclex/rclex_docker#available-versions-docker-tags)を参照してください．

### Docker環境

[Docker Hub](https://hub.docker.com/r/rclex/rclex_docker)にてビルド済みのDockerイメージを公開しており，これを用いてRclexを簡単に試行することもできます．
詳細は[「Docker環境の利用」](#Docker環境の利用)のセクションを参照してください．

### Nervesデバイス（ターゲット）

`rclex` はNerves上での実行も可能です．この場合，ホスト環境にはROS 2環境を導入する必要はありません．

詳細は[Use on Nerves](USE_ON_NERVES.md)の章および[b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves)のリポジトリによる例を参照してください．

## 機能

現時点では以下のことができるようにRclex APIを提供しています．
1. 同一トピックに対して，複数のパブリッシャおよびサブスクライバを大量に作成できる．
2. パブリッシャ，トピック，サブスクライバが1つずつのペアを大量に作成できる．

ドキュメントは[ExDoc](https://github.com/elixir-lang/ex_doc)で生成されて[HexDocs](https://hexdocs.pm)に公開されています．  
[https://hexdocs.pm/rclex](https://hexdocs.pm/rclex)をご参照ください．

使用例は[rclex/rclex_examples](https://github.com/rclex/rclex_examples)を参照してください．サンプルコードとともに使い方を記しています．

## 使用方法

ここでは，ROS 2およびElixirの動作環境がインストール済みである計算機での`rclex`の使用方法を示します．

### プロジェクトの作成

通常のElixirプロジェクトと同様に作成します．

```
mix new rclex_usage
cd rclex_usage
```

### rclexのインストール

`rclex` は[Hexパッケージとして公開](https://hex.pm/docs/publish)しています．

`mix.exs` の依存関係に `rclex` を追加することで，ご自身のプロジェクトにて使用することができます．

```elixir
  defp deps do
    [
      ...
      {:rclex, "~> 0.9.3"},
      ...
    ]
  end
```

上記を追加後，プロジェクトのディレクトリ内で `mix deps.get` を実行してください．

```
mix deps.get
```

### ROS 2の環境設定

```
source /opt/ros/humble/setup.bash
```

### メッセージの型の設定

Rclexでは，ROS 2において定義されるメッセージの型を利用して出版購読型のトピック通信を行うことができます．ROS 2におけるメッセージの型については[こちら](https://docs.ros.org/en/humble/Concepts/About-ROS-Interfaces.html)を参照してください．

プロジェクトで使用したいメッセージの型は，`config/config.exs` における `ros2_message_types` で指定します．コンマ区切り `,` で複数の型を指定することもできます．

ここでは `String` 型を使用したい `config/config.exs` の例を示します．

```elixir
import Config

config :rclex, ros2_message_types: ["std_msgs/msg/String"]
```

その後，次のMixタスクを実行し，メッセージの型を使用するために必要な定義とファイル群を自動生成します．

```
mix rclex.gen.msgs
```

### コードの実装

これで Rclex を使用する準備が整いました！  
もちろんIEx上で[RclexのAPI](https://hexdocs.pm/rclex/api-reference.html)を直接実行することもできます．

ここでは，最も単純なコードを対象として，プロジェクトの実装例を示します．
次のコード `lib/rclex_usage.ex` は，`String`型のトピック `/chatter` に対して文字列を出版する処理を示しています．

```elixir
defmodule RclexUsage do
  def publish_message do
    context = Rclex.rclexinit()
    {:ok, node} = Rclex.ResourceServer.create_node(context, 'talker')
    {:ok, publisher} = Rclex.Node.create_publisher(node, 'StdMsgs.Msg.String', 'chatter')

    msg = Rclex.Msg.initialize('StdMsgs.Msg.String')
    data = "Hello World from Rclex!"
    msg_struct = %Rclex.StdMsgs.Msg.String{data: String.to_charlist(data)}
    Rclex.Msg.set(msg, msg_struct, 'StdMsgs.Msg.String')

    # This sleep is essential for now, see Issue #212
    Process.sleep(100)

    IO.puts("Rclex: Publishing: #{data}")
    Rclex.Publisher.publish([publisher], [msg])

    Rclex.Node.finish_job(publisher)
    Rclex.ResourceServer.finish_node(node)
    Rclex.shutdown(context)
  end
end
```

この他の実装例は，下記も参照してください．
- [rclex/rclex_examples](https://github.com/rclex/rclex_examples)

### ビルドと実行

```
mix compile
iex -S mix
```

IEx上で次のように実行してください．

```
iex()> RclexUsage.publish_message

00:04:40.701 [debug] JobExecutor start
 
00:04:40.705 [debug] talker0/chatter/pub
Rclex: Publishing: Hello World from Rclex!

00:04:40.706 [debug] publish ok
 
00:04:40.706 [debug] publisher finished: talker0/chatter/pub
 
00:04:40.710 [debug] finish node: talker0
{:ok, #Reference<0.2970499651.1284374532.3555>}
```

このメッセージの出版結果は，ROS 2コマンド`ros2 topic echo`によって購読して確認できます．

```
$ source /opt/ros/humble/setup.bash
$ ros2 topic echo /chatter std_msgs/msg/String
data: Hello World from Rclex!
---
```

## 開発の円滑化

本セクションでは主に開発者向けの情報を示します．

### Docker環境の利用

本リポジトリでは，Dockerでライブラリ開発を進めるための`docker compose`による環境を提供しています．

前述の通り[Docker Hub](https://hub.docker.com/r/rclex/rclex_docker)にてビルド済みのDockerイメージを公開しており，これを用いることでRclexを簡単に試行できます．
環境変数 `$RCLEX_DOCKER_TAG` にて対象とする実行環境のバージョンを設定できます．設定可能な実行環境は[こちら](https://github.com/rclex/rclex_docker#available-versions-docker-tags)を参照してください．

```
# optional: 実行環境の設定（デフォルトは`latest`）
export RCLEX_DOCKER_TAG=latest
# コンテナを作成して起動
docker compose up -d
# コンテナの実行（本リポジトリのマウントポイントを作業ディレクトリに）
docker compose exec -w /root/rclex rclex_docker /bin/bash
# コンテナの終了
docker compose down
```

### mix test等の自動実行

`mix test.watch` を導入しており，ソースコードの編集時毎に，単体テスト `mix test` やコード整形 `mix format` を自動実行できます．

```
$ mix test.watch
# または docker で動作させるには
$ docker compose run --rm -w /root/rclex rclex_docker mix test.watch
```

### 動作確認

動作確認として，[rclex/rclex_connection_tests](https://github.com/rclex/rclex_connection_tests)を用いてRclcppで実装されたノードとの通信に関するテストを実施しています．

```
cd /path/to/yours
git clone https://github.com/rclex/rclex
git clone https://github.com/rclex/rclex_connection_tests
cd /path/to/yours/rclex_connection_tests
./run-all.sh
```

[GitHub Actions](https://github.com/rclex/rclex/actions)では，複数の環境でのCIを実行しています．ただし，これら全ての環境での動作保証には対応できません．

## 主な管理者と開発者（過去分も含む）

- [@takasehideki](https://github.com/takasehideki)
- [@HiroiImanishi](https://github.com/HiroiImanishi)
- [@kebus426](https://github.com/kebus426)
- [@shiroro466](https://github.com/shiroro466)
- [@s-hosoai](https://github.com/s-hosoai)
