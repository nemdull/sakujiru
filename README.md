# Sakujiru

作字（自作文字・作品）を投稿・閲覧できる Rails 7 アプリです。ユーザー登録、作品投稿（画像アップロード）、一覧・詳細表示、いいね、プロフィール表示、スワイプ型の閲覧ページを備えています。UI は Tailwind CSS + daisyUI で構築しています。

## 技術スタック

- 言語・FW: Ruby 3.1.1, Rails 7.0.2.2
- Web サーバ: Puma
- DB: PostgreSQL
- 認証: Devise（カスタム RegistrationsController でパスワードなし更新）
- 画像アップロード: CarrierWave + MiniMagick（ローカルファイル保存）
- ページネーション: Kaminari
- フロントエンド: Importmap + Stimulus, Tailwind CSS（tailwindcss-rails）, daisyUI, Font Awesome
- 開発オーケストレーション: Foreman（Procfile.dev, `bin/dev`）

## 主な機能

- ユーザー登録・ログイン（Devise）
- マイページ表示、プロフィール画像アップロード（CarrierWave）
- 作品投稿（タイトル・テキスト・画像）、複数画像（`Arts`）のネスト属性対応
- 作品一覧（最新順、Kaminari でページネーション）、詳細表示、削除（投稿者のみ）
- いいね（`Like`）モデルと作成・削除アクション
- スワイプページ（自分以外の投稿をカード表示）
- カテゴリ表示（`Category`）

## 設計・実装の工夫

- 認証: Devise を使用し、`RegistrationsController#update_resource` をオーバーライドしてプロフィール更新時の現在パスワード入力を不要化
- 画像処理: CarrierWave + MiniMagick を利用し、中サイズサムネイル（1080x1080）を作成
- パフォーマンス: 一覧は `Post.includes(:arts, :user)` で N+1 を抑制
- UI: Tailwind CSS + daisyUI によるコンポーネント指向のデザイン。テーマは `data-theme="aqua"`
- 開発体験: `Procfile.dev` により Web サーバと Tailwind の watch を Foreman で並行起動

## セットアップ & 動作確認

前提: macOS + Homebrew（他環境でも Ruby 3.1.1 と PostgreSQL を用意すれば動作）

1) Ruby 3.1.1 の用意（rbenv 推奨）

```bash
brew install rbenv ruby-build
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc && exec zsh  # bash は適宜 - bash に
rbenv install 3.1.1
rbenv local 3.1.1  # プロジェクト直下
ruby -v            #=> 3.1.1
```

2) 依存関係のインストール

```bash
gem install bundler -v 2.3.7
bundle config set --local path 'vendor/bundle'
bundle install
```

3) データベースの起動・準備

```bash
# PostgreSQL を起動（例）
brew services start postgresql          # 環境により postgresql@14 など

# DB 作成・マイグレーション
bin/rails db:prepare

# ダミーデータ（任意）
bin/rails db:seed
```

4) アプリの起動

```bash
# 推奨（Foreman で Web + CSS watch）
bin/dev

# もしくは個別に
bin/rails s -p 3000            # http://localhost:3000
bin/rails tailwindcss:watch    # 別ターミナルで CSS を監視
```

補足:

- `config/database.yml` は OS ユーザー接続を前提とした設定です。必要に応じて `username`/`password`/`host` を設定してください。
- Tailwind プラグイン `@tailwindcss/forms`/`typography`/`aspect-ratio` は `config/tailwind.config.js` で require 済みです。未インストールの場合は npm/yarn で追加してください。

```bash
npm i -D @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio
```

## ディレクトリ構成（抜粋）

- `app/models`: `User`, `Post`, `Art`, `Like`, `Category`
- `app/controllers`: `PostsController`, `UsersController`, `LikesController`, `RegistrationsController`
- `app/views/posts`: `index`, `new`, `show`, `swipe`
- `app/uploaders`: `ImageUploader`, `ProfilePhotoUploader`
- `app/javascript`: Importmap + Stimulus 構成（`controllers/*`）
- `config/routes.rb`: 認証と `posts`/`arts`、`swipe`、`root` の定義
- `Procfile.dev`: Web サーバと Tailwind 監視

## 改善ポイント / TODO（リポジトリから抽出）

テスト
- ほぼ未整備（`test/channels/...` のみ）。モデル・コントローラ・システムテストを追加

設計・ドメイン
- `Post` の関連が `has_many :category` になっており整合しない（`belongs_to :category` が正）。`posts.category_id` に外部キー制約も未設定
- `Like` のルーティング定義が不足（`resources :likes` または `resources :posts do; resource :like; end` を追加）
- `Post` のバリデーション（`art_name`/画像必須など）を強化

フロントエンド
- Tailwind プラグイン `@tailwindcss/*` が `package.json` に未記載。導入または `config/tailwind.config.js` をプラグインなし構成へ整理
- `app/javascript/application.js` に CommonJS の `require("src/profile_photo_upload")` が残存。Importmap 環境に合わせて ES Modules の `import` に移行
- `profile_photo_upload.js` は jQuery（`$`）前提だが jQuery を導入していない。バニラ JS へ置換または jQuery の追加が必要

エラーハンドリング・UX
- `LikesController` の保存/削除成功・失敗ハンドリング、CSRF/turbo 連携の見直し
- フラッシュメッセージの体系化（I18n 化、種類の統一）

ドキュメント / DevEx
- README の Docker 手順と CI 設定が未整備。Docker Compose（Web/DB/CSS）と GitHub Actions（lint/test）を追加
- 環境変数の一覧（例: 本番用ストレージやメール設定）を `ENV` サンプルとともに追記

CI/CD
- GitHub Actions なし。Ruby/Node の Lint/テスト/セキュリティチェック（bundler-audit, brakeman）を導入

セキュリティ
- 認可（権限）ルールが最小限。Pundit/CanCanCan などで粒度の細かいアクセス制御を導入検討
- 画像アップロードのサイズ上限・MIME 検証、DoS 回避のための rate limit など

## ライセンス

本リポジトリのライセンスが未定義の場合は、適切な OSS ライセンスの明記を検討してください。

---

不明点やセットアップで詰まった場合は Issues へどうぞ。改善 PR も歓迎です！
