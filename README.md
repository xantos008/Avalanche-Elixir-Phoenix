# Avalanche-Elixir-Phoenix

This is an Avalanche Referrals SDK for Elixir + Phoenix framework

# Avalanche Phoenix|Elixir module

[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

# Installation

### Step 1 - Base installation

> We use [Node.js](https://nodejs.org/) v15.2.0

Install the [Elixir](https://elixir-lang.org/install.html) programming language
Install the Phoenix project generator and create your project

```sh
mix archive.install hex phx_new
mix phx.new demo
```

##### NOTES:

- `demo` - name of your app
- `mix phx.new demo` - if you want to use default PostgreSQL
- `mix phx.new demo --database mysql` - if you want to use MySQL

### Step 2 - Issues

There may be an issue with default package.json and node_modules being incompatible with Node v15+
Solution: Remove `/assets/package-lock.json` and `/assets/node_modules`

When change `/assets/package.json` to

```sh
{
  "repository": {},
  "description": " ",
  "license": "MIT",
  "scripts": {
    "deploy": "webpack --mode production",
    "watch": "webpack --mode development --watch"
  },
  "dependencies": {
    "@babel/core": "^7.13.8",
    "@babel/preset-env": "^7.13.9",
    "babel-loader": "^8.2.2",
    "copy-webpack-plugin": "^8.0.0",
    "css-loader": "^5.1.1",
    "css-minimizer-webpack-plugin": "^1.2.0",
    "hard-source-webpack-plugin": "^0.13.1",
    "mini-css-extract-plugin": "^1.3.9",
    "node-sass": "^5.0.0",
    "phoenix": "file:../deps/phoenix",
    "phoenix_html": "file:../deps/phoenix_html",
    "sass-loader": "^11.0.1",
    "terser-webpack-plugin": "^5.1.1",
    "webpack": "^5.24.3",
    "webpack-cli": "^4.5.0"
  }
}
```

Run

```sh
cd demo/assets
npm install
```

Change `/assets/webpack.config.js` to

```sh
const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    optimization: {
      minimizer: [
        new CssMinimizerPlugin({})
      ]
    },
    entry: {
      'app': glob.sync('./vendor/**/*.js').concat(['./js/app.js'])
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, '../priv/static/js'),
      publicPath: '/js/'
    },
    devtool: devMode ? 'eval-cheap-module-source-map' : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            'sass-loader',
          ],
        }
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: '../css/app.css' }),
      new CopyWebpackPlugin(
	    {
			patterns: [
				{ from: 'static/', to: '../' }
			]
		}
	  )
    ]
  }
};
```

Also dont forget to to edit your config `dev.exs` or what do you use
Change

```sh
      "--watch-stdin",
```

To

```sh
      "--watch",
```

Build your webpack setups

```sh
node node_modules/webpack/bin/webpack.js --mode development
```

## Setup database if you use MySQL

Go to root of your project and open file `mix.exs`

Change

```sh
{:myxql, ">= 0.0.0"},
```

To

```sh
{:myxql, ">= 0.3.3"},
```

## When run

```sh
mix deps.get
```

### Instalation on exist project (next step)

```sh
mix phx.gen.schema Avalanche avalanche cliend_id:string client_secret:string audience:string grant_type:string oauth_url:string referapp_api_url:string site_base_url:string site_redirect:string site_premium_url:string token:text token_live:utc_datetime
```

`/ledger/lib/ledger/avalanche.ex`

```sh
defmodule Ledger.Avalanche do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "avalanche" do
    field :audience, :string
    field :cliend_id, :string
    field :client_secret, :string
    field :grant_type, :string
    field :oauth_url, :string
    field :referapp_api_url, :string
    field :site_base_url, :string
    field :site_premium_url, :string
    field :site_redirect, :string
    field :token, :string
    field :token_live, :time
  end

  @doc false
  def changeset(avalanche, attrs) do
    avalanche
    |> cast(attrs, [:cliend_id, :client_secret, :audience, :grant_type, :oauth_url, :referapp_api_url, :site_base_url, :site_redirect, :site_premium_url, :token, :token_live])
    |> validate_required([:cliend_id, :client_secret, :audience, :grant_type, :oauth_url, :referapp_api_url, :site_base_url, :site_redirect, :site_premium_url, :token, :token_live])
  end
end
```

`/priv/repo/migrations/20210307204413_create_avalanche.exs` where `20210307204413` - current time, so it would be different

```sh
defmodule Ledger.Repo.Migrations.CreateAvalanche do
  use Ecto.Migration

  def change do
    create table(:avalanche, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :cliend_id, :string
      add :client_secret, :string
      add :audience, :string, default: "https://useavalanche.us.auth0.com/api/v2/", null: false
      add :grant_type, :string, default: "client_credentials", null: false
      add :oauth_url, :string, default: "https://useavalanche.us.auth0.com/oauth/token", null: false
      add :referapp_api_url, :string, default: "http://salty-reef-38656.herokuapp.com", null: false
      add :site_base_url, :string, default: "https://app.inkle.io", null: false
      add :site_redirect, :string, default: "https://app.inkle.io", null: false
      add :site_premium_url, :string, default: "https://app.inkle.io", null: false
      add :token, :text
      add :token_live, :utc_datetime, default: fragment("now()"), null: false
	end


	execute "INSERT INTO avalanche (id, cliend_id, client_secret) VALUES ('ecfbbd68-7f84-11eb-9439-0242ac130002', 'NiwToJ2Mlkn4ubzbymnC18vM08WSXyb5', '_BxwOPM0xfZ6n2OUch75BjuJ8kvvuOzSLzZtmoGp5rCVfW3neYIQkBaTnGmMLWDM')"

  end
end
```

NOTICE
`NiwToJ2Mlkn4ubzbymnC18vM08WSXyb5` - need to be changed by your own Client ID
`_BxwOPM0xfZ6n2OUch75BjuJ8kvvuOzSLzZtmoGp5rCVfW3neYIQkBaTnGmMLWDM` - need to be changed by your own Client Secret

add to `mix.exs`

```sh
{:httpoison, "~> 1.8"}
```

and run

```sh
mix deps.get
mix deps.compile
```

##### Add\edit files from this repository to folders

`avalanche.ex` - demo/lib/demo

`avalanche_module.ex` - demo/lib/demo

`iframe.html.eex` - demo/lib/demo_web/templates/avalanche (create folder `avalanche` if not exists)

`avalanche_view.ex` - demo/lib/demo_web/views

`demo` is name of your app
`demo_web` is name of your web app where `demo` is name of your app

Change file `router.ex` in path `demo/lib/demo_web/router.ex`

```sh
defmodule LedgerWeb.Router do
  use LedgerWeb, :router

  import LedgerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LedgerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
	plug Demo.AvalancheModule #This need to be added
  end

  ... your code next
```

`Demo` is the name of your app

Add `AvalancheView` to your view_helpers function in `demo/lib/demo_web.ex`, where `demo` is the name of your app

```sh

  ... your code before

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import Demo.ErrorHelpers
      import Demo.Gettext
      alias Demo.Router.Helpers, as: Routes
      alias Demo.SharedView
      alias Demo.AvalancheView #This need to be added
    end
  end

  ... your code after

```

### View

Add this to any location in view where you want to show 'invite your friends' window interface

```sh
<%= render AvalancheView, "iframe.html", referapp_url: AvalancheView.referapp_url, email: AvalancheView.email(@conn), name: AvalancheView.name(@conn), base_url: AvalancheView.base_url, redirect_uri: AvalancheView.redirect_uri, token: AvalancheView.token %>
```

### Functions for usage

`AvalancheModule.getToken` - Token generation for your app in our system. After a successful generation of a token, the function adds the token and a current time to your database.
Token's life period is 24 hours, so after it expires it would be replaced by a new one

`AvalancheModule.getRedirectUri`, `AvalancheModule.getBaseUrl` - Get needed variables's value from database

`AvalancheModule.getReferAppUrl` - Manual set site for iframe

`AvalancheModule.getName`, `AvalancheModule.getEmail` - Get `name` and `email` from conn.assigns (simething like SESSION) from object array `current_user`

NOTICE: Some names can be different from your app's names. Make sure you replace it for used names if necessary

`confirmedUserRef` - email and referral code are required - This function tells us that user confirmed invitation from his referrer. Usually called immediately after registration.

`updateReferralEmail` - email required - Call it after `confirmedUserRef` or if you have email confirmation, do `updateReferralEmail` after email was confirmed. This function will replace referral email for email in use.

`setPremiumEvent` - email required - This function tells us that user reached premium conversion goal for your project. This can be the moment when you've received payment. Another option is to handle this externally via an integration. We can provide support for that.

# Thank you!
