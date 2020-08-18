require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  it "is valid with valid attributes" do 
    expect(user).to be_valid
  end

  it "is not valid without a email" do 
    user.email = nil
    expect(user).to_not be_valid
  end
  it "is not valid without a password" do 
    user.password = nil
    expect(user).to_not be_valid
  end
  it "is not valid without a name" do 
    user.name = nil
    expect(user).to_not be_valid
  end

  describe 'associations' do
    it 'has many standups' do
      should have_many(:standups)
    end
  end
end
