# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'
require 'sidekiq/testing'
require_relative '../../../support/helpers/api/v1/authorization'

resource 'Friendship' do
  include Helpers::Api::V1

  let(:user) { FactoryBot.create(:user) }
  let(:bearer_token) { jwt_bearer_token(user) }
  let(:raw_post) { params.to_json }

  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :bearer_token

  post '/api/v1/friendships' do
    let(:member) { create(:member) }
    let(:other_member) { create(:member) }

    with_options scope: :data, with_example: true do
      parameter :member_name, 'The name of the Member', required: true
      parameter :friend_name, 'The name of the Friend', required: true
    end

    context '201' do
      let(:payload) do
        {
          data: {
            type: 'friendship',
            attributes: {
              member_name: member.name,
              friend_name: other_member.name
            }
          }
        }
      end

      before do
        member
        other_member
      end

      example 'Make friends' do
        do_request(payload)
        expect(status).to eq 201
      end
    end

    context '422' do
      let(:bad_payload) do
        {
          data: {
            type: 'friendship',
            attributes: {
              member_name: 'foo',
              friend_name: 'bar'
            }
          }
        }
      end
      let(:expected_response) do
        {
          errors: [
            {
              code: '200',
              detail: "Unable to find member: foo",
              status: 'unprocessable_entity',
              title: "Friendship creation failed"
            }
          ]
        }
      end

      example 'Member not found' do
        do_request(bad_payload)
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 422
      end
    end
  end
end
