# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'
require 'sidekiq/testing'
require_relative '../../../support/helpers/api/v1/authorization'

resource 'api/v1/member' do
  include Helpers::Api::V1

  let(:user) { FactoryBot.create(:user) }
  let(:bearer_token) { jwt_bearer_token(user) }
  let(:raw_post) { params.to_json }

  explanation 'Member management'

  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :bearer_token

  post '/api/v1/members' do
    let(:name) { 'Rick Sanchez' }
    let(:url) { 'https://dimension-c-137.org/rick-sanchez' }

    with_options scope: :data, with_example: true do
      parameter :name, 'The name of the Member', required: true
      parameter :url, 'The website URL of the Member', required: true
    end

    context '201' do
      let(:payload) do
        {
          data: {
            type: 'member',
            attributes: {
              name: name,
              url: url
            }
          }
        }
      end
      let(:expected_response) do
        {
          data: {
            type: 'member',
            attributes: {
              friends_count: 0,
              name: name,
              short_url: nil,
              url: url
            }
          }
        }
      end

      example 'Create a Member' do
        do_request(payload)
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 201
      end
    end

    context '422' do
      let(:bad_payload) do
        {
          data: {
            type: 'member',
            attributes: {
              name: name
            }
          }
        }
      end
      let(:expected_response) do
        {
          errors: [
            {
              code: '100',
              detail: "Url can't be blank, Url is not a valid URL",
              status: 'unprocessable_entity',
              title: "Member creation failed"
            }
          ]
        }
      end

      example 'Returns an error' do
        do_request(bad_payload)
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 422
      end
    end
  end

  get '/api/v1/members/:id' do
    let(:member) { create(:member, url: 'https://nokogiri.org') }
    let(:other_member) { create(:member, url: 'https://www.ruby-lang.org') }
    let(:yet_another_member) { create(:member, url: 'https://guides.rubyonrails.org') }
    let(:member_creation) do
      Sidekiq::Testing.fake!
      Sidekiq::Worker.clear_all

      member
      member.friends << other_member
      member.friends << yet_another_member

      Sidekiq::Worker.drain_all
      member.reload
    end

    with_options scope: :data, with_example: true do
      parameter :id, 'The member\'s UUID', required: true
    end

    context '200', :vcr do
      let(:expected_response) do
        {
          data: {
            id: member.id,
            type: 'member',
            attributes: {
              friends_count: member.friends.size,
              friends_pages: member.friends.pluck(:url),
              headings: member.headings.pluck(:text),
              name: member.name,
              short_url: member.short_url,
              url: member.url
            }
          }
        }
      end

      before do
        member_creation
      end

      example 'Display member information' do
        do_request(id: member.id)
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 200
      end
    end

    context '404' do
      let(:expected_response) do
        {
          errors: [
            {
              code: '101',
              detail: "Unable to find member.",
              status: 'not_found',
              title: 'Member not found'
            }
          ]
        }
      end

      example 'Returns an error' do
        do_request(id: 'foo')
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 404
      end
    end
  end
end
