# Docker+Rails 環境構築メモ

参考

https://zenn.dev/kei1232/articles/0fac51829570c1

## 今回のゴール

Docker + Rails の開発環境構築を学ぶ

## バージョン

- macOS 14.6.1
- Docker version 27.2.0, build 3ab4256
- Ruby 3.3.5
- Rails 7.2.1.2

## 作業の流れ

1. Dockerfile 等を作成
2. 仮でコンテナを作成＆起動し、コンテナ上で rails new
3. コンテナを作り直し
4. rails g scaffold

## やったことメモ

### 1. 初期ファイル作成

#### Dockerfile.dev

```
FROM ruby:3.3

WORKDIR /app

COPY Gemfile Gemfile.lock .

RUN bundle install

COPY entrypoint.sh /
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3000
# CMD ["rails", "server", "-b", "0.0.0.0"]
```

#### Gemfile

```
source 'https://rubygems.org'
gem 'rails'
```

#### Gemfile.lock

空ファイルを作成

#### compose.yaml

```
services:
  web:
    container_name: d1r2
    build:
      context: .
      dockerfile: Dockerfile.dev
    # command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
    volumes:
      - .:/app
    env_file:
      - .env
    ports:
      - ${RAILS_PORT}:3000
    tty: true
    stdin_open: true
```

#### entrypoint.sh

```
#!/bin/bash
set -e

rm -f tmp/pids/server.pid
exec "$@"
```

#### .env

```
RAILS_PORT=3000
```

### 2. 仮ビルド

```
> docker compose build
```

### 3. コンテナ起動

```
> docker compose up -d
```

### 4. Rails new

```
> docker-compose exec web rails new . -f -T
```

### 5. DB 作成

```
> docker-compose exec web rails db:create
```

### 6. Dockerfile.dev と compose.yaml のコメントアウトを外す

#### Dockerfile.dev

```
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["rails", "server", "-b", "0.0.0.0"]
```

#### compose.yaml

```
    command: bash -c "rm -f tmp/pids/server.pid && bundle exec rails s -p 3000 -b '0.0.0.0'"
```

### 7. 再ビルド

```
> docker compose build
```

### 8. コンテナ起動

```
> docker compose up -d
```

### 9. サーバ起動確認

http://localhost:3000/

### 10. アプリ作成を始める

```
> docker-compose exec web rails g scaffold example title:string content:text
> docker-compose exec web rails db:migrate
```

### 11. 完了！

http://localhost:3000/examples
