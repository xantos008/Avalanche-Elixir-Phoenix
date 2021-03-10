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
