require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Member, type: :model do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_url_of(:url) }
  end

  describe 'Relations' do
    it { is_expected.to have_many(:friendships) }
    it { is_expected.to have_many(:friends).dependent(:destroy).through(:friendships) }
    it { is_expected.to have_many(:headings).dependent(:destroy).inverse_of(:member) }
  end

  describe 'callbacks' do
    describe 'after create', :vcr do
      let(:member) { build(:member, url: 'https://nokogiri.org') }
      let(:expected_headings) do
        [
          'Authors¶',
          'CRuby¶',
          'Code of Conduct¶',
          'Contributing¶',
          'Dependencies¶',
          'Encoding¶',
          'Features Overview¶',
          'Guiding Principles¶',
          'Guiding Principles¶',
          'How To Use Nokogiri¶',
          'Installation¶',
          'JRuby¶',
          'License¶',
          'Native Gems: Faster, more reliable installation¶',
          'Nokogiri¶',
          'Other Installation Options¶',
          'Parsing and Querying¶',
          'Questions¶',
          'Reading¶',
          'Security and Vulnerability Reporting¶',
          'Semantic Versioning Policy¶',
          'Status¶',
          'Support and Help¶',
          'Supported Platforms¶',
          'Technical Overview¶',
        ]
      end
      let(:expected_short_url) { 'https://bit.ly/3qrL9iw' }

      before do
        Sidekiq::Testing.fake!
        allow(member).to receive(:enqueue_creation_jobs).and_call_original
        Sidekiq::Worker.clear_all

        member.save
        Sidekiq::Worker.drain_all
        member.reload
      end

      it "extracts the member's website headings" do
        expect(member.headings.size).to eq expected_headings.size
        expect(member.headings.ordered.pluck(:text)).to eq expected_headings
      end

      it "shortens the member's website URL" do
        expect(member.short_url).to be_present
        expect(member.short_url).to eq expected_short_url
      end
    end
  end

  describe 'frienship reciprocity' do
    let(:member) { create(:member) }
    let(:other_member) { create(:member) }

    before do
      member.friends << other_member
    end

    it 'is reciprocal' do
      expect(member.friends).to eq [other_member]
      expect(other_member.friends).to eq [member]
    end
  end

  describe 'finding paths' do
    let(:rick) { create(:member, name: 'Rick Sanchez', url: 'https://rickandmorty.fandom.com/wiki/Rick_Sanchez') }
    let(:doofus_rick) { create(:member, name: 'Rick Sanchez J19 Zeta 7', url: 'https://rickandmorty.fandom.com/wiki/Doofus_Rick') }
    let(:morty) { create(:member, name: 'Morty Smith', url: 'https://rickandmorty.fandom.com/wiki/Morty_Smith') }
    let(:jessica) { create(:member, name: 'Jessica', url: 'https://en.wikipedia.org/wiki/Kari_Wahlgren') }
    let(:summer) { create(:member, name: 'Summer Smith', url: 'https://en.wikipedia.org/wiki/Spencer_Grammer') }
    let(:jerry) { create(:member, name: 'Jerry Smith', url: 'https://en.wikipedia.org/wiki/Chris_Parnell') }
    let(:beth) { create(:member, name: 'Beth Smith', url: 'https://en.wikipedia.org/wiki/Sarah_Chalke') }
    let(:scary_terry) { create(:member, name: 'Scary Terry', url: 'https://en.wikipedia.org/wiki/Jess_Harnell') }
    let(:members) { [rick, doofus_rick, morty, jessica, summer, jerry, beth, scary_terry] }
    let(:do_friends) do
      rick.friends << morty
      rick.friends << beth

      morty.friends << jessica
      morty.friends << summer
      morty.friends << jerry
      morty.friends << beth

      beth.friends << jerry

      jerry.friends << doofus_rick
    end

    before do
      Sidekiq::Testing.fake!
      do_friends
      Sidekiq::Worker.drain_all
      members.each { |m| m.reload }
    end

    describe '#path_to', :vcr do
      context 'when a member has no friends' do
        subject(:path) { scary_terry.path_to(morty) }

        it 'returns an empty array' do
          expect(path).to be_a Array
          expect(path).to be_empty
        end
      end

      context 'when searching for the path to self' do
        subject(:path) { scary_terry.path_to(scary_terry) }

        it 'returns an empty array' do
          expect(path).to be_a Array
          expect(path).to be_empty
        end
      end

      context 'when there is no friendship path between two members' do
        subject(:path) { rick.path_to(scary_terry) }

        it 'returns an empty array' do
          expect(path).to be_a Array
          expect(path).to be_empty
        end
      end

      context 'when searching the path to a friend' do
        let(:expected_path) { ["Rick Sanchez", "Morty Smith"] }

        subject(:path) { rick.path_to(morty) }

        it 'returns the path' do
          expect(path).to be_a Array
          expect(path).to eq expected_path
        end
      end

      context 'when there is a friendship path between two members' do
        let(:expected_path) { ["Rick Sanchez", "Beth Smith", "Jerry Smith", "Morty Smith", "Summer Smith"] }

        subject(:path) { rick.path_to(summer) }

        it 'returns the path' do
          expect(path).to be_a Array
          expect(path).to eq expected_path
        end
      end

      context 'when there are more than one friendship paths between two members' do
        let(:expected_path) { ["Rick Sanchez", "Beth Smith", "Jerry Smith", "Rick Sanchez J19 Zeta 7"] }

        subject(:path) { rick.path_to(doofus_rick) }

        it 'returns the shortest path' do
          expect(path).to be_a Array
          expect(path).to eq expected_path
        end
      end
    end

    describe '#shortest_path_to', :vcr do
      context 'when a member has no friends' do
        subject(:path) { scary_terry.shortest_path_to(morty) }

        it 'returns an empty array' do
          expect(path).to be_a Array
          expect(path).to be_empty
        end
      end

      context 'when searching for the path to self' do
        subject(:path) { scary_terry.shortest_path_to(scary_terry) }

        it 'returns an empty array' do
          expect(path).to be_a Array
          expect(path).to be_empty
        end
      end

      context 'when there is no friendship path between two members' do
        subject(:path) { rick.shortest_path_to(scary_terry) }

        it 'returns an empty array' do
          expect(path).to be_a Array
          expect(path).to be_empty
        end
      end

      context 'when searching the path to a friend' do
        let(:expected_path) { ["Rick Sanchez", "Morty Smith"] }

        subject(:path) { rick.shortest_path_to(morty) }

        it 'returns the path' do
          expect(path).to be_a Array
          expect(path).to eq expected_path
        end
      end

      context 'when there is a friendship path between two members' do
        let(:expected_path) { ["Rick Sanchez", "Morty Smith", "Summer Smith"] }

        subject(:path) { rick.shortest_path_to(summer) }

        it 'returns the path' do
          expect(path).to be_a Array
          expect(path).to eq expected_path
        end
      end

      context 'when there are more than one friendship paths between two members' do
        let(:expected_path) { ["Rick Sanchez", "Beth Smith", "Jerry Smith", "Rick Sanchez J19 Zeta 7"] }

        subject(:path) { rick.shortest_path_to(doofus_rick) }

        it 'returns the shortest path' do
          expect(path).to be_a Array
          expect(path).to eq expected_path
        end
      end
    end
  end
end

# ## Schema Information
#
# Table name: `members`
#
# ### Columns
#
# Name                                    | Type               | Attributes
# --------------------------------------- | ------------------ | ---------------------------
# **`id`**                                | `uuid`             | `not null, primary key`
# **`name(Name)`**                        | `text`             | `not null`
# **`short_url(Shortened website URL)`**  | `text`             |
# **`url(Website URL)`**                  | `text`             | `not null`
# **`created_at`**                        | `datetime`         | `not null`
# **`updated_at`**                        | `datetime`         | `not null`
#
