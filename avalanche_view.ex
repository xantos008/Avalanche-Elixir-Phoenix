defmodule LedgerWeb.AvalancheView do
  use LedgerWeb, :view
  alias Ledger.AvalancheModule

  def referapp_url do
	AvalancheModule.getReferAppUrl
  end
  
  def email(conn) do
	AvalancheModule.getEmail(conn)
  end
  
  def name(conn) do
	AvalancheModule.getName(conn)
  end
  
  def base_url do
	AvalancheModule.getBaseUrl
  end
  
  def redirect_uri do
	AvalancheModule.getRedirectUri
  end
  
  def token do
	AvalancheModule.getToken
  end
  
end
