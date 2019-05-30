require 'rails_helper'

RSpec.describe Api::V1::ChatApplicationsController, type: :controller do

  describe 'POST #create' do
    valid_params = { params: {
      name: 'First ChatApplication'
    } }
    invalid_params = { params: {
      name: nil
    } }
    context 'with valid params' do
      before do
        post :create, valid_params
      end

      it 'is expected to return the token' do
        json = JSON.parse(response.body)
        expect(json["token"]).to eql(ChatApplication.first.token)
        @chat_application_token = ChatApplication.first.token
      end

      it 'is expected to respond with 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      before do
        post :create, invalid_params
      end

      it 'is expected to respond with 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #show' do

    let!(:token) do
      post :create, { params: { name: "First application"}}
      expect(response).to be_success
      @token = JSON.parse(response.body)["token"]
    end

    context 'with valid params' do
      before do
        get :show, { params: {token: @token } }
      end

      it 'is expected to return the ChatApplication object' do
        json = JSON.parse(response.body)
        expect(json["token"]).to eql(@token)
      end

      it 'is expected to respond with 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      before do
        get :show, { params: {token: ''} }
      end

      it 'is expected to respond with 404' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'Put #update' do

    let!(:chat_application_token) do
      post :create, { params: { name: "First application"}}
      expect(response).to be_success
      @token = JSON.parse(response.body)["token"]
    end

    context 'with valid params' do
      before do
        put :update, { params: {name: 'Chat application new name', token: @token } }
      end

      it 'is expected to return the ChatApplication with its new name' do
        json = JSON.parse(response.body)
        expect(json["name"]).to eql('Chat application new name')
      end

      it 'is expected to respond with 200' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid params' do
      before do
        put :update, { params: {name: '', token: @token } }
      end

      it 'is expected to respond with 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
