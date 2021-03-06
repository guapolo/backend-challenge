# frozen_string_literal: true

require 'rails_helper'

describe Members::Website::HeadingExtractionService, :vcr do
  describe '.call' do
    let(:member) { create(:member, url: website_url) }

    subject { described_class.call(member) }

    context "when headings are found at the member's website" do
      let(:website_url) { 'https://nokogiri.org' }
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

      before do
        subject
      end

      it { is_expected.to be_success }

      it "extracts and persists H1, H2 and H3 headers from the member's website" do
        member.reload
        expect(member.headings.size).to eq expected_headings.size
        expect(member.headings.ordered.pluck(:text)).to eq expected_headings
      end
    end

    context "when connecting to the website is not possible" do
      let(:website_url) { 'https://no.headers.in.here.com' }
      let(:expected_headings) { [] }

      before do
        subject
      end

      it { is_expected.to be_failure }

      it 'returns the proper error code' do
        expect(subject.error_code).to eq Members::Website::HEADING_EXTRACTION_SERVICE_ERRORS[:connection_failed]
      end
    end

    context "when no headings are found on the  member's website" do
      let(:website_url) { 'https://vulfpeck.com' }
      let(:expected_headings) { [] }

      before do
        subject
      end

      it { is_expected.to be_success }

      it 'no headers are stored' do
        member.reload
        expect(member.headings.size).to eq expected_headings.size
        expect(member.headings.pluck(:text)).to eq expected_headings
      end
    end
  end
end
