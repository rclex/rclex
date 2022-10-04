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

## 動作環境（開発環境）

現在，下記の環境を主な対象として開発を進めています．

- Ubuntu 20.04.2 LTS (Focal Fossa)
- ROS 2 [Foxy Fitzroy](https://docs.ros.org/en/foxy/Releases/Release-Foxy-Fitzroy.html)
- Elixir 1.12.3-otp-24
- Erlang/OTP 24.1.5

動作検証の対象としている環境は[こちら](https://github.com/rclex/rclex_docker#available-versions-docker-tags)を参照してください．

[Docker Hub](https://hub.docker.com/r/rclex/rclex_docker)にてビルド済みのDockerイメージを公開しており，これを用いてRclexを簡単に試行することもできます．
詳細は[「Docker環境の利用」](#Docker環境の利用)のセクションを参照してください．

## インストール方法

`rclex` は[Hexパッケージとして公開](https://hex.pm/docs/publish)しています．

`mix.exs` の依存関係に `rclex` を追加することで，ご自身のプロジェクトにて使用することができます．

```elixir
def deps do
  [
    {:rclex, "~> 0.7.2"}
  ]
end
```

ドキュメントは[ExDoc](https://github.com/elixir-lang/ex_doc)で生成されて[HexDocs](https://hexdocs.pm)に公開されています．  
[https://hexdocs.pm/rclex](https://hexdocs.pm/rclex)をご参照ください．

## 使い方

現時点では以下のことができるよう，Rclex APIを提供しています．
1. 同一トピックに対して，複数のパブリッシャおよびサブスクライバを大量に作成できる．
2. パブリッシャ，トピック，サブスクライバが1つずつのペアを大量に作成できる．

[こちら](https://github.com/rclex/rclex_examples)を参照してください．サンプルコードとともに使い方を記しています．

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
# docker で動作させるには
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
