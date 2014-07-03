require_relative '../../spec_helper'
require_relative '../../../app/models/connection'
require 'ostruct'

describe ConnectionCollection do
  describe "#find_connection" do
    subject { collection.find_connection(query) }
    let(:collection) { ConnectionCollection.new }
    context "with connection as query" do
      let(:connection) { Connection.new(Object.new) }
      let(:query) { connection }
      it { is_expected.to be connection }
    end
    context "with an email address as query" do
      let(:query) { "some@email.com" }
      context "when recipient does not exist" do
        it { is_expected.to be_a NoConnection }
      end
      context "when recipient does exist" do
        let(:session) { OpenStruct.new({user_email: "some@email.com"}) }
        let(:connection) { Object.new }
        before do
          collection.register_session(session: session, connection: connection)
        end
        it { is_expected.to be connection }
      end
    end
  end
end

describe NoConnection do
  describe '#queue_message' do
    let(:connection) { NoConnection.new }
    it "accepts the message, does nothing with it" do
      expect { connection.queue_message("Some message") }.to_not raise_error
    end
  end
end
