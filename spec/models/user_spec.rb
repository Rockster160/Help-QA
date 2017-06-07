# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  last_seen_at           :datetime
#  avatar_url             :string
#  verified_at            :datetime
#

require 'rails_helper'

RSpec.describe User, type: :model do

  context "validations" do
    context "username" do
      context "when blank" do
        let(:user) { ::FactoryGirl.build(:user, username: "") }

        it "should be invalid" do
          expect(user.valid?).to be(false)
          expect(user.errors.keys).to include(:username)
        end
      end

      context "as only numbers" do
        let(:user) { ::FactoryGirl.build(:user, username: "12345678") }

        it "should be invalid" do
          expect(user.valid?).to be(false)
          expect(user.errors.keys).to include(:username)
        end
      end

      context "with a space" do
        let(:user) { ::FactoryGirl.build(:user, username: "hello world") }

        it "should be invalid" do
          expect(user.valid?).to be(false)
          expect(user.errors.keys).to include(:username)
        end
      end

      context "when username already exists" do
        let!(:user1) { ::FactoryGirl.create(:user, username: "helloworld") }
        let(:user2) { ::FactoryGirl.build(:user, username: "helloworld") }

        it "should be valid" do
          expect(user2.valid?).to be(false)
        end
      end

      context "with special characters" do
        let(:user) { ::FactoryGirl.build(:user, username: "~~~helloworld~~~") }

        it "should be valid" do
          expect(user.valid?).to be(true)
        end
      end
    end
  end

  context "default values" do
    context "username" do
      let(:user) { ::FactoryGirl.create(:user, username: nil, email: "thisismy@email.com") }

      it "should auto set the username to the first part of their email" do
        expect(user.username).to eq("thisismy")
      end
    end
  end

  context "public methods" do
    context "ip_address" do
      let(:user) { ::FactoryGirl.create(:user, last_sign_in_ip: "174.52.39.242") }

      it "should fall back to some value" do
        expect(user.ip_address).to eq("174.52.39.242")
      end
    end

    context "see!" do
      let(:user) { ::FactoryGirl.create(:user, last_seen_at: nil) }

      it "should update the last_seen_at attribute" do
        user.see!
        expect(user.reload.last_seen_at).to_not be(nil)
      end
    end

    context "letter" do
      let(:user) { ::FactoryGirl.create(:user, username: "~~!@#hello") }

      it "should return the first alpha charater in the username" do
        expect(user.letter).to eq("H")
      end
    end

    context "online?" do
      context "when recently seen" do
        let(:user) { ::FactoryGirl.create(:user, last_seen_at: 2.minutes.ago) }

        it "should return true" do
          expect(user.online?).to be(true)
        end
      end

      context "when not recently seen" do
        let(:user) { ::FactoryGirl.create(:user, last_seen_at: 2.years.ago) }

        it "should return false" do
          expect(user.online?).to be(false)
        end
      end
    end
  end

end
