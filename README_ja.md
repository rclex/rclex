[![Hex version](https://img.shields.io/hexpm/v/rclex.svg "Hex version")](https://hex.pm/packages/rclex)
[![API docs](https://img.shields.io/hexpm/v/rclex.svg?label=hexdocs "API docs")](https://hexdocs.pm/rclex/readme.html)
[![License](https://img.shields.io/hexpm/l/rclex.svg)](https://github.com/rclex/rclex/blob/main/LICENSE)
[![ci-latest](https://github.com/rclex/rclex/actions/workflows/ci-latest.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci-latest.yml)
[![ci-all_version](https://github.com/rclex/rclex/actions/workflows/ci-all_version.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci-all_version.yml)

注：READMEは[英語版](README.md)が常に最新かつ確実です．

# Rclex [Ja]

関数型言語[Elixir](https://elixir-lang.org/)によるROS 2クライアントライブラリです．

ROS 2共通階層であるRCL（ROS Client Library）APIをElixirコードから呼び出すことでROS 2の基本的な振る舞いを実現しています．

また，ノード間の出版購読通信およびそれに付随するコールバック関数をErlangの軽量プロセスに実行させるようにしています．
これにより，メモリへの負荷を抑えつつ，また耐障害性を高めてノードを大量に生成，通信させることが可能になっています．

## ROS 2とは

ROS（Robot Operating System）というロボット開発を支援するプラットフォームの次世代版です．
ROS 2では，機能単位はノードとして表現され，ノードを複数組み合わせてさまざまな所望のロボットアプリケーションが作成できます．
またノード間通信には出版購読通信が主に用いられ，パブリッシャとサブスクライバがトピックという名前でデータを識別してやりとりしています．

ROS 2の主な貢献として，通信にDDS（Data Distribution Service）プロトコルが採用されたこと，そしてライブラリが階層構造に分けられたことです．
これによって，様々な言語でROS 2クライアントライブラリを開発できるようになり，もちろんElixirでもロボットアプリケーションを開発できるようになりました．

詳しくは[ROS 2の公式ドキュメント](https://docs.ros.org/en/rolling/index.html)を参照ください．

## 対象とする環境

### ネイティブ環境

基本的で推奨される環境は，ホスト（開発環境）とターゲット（実行環境）が同一のものです．

現在，下記の環境を主な対象として開発を進めています．

- Ubuntu 22.04.4 LTS (Jammy Jellyfish)
- ROS 2 [Humble Hawksbill](https://docs.ros.org/en/humble/Releases/Release-Humble-Hawksbill.html)
- Elixir 1.15.7-otp-26
- Erlang/OTP 26.2.2

ROS 2には長期サポート版（LTS）であるHumbleの利用を強く推奨します．
短期サポート版（STS）のIronは，実験的なサポートでありネイティブ環境での基本的な動作のみを確認しています．対応状況の詳細は[Issue#228](https://github.com/rclex/rclex/issues/228#issuecomment-1715293177)を確認してください．
FoxyとGalacticもCI対象としていますが，これらはすでにEOLとなっています．

動作検証の対象としている環境は[こちら](https://github.com/rclex/rclex_docker#available-versions-docker-tags)を参照してください．

### Docker環境

[Docker Hub](https://hub.docker.com/r/rclex/rclex_docker)にてビルド済みのDockerイメージを公開しており，これを用いてRclexを簡単に試行することもできます．
詳細は[「Docker環境の利用」](#Docker環境の利用)のセクションを参照してください．

### Nervesデバイス（ターゲット）

`rclex` はNerves上での実行も可能です．この場合，ホスト環境にはROS 2環境を導入する必要はありません．

詳細は[Use on Nerves](USE_ON_NERVES.md)のセクションおよび[b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves)のリポジトリによる例を参照してください．

## 機能

現時点では以下のことができるようにRclex APIを提供しています．
1. 同一トピックに対して，複数のパブリッシャおよびサブスクライバを大量に作成できる．
2. パブリッシャ，トピック，サブスクライバが1つずつのペアを大量に作成できる．

APIドキュメントは[https://hexdocs.pm/rclex](https://hexdocs.pm/rclex)をご参照ください．

使用例は[rclex/rclex_examples](https://github.com/rclex/rclex_examples)を参照してください．サンプルコードとともに使い方を記しています．

## 使用方法

ここでは，ROS 2およびElixirの動作環境がインストール済みであるネイティブ環境での`rclex`の使用方法を示します．

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
      {:rclex, "~> 0.11.2"},
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

`config/config.exs`を編集してメッセージの型を変更したときは, `mix rclex.gen.msgs`を再度実行してください．

### コードの実装

これで Rclex を使用する準備が整いました！  
もちろんIEx上で[RclexのAPI](https://hexdocs.pm/rclex/api-reference.html)を直接実行することもできます．

ここでは，最も単純なコードを対象として，プロジェクトの実装例を示します．
次のコード `lib/rclex_usage.ex` は，`String`型のトピック `/chatter` に対して文字列を出版する処理を示しています．

```elixir
defmodule RclexUsage do
  alias Rclex.Pkgs.StdMsgs

  def publish_message do
    Rclex.start_node("talker")
    Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "talker")

    data = "Hello World from Rclex!"
    msg = struct(StdMsgs.Msg.String, %{data: data})

    IO.puts("Rclex: Publishing: #{data}")
    Rclex.publish(msg, "/chatter", "talker")
  end
end
```

この他の実装例は，下記も参照してください．

- [rclex/rclex_examples](https://github.com/rclex/rclex_examples)

### ビルドと実行

次のようにアプリケーションをビルドしてください．

```
mix compile
iex -S mix
```

IEx上で次のように実行してください．

```
iex()> RclexUsage.publish_message
Rclex: Publishing: Hello World from Rclex!
:ok
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

[GitHub Actions](https://github.com/rclex/rclex/actions)では，これらのDocker環境を利用して，複数のツールバージョンでのCIを実行しています．ただし，これら全ての環境での動作保証には対応できません．

### mix test等の自動実行

`mix test.watch` を導入しており，ソースコードの編集時毎に，単体テスト `mix test` やコード整形 `mix format` を自動実行できます．

```
$ mix test.watch
# または docker で動作させるには
$ docker compose run --rm -w /root/rclex rclex_docker mix test.watch
```

### 通信に関する動作確認

特にノード間通信に関する動作確認として，[rclex/rclex_connection_tests](https://github.com/rclex/rclex_connection_tests)を用いてRclcppで実装されたノードとの通信に関するテストを実施しています．

```
cd /path/to/yours
git clone https://github.com/rclex/rclex
git clone https://github.com/rclex/rclex_connection_tests
cd /path/to/yours/rclex_connection_tests
./run-all.sh
```

## 主な管理者と開発者（過去分も含む）

- [@takasehideki](https://github.com/takasehideki)
- [@s-hosoai](https://github.com/s-hosoai)
- [@pojiro](https://github.com/pojiro)
- [@HiroiImanishi](https://github.com/HiroiImanishi)
- [@kebus426](https://github.com/kebus426)
- [@shiroro466](https://github.com/shiroro466)
