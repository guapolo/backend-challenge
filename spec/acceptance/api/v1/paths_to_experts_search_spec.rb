# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation/dsl'
require 'sidekiq/testing'
require_relative '../../../support/helpers/api/v1/authorization'

resource 'api/v1/paths_to_experts_search', :vcr do
  include Helpers::Api::V1

  let(:user) { FactoryBot.create(:user) }
  let(:bearer_token) { jwt_bearer_token(user) }
  let(:raw_post) { params.to_json }

  explanation 'Member management'

  header 'Accept', 'application/vnd.api+json'
  header 'Content-Type', 'application/json'
  header 'Authorization', :bearer_token

  post '/api/v1/paths_to_experts_search' do
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
    let(:topic) { 'voice-over' }

    before do
      Sidekiq::Testing.fake!
      do_friends
      Sidekiq::Worker.drain_all
      members.each { |m| m.reload }
    end

    with_options scope: :data, with_example: true do
      parameter :member_name, 'The name of the Member', required: true
      parameter :topic, 'Topic for the search', required: true
    end

    context '200' do
      let(:payload) do
        {
          data: {
            type: 'member_topic',
            attributes: {
              member_name: rick.name,
              topic: topic
            }
          }
        }
      end
      let(:expected_response) do
        {
          data: {
            type: 'path_to_expert',
            attributes: {
              paths: [["Rick Sanchez", "Morty Smith", "Jessica"]],
              topic: topic
            }
          }
        }
      end

      example 'Create a Member' do
        do_request(payload)
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 200
      end
    end

    context '404' do
      let(:bad_payload) do
        {
          data: {
            type: 'member_topic',
            attributes: {
              member_name: 'Mr. Goldenfold',
              topic: topic
            }
          }
        }
      end
      let(:expected_response) do
        {
          errors: [
            {
              code: '101',
              detail: "Unable to find member.",
              status: 'not_found',
              title: "Member not found"
            }
          ]
        }
      end

      example 'Returns an error' do
        do_request(bad_payload)
        expect(response_body).to include_json(expected_response)
        expect(status).to eq 404
      end
    end

    context '422' do
      let(:bad_payload) do
        {
          data: {
            type: 'member_topic',
            attributes: {
              member_name: rick.name,
              topic: nil
            }
          }
        }
      end
      let(:expected_response) do
        {
          errors: [
            {
              code: '300',
              detail: "Topic is missing.",
              status: 'unprocessable_entity',
              title: "Invalid search payload"
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
end
