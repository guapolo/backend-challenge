require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:member) { create(:member) }
  let(:other_member) { create(:member) }
  let(:friendship) { described_class.create(member_id: member.id, friend_id: other_member.id) }

  describe 'validations' do
    it 'uniqueness' do
      expect(friendship).to validate_uniqueness_of(:friend_id).scoped_to(:member_id).case_insensitive
    end
  end

  describe 'relations' do
    it { is_expected.to belong_to(:member) }
    it { is_expected.to belong_to(:friend).class_name('Member') }
  end

  describe 'callbacks' do
    describe 'after create' do
      describe 'adds a reciprocal relation' do
        context 'when no reciprocal relation exists' do
          before do
            friendship
          end

          it 'creates a reciprocal relation' do
            expect(described_class.where(member_id: other_member.id, friend_id: member.id).count).to eq 1
          end
        end

        context 'when a reciprocal relation exists' do
          before do
            described_class.insert(
              member_id: other_member.id,
              friend_id: member.id,
              created_at: Time.zone.now,
              updated_at: Time.zone.now
            )

            friendship
          end

          it 'preserves the reciprocal relation' do
            expect(described_class.where(member_id: other_member.id, friend_id: member.id).count).to eq 1
          end
        end
      end
    end

    describe 'after destroy' do
      describe 'destroys a reciprocal relation' do
        context 'when no reciprocal relation exists' do
          before do
            friendship

            described_class.where(
              member_id: other_member.id,
              friend_id: member.id
            ).delete_all

            friendship.destroy
          end

          it 'does nothing' do
            expect(described_class.where(member_id: other_member.id, friend_id: member.id).count).to be_zero
          end
        end

        context 'when a reciprocal relation exists' do
          before do
            friendship.destroy
          end

          it 'destroys the reciprocal relation' do
            expect(described_class.where(member_id: other_member.id, friend_id: member.id).count).to be_zero
          end
        end
      end
    end

  end
end

# ## Schema Information
#
# Table name: `friendships`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`friend_id(Friend UUID)`**  | `uuid`             | `not null`
# **`member_id(Member UUID)`**  | `uuid`             | `not null`
#
# ### Indexes
#
# * `index_friendships_on_friend_id`:
#     * **`friend_id`**
# * `index_friendships_on_member_id`:
#     * **`member_id`**
# * `index_friendships_on_member_id_and_friend_id` (_unique_):
#     * **`member_id`**
#     * **`friend_id`**
#
# ### Foreign Keys
#
# * `fk_rails_2ed7e67632`:
#     * **`member_id => members.id`**
# * `fk_rails_d78dc9c7fd`:
#     * **`friend_id => members.id`**
#
