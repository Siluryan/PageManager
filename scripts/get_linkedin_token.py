#!/usr/bin/env python3
"""OAuth LinkedIn (w_member_social) → token + URN para PageManager."""
import threading
import time
import webbrowser
import requests
import urllib.parse
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

CLIENT_ID     = os.environ.get("LINKEDIN_CLIENT_ID")     or input("LINKEDIN_CLIENT_ID: ").strip()
CLIENT_SECRET = os.environ.get("LINKEDIN_CLIENT_SECRET") or input("LINKEDIN_CLIENT_SECRET: ").strip()

SCOPE    = "openid profile w_member_social"
REDIRECT = "http://localhost:8765/callback"
AUTH_URL = "https://www.linkedin.com/oauth/v2/authorization"
TOKEN_URL = "https://www.linkedin.com/oauth/v2/accessToken"

callback_result = {"code": None, "error": None, "error_description": None}


class CallbackHandler(BaseHTTPRequestHandler):
	def do_GET(self):
		qs = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
		err = (qs.get("error") or [""])[0]
		desc = (qs.get("error_description") or [""])[0]

		if err:
			callback_result["error"] = err
			callback_result["error_description"] = urllib.parse.unquote_plus(desc)
			body = (
				"<html><body style='font-family:sans-serif'><h2 style='color:#c00'>Erro OAuth</h2>"
				f"<p>{err}</p><p>{callback_result['error_description']}</p>"
				"<p>Volte ao terminal.</p></body></html>"
			).encode("utf-8")
		else:
			callback_result["code"] = (qs.get("code") or [""])[0]
			body = b"<html><body><h2>Autorizado! Volte ao terminal.</h2></body></html>"

		self.send_response(200)
		self.send_header("Content-Type", "text/html; charset=utf-8")
		self.send_header("Content-Length", str(len(body)))
		self.end_headers()
		self.wfile.write(body)

	def log_message(self, format, *args):
		pass


def start_server():
	HTTPServer(("127.0.0.1", 8765), CallbackHandler).serve_forever()


def wait_for_callback():
	while callback_result["code"] is None and callback_result["error"] is None:
		time.sleep(0.05)


def main():
	print("=" * 55)
	print("  LinkedIn Token — Perfil pessoal (w_member_social)")
	print("=" * 55)

	threading.Thread(target=start_server, daemon=True).start()

	auth_url = (
		f"{AUTH_URL}?response_type=code"
		f"&client_id={CLIENT_ID}"
		f"&redirect_uri={urllib.parse.quote(REDIRECT, safe='')}"
		f"&scope={urllib.parse.quote(SCOPE, safe='')}"
		f"&state=pagemanager-personal"
	)

	print("\n[1/3] Abrindo o navegador...")
	print(f"      {auth_url}\n")
	webbrowser.open(auth_url)
	print("      Aguardando autorização...")
	wait_for_callback()

	if callback_result["error"]:
		print(f"\nERRO: {callback_result['error']}")
		print(callback_result["error_description"])
		if "w_member_social" in (callback_result.get("error_description") or ""):
			print("\nAdicione o produto **Share on LinkedIn** ao app em:")
			print("https://www.linkedin.com/developers/apps")
		raise SystemExit(1)

	code = callback_result["code"]
	if not code:
		print("ERRO: sem código de autorização.")
		raise SystemExit(1)

	print("[2/3] Trocando código por access token...")
	resp = requests.post(TOKEN_URL, data={
		"grant_type":    "authorization_code",
		"code":          code,
		"redirect_uri":  REDIRECT,
		"client_id":     CLIENT_ID,
		"client_secret": CLIENT_SECRET,
	}, timeout=30)
	resp.raise_for_status()
	access_token = resp.json()["access_token"]
	expires_in   = resp.json().get("expires_in", 5184000)
	print(f"      OK. Expira em ~{expires_in // 86400} dias.\n")

	print("[3/3] Obtendo URN do perfil (OpenID userinfo)...")
	person_id = None
	try:
		me = requests.get(
			"https://api.linkedin.com/v2/userinfo",
			headers={"Authorization": f"Bearer {access_token}"},
			timeout=10,
		)
		if me.ok:
			person_id = me.json().get("sub") or me.json().get("id")
	except Exception:
		pass

	if not person_id:
		print("  Não foi possível obter o ID automaticamente.")
		person_id = input("  Cole o 'sub' do userinfo ou ID numérico do perfil: ").strip()

	member_urn = person_id if person_id.startswith("urn:li:") else f"urn:li:person:{person_id}"

	print("\n" + "=" * 55)
	print("Copie para o .env / terraform:")
	print("=" * 55)
	print(f"LINKEDIN_ACCESS_TOKEN={access_token}")
	print(f"LINKEDIN_MEMBER_URN={member_urn}")
	print("=" * 55)
	print("\nToken expira em ~60 dias. Rode este script de novo para renovar.")


if __name__ == "__main__":
	main()

