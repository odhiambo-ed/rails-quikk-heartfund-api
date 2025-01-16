require "net/http"
require "json"
require "base64"
require "time"
require "openssl"
require "uri"
require "securerandom"

class DonationsController < ApplicationController
  QUIKK_URL = 'https://tryapi.quikk.dev/v1/mpesa/charge'
  DATE_HEADER = 'date'

   def create
    donation = Donation.new(donation_params)

    if donation.save
      response = make_post_request(donation)
      render json: { status: 'success', response: response.body }, status: :created
    else
      render json: { errors: donation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def donation_params
    params.require(:donation).permit(:amount, :reference, :customer_no)
  end

  def generate_hmac_signature
    timestamp = Time.now.httpdate
    to_encode = "#{DATE_HEADER}: #{timestamp}"

    hmac = OpenSSL::HMAC.digest('SHA256', ENV['QUIKK_SECRET'], to_encode)
    encoded = Base64.strict_encode64(hmac)
    url_encoded = URI.encode_www_form_component(encoded)

    auth_string = %(keyId="#{ENV['QUIKK_KEY']}",algorithm="hmac-sha256",headers="#{DATE_HEADER}",signature="#{url_encoded}")

    [timestamp, auth_string]
  end

  def make_post_request(donation)
    timestamp, auth_string = generate_hmac_signature

    uri = URI.parse(QUIKK_URL)
    client = Net::HTTP.new(uri.host, uri.port)
    client.use_ssl = true
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/vnd.api+json'
    request[DATE_HEADER] = timestamp
    request['Authorization'] = auth_string
    request.body = {
      data: {
        id: SecureRandom.uuid,
        type: 'charge',
        attributes: {
          amount: donation.amount.to_i,  # Convert amount to integer
          posted_at: Time.now.utc.iso8601,
          reference: donation.reference,
          short_code: '174379',
          customer_no: donation.customer_no,
          customer_type: 'msisdn'
        }
      }
    }.to_json

    Rails.logger.info("Request Body: #{request.body}")
    Rails.logger.info("Request Headers: #{request.to_hash}")

    response = client.request(request)

    Rails.logger.info("Response Code: #{response.code}")
    Rails.logger.info("Response Body: #{response.body}")

    response
  end
end
