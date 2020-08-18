require 'rails_helper'

RSpec.describe StandupsHelper, type: :helper do

  describe '#display_links' do
    let(:user) {FactoryBot.create(:user)}

    it 'returns links if object is changeable' do
      standup = FactoryBot.create(:standup, user: user)
      expecting_links = link_to("Edit", edit_standup_path(standup), class: 'm-r-sm') + link_to("Delete", standup, method: :delete, data: { confirm: 'Are you sure?' }, class: 'm-r-sm')
      expect(display_links(standup, user)).to eq(expecting_links)
    end

    it 'return nil for unauthorised user' do
      standup = FactoryBot.create(:standup)
      expect(display_links(standup, user)).to eq(nil)
    end

    it 'return nil for past days scenario' do
      standup = FactoryBot.create(:standup, user: user, created_at: Time.zone.now.prev_day)
      expect(display_links(standup, user)).to eq(nil)
    end
  end

  describe '#formatted_date' do
    it 'returns the date in the desired format' do
      date = Time.zone.now
      formatted_date = date.try(:strftime, "%e-%m-%Y")
      expect(formatted_date(date)).to eq(formatted_date)
    end

    it 'return nil if argument is not date' do
      date = ""
      expect(formatted_date(date)).to eq(nil)
    end
  end

  describe '#users_select_options' do
    it 'returns the correct options for the user select control' do
      user_1 = FactoryBot.create(:user)
      user_2 = FactoryBot.create(:user)
      expect(users_select_options).to eq([[user_1.name, user_1.id], [user_2.name, user_2.id]])
    end

    it 'returns the correct options for the user select control' do
      expect(users_select_options).to eq([])
    end
  end
end
