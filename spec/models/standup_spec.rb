require 'rails_helper'

RSpec.describe Standup, type: :model do
  let(:standup) {FactoryBot.build(:standup)}

  describe 'constants' do
    it 'has the correct exportable columns defined' do
      expect(Standup::EXPORTABLE_COLUMNS).to eq(['created_at', 'name', 'worklog'])
    end
  end

  describe 'scopes' do 
    describe 'default scope' do
      it 'returns all the standups in order of latest first' do
        standup_1 = FactoryBot.create(:standup)
        standup_2 = FactoryBot.create(:standup)
        expect(Standup.all).to eq([standup_2, standup_1])
      end
    end

    describe '.for_today scope' do
      it 'returns all the standups in order of latest first that are created today' do
        standup_1 = FactoryBot.create(:standup, created_at: Time.zone.now.prev_day)
        standup_2 = FactoryBot.create(:standup)
        standup_3 = FactoryBot.create(:standup)
        expect(Standup.for_today).to eq([standup_3, standup_2])
      end
    end

    describe '.for_yesterday scope' do
      it 'returns all the standups in order of latest first that are created yesterday' do
        standup_1 = FactoryBot.create(:standup, created_at: Time.zone.now.prev_day)
        standup_2 = FactoryBot.create(:standup)
        expect(Standup.for_yesterday).to eq([standup_1])
      end
    end
    
    describe '.exclude_new_records scope' do
      it 'returns all the standups in order of latest first excluding initialised records' do
        standup_1 = FactoryBot.create(:standup)
        standup_2 = FactoryBot.build(:standup)
        expect(Standup.exclude_new_records).to eq([standup_1])
      end
    end
  end

  describe 'delegate' do 
    it "delegates to users name without prefix" do
      expect(standup.name).to eq(standup.user.name)
    end
  end

  describe "validations" do
    it "is valid with valid attributes"do
      expect(standup).to be_valid
    end

    it "is not valid without a user" do
      standup.user = nil
      expect(standup).to_not be_valid
    end
    it "is not valid without a worklog" do
      standup.worklog = nil
      expect(standup).to_not be_valid
    end
  end

  describe '#is_changeable' do
    it 'return false for unauthorised user' do
      user = FactoryBot.create(:user)
      expect(standup.is_changeable?(user.id)).to eq(false)
    end

    it 'return false for past days scenario' do
      standup_1 = FactoryBot.create(:standup, created_at: Time.zone.now.prev_day)
      expect(standup.is_changeable?(standup_1.user.id)).to eq(false)
    end

    it 'return true when it is created today & requester is the same user' do
      standup.save
      expect(standup.is_changeable?(standup.user_id)).to eq(true)
    end
  end

  describe '#filter_results' do 
    it 'return correct results when no filters' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      standup_1 = FactoryBot.create(:standup, user: user_1)
      standup_2 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day)
      standup_3 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day(2))
      standup_4 = FactoryBot.create(:standup, user: user_2)
      standup_5 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day)
      standup_6 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day(2))
      search_params = {}
      expect(Standup.filter_results(search_params)).to eq(Standup.all)
    end

    it 'return correct results when user id is passed' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      standup_1 = FactoryBot.create(:standup, user: user_1)
      standup_2 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day)
      standup_3 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day(2))
      standup_4 = FactoryBot.create(:standup, user: user_2)
      standup_5 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day)
      standup_6 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day(2))
      search_params = {user_id: user_1.id}

      expect(Standup.filter_results(search_params).to_a).to eq(Standup.where(id: [standup_1.id, standup_2.id, standup_3.id]).to_a)
    end

    it 'return correct results when user id & from date is passed' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      standup_1 = FactoryBot.create(:standup, user: user_1)
      standup_2 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day)
      standup_3 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day(2))
      standup_4 = FactoryBot.create(:standup, user: user_2)
      standup_5 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day)
      standup_6 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day(2))
      search_params = {user_id: user_1.id, from_date: Time.zone.now.prev_day}

      expect(Standup.filter_results(search_params).to_a).to eq(Standup.where(id: [standup_1.id, standup_2.id]).to_a)
    end

    it 'return correct results when user id,  from date & to data is passed' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      standup_1 = FactoryBot.create(:standup, user: user_1)
      standup_2 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day)
      standup_3 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day(2))
      standup_4 = FactoryBot.create(:standup, user: user_2)
      standup_5 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day)
      standup_6 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day(2))
      search_params = {user_id: user_1.id, from_date: Time.zone.now.prev_day(2), to_date: Time.zone.now.prev_day}

      expect(Standup.filter_results(search_params).to_a).to eq(Standup.where(id: [standup_2.id, standup_3.id]).to_a)
    end

    it 'return correct results when user id,  same from date & to data is passed' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      standup_1 = FactoryBot.create(:standup, user: user_1)
      standup_2 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day)
      standup_3 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day(2))
      standup_4 = FactoryBot.create(:standup, user: user_2)
      standup_5 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day)
      standup_6 = FactoryBot.create(:standup, user: user_2, created_at: Time.zone.now.prev_day(2))
      search_params = {user_id: user_1.id, from_date: Time.zone.now.prev_day, to_date: Time.zone.now.prev_day}

      expect(Standup.filter_results(search_params).to_a).to eq(Standup.where(id: [standup_2.id]).to_a)
    end

    it 'return correct results when user id, same from date & to data is passed & worklog content' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      standup_1 = FactoryBot.create(:standup, user: user_1, worklog: "I have completed device task")
      standup_2 = FactoryBot.create(:standup, user: user_1, worklog: "I have completed device task", created_at: Time.zone.now.prev_day)
      standup_3 = FactoryBot.create(:standup, user: user_1, worklog: "I have completed device task", created_at: Time.zone.now.prev_day(2))
      standup_4 = FactoryBot.create(:standup, user: user_2, worklog: "I have completed device task")
      standup_5 = FactoryBot.create(:standup, user: user_2, worklog: "I have completed device task", created_at: Time.zone.now.prev_day)
      standup_6 = FactoryBot.create(:standup, user: user_2, worklog: "I have completed device task", created_at: Time.zone.now.prev_day(2))
      standup_7 = FactoryBot.create(:standup, user: user_1, created_at: Time.zone.now.prev_day)
      search_params = {user_id: user_1.id, from_date: Time.zone.now.prev_day, to_date: Time.zone.now.prev_day, worklog: 'device'}

      expect(Standup.filter_results(search_params).to_a).to eq(Standup.where(id: [standup_2.id]).to_a)
    end
  end


  describe 'set_absentees_worklog' do
    it "create correct absentees when all users absent" do 
      FactoryBot.create(:user)
      FactoryBot.create(:user)
      expect {Standup.set_absentees_worklog}.to change{ Standup.count }.by(2)

    end

    it "create correct absentees when one user absent" do 
      user_1 = FactoryBot.create(:user)
      FactoryBot.create(:user)
      FactoryBot.create(:standup, user: user_1,  created_at: Time.zone.now.prev_day)
      expect {Standup.set_absentees_worklog}.to change{ Standup.count }.by(1)
    end

    it "create correct absentees when no user absent" do 
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      FactoryBot.create(:standup, user: user_1,  created_at: Time.zone.now.prev_day)
      FactoryBot.create(:standup, user: user_2,  created_at: Time.zone.now.prev_day)
      expect {Standup.set_absentees_worklog}.to change{ Standup.count }.by(0)
    end
  end
end
