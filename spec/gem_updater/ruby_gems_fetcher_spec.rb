require 'spec_helper'

describe GemUpdater::RubyGemsFetcher do
  subject do
    GemUpdater::RubyGemsFetcher.new(
      'gem_name',
      OpenStruct.new(remotes: [URI('https://rubygems.org')])
    )
  end

  describe '#source_uri' do
    before do
      allow(subject).to receive_message_chain(:open, :read) { source_uri.to_json }
    end

    context 'when gem exists on rubygems.org' do
      describe 'making too many requests' do
        before do
          allow(subject).to receive_message_chain(:open) do
            raise OpenURI::HTTPError.new('429', OpenStruct.new(status: ['429']))
          end
          subject.source_uri
        end

        it 'tries again' do
          expect(subject).to have_received(:open).twice
        end
      end

      context "when 'source_code_uri' is present" do
        let(:source_uri) { { source_code_uri: 'source_code_uri' } }

        it "returns 'source_code_uri' value" do
          expect(subject.source_uri).to eq 'source_code_uri'
        end
      end

      context "when 'homepage_uri' is present" do
        let(:source_uri) { { homepage_uri: 'homepage_uri' } }

        it "returns 'homepage_uri' value" do
          expect(subject.source_uri).to eq 'homepage_uri'
        end
      end

      context "when both 'source_code_uri' and 'homepage_uri' are present" do
        let(:source_uri) do
          {
            source_code_uri: 'source_code_uri',
            homepage_uri: 'homepage_uri'
          }
        end

        it "returns 'source_code_uri' value" do
          expect(subject.source_uri).to eq 'source_code_uri'
        end
      end

      context 'when none is present' do
        let(:source_uri) { {} }

        before do
          allow(subject).to receive(:uri_from_other_sources)
          subject.source_uri
        end

        it 'looks in other sources' do
          expect(subject).to have_received(:uri_from_other_sources)
        end
      end

      context 'when both returns empty string' do
        let(:source_uri) do
          {
            source_code_uri: '',
            homepage_uri: ''
          }
        end

        before do
          allow(subject).to receive(:uri_from_other_sources)
          subject.source_uri
        end

        it 'looks in other sources' do
          expect(subject).to have_received(:uri_from_other_sources)
        end
      end
    end

    context 'when gem does not exists on rubygems.org' do
      context 'when they are no other hosts' do
        before do
          allow(subject).to receive(:uri_from_rubygems) { nil }
        end

        it 'returns nil' do
          expect(subject.source_uri).to be_nil
        end
      end

      context 'when they are other hosts' do
        before do
          allow(subject).to receive(:uri_from_rubygems) { nil }
        end

        describe 'looking on rubygems' do
          before do
            allow(subject.source).to receive(:remotes) do
              [URI('https://rubygems.org'), URI('')]
            end
            allow(subject).to receive(:uri_from_other_sources) { nil }
            subject.source_uri
          end

          it 'does it only once' do
            expect(subject).to have_received(:uri_from_rubygems).once
          end
        end

        context 'when gem can be hosted on rails-assets.org' do
          before do
            allow(subject.source).to receive(:remotes) do
              [URI('https://rubygems.org'), URI('https://rails-assets.org')]
            end
          end

          context 'when gem is on rails-assets' do
            before do
              allow(subject).to receive_message_chain(:open, :read) do
                {
                  url: 'git://fake.com/gem_name'
                }.to_json
              end
            end

            it 'returns http url' do
              expect(subject.source_uri).to eq 'http://fake.com/gem_name'
            end
          end

          context 'when gem is not on rails-assets' do
            before do
              allow(subject).to receive_message_chain(:open, :read) do
                "<title>We're sorry, but something went wrong (500)</title>"
              end
            end

            it 'returns nil' do
              expect(subject.source_uri).to be_nil
            end
          end
        end
      end
    end
  end
end
