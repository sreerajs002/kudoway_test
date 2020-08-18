require 'rails_helper'

RSpec.describe "Standups", type: :request do

  let(:user) { FactoryBot.create(:user) }
  let(:valid_attributes) {
      {:user_id => user.id,
       :worklog => 'Made the following changes',
      }
    }

    let(:invalid_attributes) {
      {:worklog => nil}
    }
  describe "GET /index" do
    context "un authenticated user" do 
      it "returns http success redirection to sign_in page" do
        get "/standups"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "authenticated user" do 
      it "returns http success when no filters" do
        sign_in user
        get "/standups"
        expect(response).to have_http_status(:success)
        assigns(:standups).should eq([])
      end
    end
  end

  describe "GET /new" do
    context "un authenticated user" do 
      it "returns http success redirection to sign_in page" do
        get "/standups/new"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "authenticated user" do 
      it "returns http success" do
        sign_in user
        get "/standups/new"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /standups" do
    context "un authenticated user" do 
      it "returns http success redirection to sign_in page" do
        post "/standups", params: {}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "authenticated user" do 
      it "returns http success redirection for valid_attributes" do
        sign_in user
        post "/standups", params: {standup: valid_attributes}
        expect(response).to redirect_to(new_standup_path)
      end

      it "success render for invalid_attributes" do
        sign_in user
        post "/standups", params: {standup: invalid_attributes}
        expect(response).to render_template('new')
      end
    end
  end

  describe "GET /standups/:id/edit" do
    context "un authenticated user" do 
      it "returns http success redirection to sign_in page" do
        standup = FactoryBot.create(:standup, user: user)
        get "/standups/#{standup.to_param}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "authenticated user" do 
      it "returns http success" do
        sign_in user
        standup = FactoryBot.create(:standup, user: user)
        get "/standups/#{standup.to_param}/edit"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PUT /standups/:id" do
    context "un authenticated user" do 
      it "returns http success redirection to sign_in page" do
        standup = FactoryBot.create(:standup, user: user)
        put "/standups/#{standup.to_param}", params: {standup: valid_attributes}
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "authenticated user" do 
      it "http success redirection for valid_attributes" do
        sign_in user
        standup = FactoryBot.create(:standup, user: user)
        put "/standups/#{standup.to_param}", params: {standup: valid_attributes}
        expect(response).to redirect_to(new_standup_path)
      end

      it "success render for invalid_attributes" do
        sign_in user
        standup = FactoryBot.create(:standup, user: user)
        put "/standups/#{standup.to_param}", params: {standup: invalid_attributes}
        expect(response).to render_template('edit')
      end
    end
  end

  describe "DELETE /standups/:id" do
    context "un authenticated user" do 
      it "returns http success redirection to sign_in page" do
        standup = FactoryBot.create(:standup, user: user)
        delete "/standups/#{standup.to_param}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "authenticated user" do 
      it "raise exception when unauthorised delete" do
        sign_in user
        standup = FactoryBot.create(:standup, user: user)
        standup_1 = FactoryBot.create(:standup)
        
        expect{
          delete "/standups/#{standup_1.to_param}"
        }.to raise_error(RuntimeError)
      end

      it "returns http success redirection for valid_attributes" do
        sign_in user
        standup = FactoryBot.create(:standup, user: user)
        delete "/standups/#{standup.to_param}"
        expect(response).to redirect_to(new_standup_path)
      end
    end
  end

end
