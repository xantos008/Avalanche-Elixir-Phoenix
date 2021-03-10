defmodule Ledger.AvalancheModule do
  use HTTPoison.Base
  
  import Ecto.Query, warn: false 
  import Plug.Conn 
  import Plug.Session 
  
  alias Ledger.Repo
  alias Ledger.Avalanche
  
  require Logger
  
  @expected_fields_token ~w(
    token_type access_token
  )
  
  @expected_fields_email ~w(
    email ira
  ) 
  
  def init(_params) do 
  end
  
  def call(conn, _params) do
	params = conn.query_params
	if params["refAPI_ref_code"] do
		refApi = inspect(params["refAPI_ref_code"])
		conn
			|> configure_session(renew: true)
			|> assign(:referApi, "#{refApi}")
			|> assign(:step, "entered")
			|> put_session(:referApi, "#{refApi}")
			|> put_session(:step, "entered")
	else
	conn
	end
  end
  
  def getSession(conn) do
	get_session(conn, :referApi)
  end 
  
  def setStepOfReferral(conn, step) do
	conn
			|> configure_session(renew: true)
			|> assign(:step, step)
			|> put_session(:step, step)
  end
	
  def getReferAppUrl do
	"https://refer-ui-two.vercel.app/"
  end
  
  def getEmail(conn) do
	result = Map.get(conn.assigns.current_user, :email)
	result
  end
  
  def getName(conn) do
	result = Map.get(conn.assigns.current_user, :full_name)
	result
  end
  
  def getBaseUrl do
	result = Repo.one(from u in "avalanche", select: u.site_base_url)
	result
  end
  
  def getRedirectUri do
	result = Repo.one(from u in "avalanche", select: u.site_redirect)
	result
  end

   
  def getToken do
	oauth_url = Repo.one(from u in "avalanche", select: u.oauth_url)
	client_id = Repo.one(from u in "avalanche", select: u.cliend_id)
	client_secret = Repo.one(from u in "avalanche", select: u.client_secret)
	audience = Repo.one(from u in "avalanche", select: u.audience)
	grant_type = Repo.one(from u in "avalanche", select: u.grant_type)
	token_live = Repo.one(from u in "avalanche", select: u.token_live)
	token = Repo.one(from u in "avalanche", select: u.token)
	
	now_date = DateTime.utc_now()
	difference = NaiveDateTime.diff(token_live, now_date, :seconds) / 60 / 60
	
	if difference > 23 || !token do
		url = oauth_url
		body = Poison.encode!(%{
		  "client_id": client_id,
		  "client_secret": client_secret,
		  "audience": audience,
		  "grant_type": grant_type,
		  
		})
		headers = [{"Content-type", "application/json"}]
		{:ok, response}  = HTTPoison.post(url, body, headers, [])
		
		result = response.body 
			|> Poison.decode!
			|> Map.take(@expected_fields_token)
			|> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
		
		new_token = "#{result[:token_type]} #{result[:access_token]}"
		
		Repo.update_all(Avalanche, set: [token: new_token, token_live: now_date])
		
	end
	
	token = Repo.one(from u in "avalanche", select: u.token)
	token
	
  end
  
  def setPremiumEvent(mail) do 	
	referapp_api_url = Repo.one(from u in "avalanche", select: u.referapp_api_url)
	token = Repo.one(from u in "avalanche", select: u.token)
	
	url = "#{referapp_api_url}/events/premium_event"
	body = Poison.encode!(%{
		"email": mail
		  
	})
	headers = [{"Authorization", token}, {"Content-type", "application/json"}]
	{:ok, response}  = HTTPoison.post(url, body, headers, [])
  end
  
  def confirmedUserRef(mail, refCode) do 	
	referapp_api_url = Repo.one(from u in "avalanche", select: u.referapp_api_url)
	token = Repo.one(from u in "avalanche", select: u.token)
	emailRef = getEmailReferrer(refCode)
	
	url = "#{referapp_api_url}/events/sign_up_by_email"
	body = Poison.encode!(%{
		"email": emailRef,
		"referral_code": refCode
	})
	headers = [{"Authorization", token}, {"Content-type", "application/json"}]
	{:ok, response}  = HTTPoison.post(url, body, headers, [])
  end
  
  def getEmailReferrer(refCode) do 
	referapp_api_url = Repo.one(from u in "avalanche", select: u.referapp_api_url)
	body = Poison.encode!(%{
		"refCode": refCode
		  
	})
	headers = [{"Content-type", "application/json"}]
	url = "#{referapp_api_url}/events/getRefererByCode?refCode=#{refCode}"
	{:ok, response}  = HTTPoison.request("get", url, body, headers, [])
	
	result = response.body
			|> Poison.decode!
			|> Map.take(@expected_fields_email)
			|> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
			
	"#{result[:email]}"
  end
  
  def updateReferralEmail(emailRef, refCode) do
	referapp_api_url = Repo.one(from u in "avalanche", select: u.referapp_api_url)
	token = Repo.one(from u in "avalanche", select: u.token)
	
	url = "#{referapp_api_url}/events/updateReferralEmail"
	body = Poison.encode!(%{
		"email": emailRef,
		"refCode": refCode
	})
	headers = [{"Authorization", token}, {"Content-type", "application/json"}]
	{:ok, response}  = HTTPoison.post(url, body, headers, [])
  end
  
  
  
end
