require 'rails_helper'

RSpec.describe "Donations", type: :request do
  describe "POST /donations" do
    let(:valid_attributes) do
      {
        donation: {
          amount: 100.00,
          reference: "DonationRef123",
          customer_no: "254712345678"
        }
      }
    end

    let(:invalid_attributes) do
      {
        donation: {
          amount: nil,
          reference: "",
          customer_no: ""
        }
      }
    end

    context "with valid parameters" do
      it "creates a new Donation and returns success" do
        post "/donations", params: valid_attributes

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["status"]).to eq("success")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Donation and returns errors" do
        post "/donations", params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end
end
