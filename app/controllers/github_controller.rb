class GithubController < ApplicationController
  def create
    jwt_token = generate_jwt_token
    client = Octokit::Client.new(bearer_token: jwt_token)
    p "Authenticated as #{client.app.name}"
  rescue Octokit::Error => e
    p e
  end

  private

  def generate_jwt_token
    private_key_path = Rails.root.join(Rails.application.credentials.github[:private_key_path])
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))

    payload = {
      # issued at time, 60 seconds in the past to allow for clock drift
      iat: Time.now.to_i - 60,
      # JWT expiration time (10 minute maximum)
      exp: Time.now.to_i + (10 * 60),
      # GitHub App's identifier
      iss: Rails.application.credentials.github[:app_id]
    }

    JWT.encode(payload, private_key, 'RS256')
  end
end
