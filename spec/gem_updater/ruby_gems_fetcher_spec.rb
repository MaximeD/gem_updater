require 'spec_helper'

describe GemUpdater::RubyGemsFetcher do
  subject { GemUpdater::RubyGemsFetcher.new( 'gem_name' ) }

  describe '#source_uri' do
    context "when 'source_code_uri' is present" do
      before do
        allow( subject ).to receive_message_chain( :open, :read ) { { source_code_uri: 'source_code_uri' }.to_json }
        subject.source_uri
      end

      it "returns 'source_code_uri' value" do
        expect( subject.source_uri ).to eq 'source_code_uri'
      end
    end

    context "when 'homepage_uri' is present" do
      before do
        allow( subject ).to receive_message_chain( :open, :read ) { { homepage_uri: 'homepage_uri' }.to_json }
        subject.source_uri
      end

      it "returns 'homepage_uri' value" do
        expect( subject.source_uri ).to eq 'homepage_uri'
      end
    end

    context "when both 'source_code_uri' and 'homepage_uri' are present" do
      before do
        allow( subject ).to receive_message_chain( :open, :read ) { { source_code_uri: 'source_code_uri', homepage_uri: 'homepage_uri' }.to_json }
        subject.source_uri
      end

      it "returns 'source_code_uri' value" do
        expect( subject.source_uri ).to eq 'source_code_uri'
      end
    end

    context 'none is present' do
      before do
        allow( subject ).to receive_message_chain( :open, :read ) { {}.to_json }
        subject.source_uri
      end

      it 'is falsey' do
        expect( subject.source_uri ).to be_falsey
      end
    end
  end
end
