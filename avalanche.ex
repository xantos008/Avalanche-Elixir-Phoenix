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
    field :token_live, :utc_datetime
  end

  @doc false
  def changeset(avalanche, attrs) do
    avalanche
    |> cast(attrs, [:site_base_url, :site_redirect, :site_premium_url, :token, :token_live])
    |> validate_required([:site_base_url, :site_redirect, :site_premium_url, :token, :token_live])
  end
  
  
end
