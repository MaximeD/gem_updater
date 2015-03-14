require 'spec_helper'

describe GemUpdater::SourcePageParser do
  subject { GemUpdater::SourcePageParser.new( url: 'https://github.com/fake_user/fake_gem', version: '0.2' ) }

  describe '#changelog' do
    context 'when gem is hosted on github' do
      context 'when there is no changelog' do
        before do
          allow( subject ).to receive( :open ) { github_gem_without_changelog }
        end

        it 'is nil' do
          expect( subject.changelog ).to be_nil
        end
      end

      context 'when changelog is in raw text' do
        before do
          allow( subject ).to receive( :open ) { github_gem_with_raw_changelog }
        end

        it 'returns url of changelog' do
          expect( subject.changelog ).to eq 'https://github.com/fake_user/fake_gem/blob/master/changelog.txt'
        end
      end

      context 'when changelog may contain anchor' do
        before do
          allow( subject ).to receive( :open ).with( URI( "https://github.com/fake_user/fake_gem" ) ) { github_gem_with_changelog_with_anchor }
          allow_any_instance_of( GemUpdater::SourcePageParser::GitHubParser ).to receive( :open ).with( "https://github.com/fake_user/fake_gem/blob/master/changelog.md" ) { github_changelog }
        end

        it 'returns url of changelog with anchor to version' do
          expect( subject.changelog ).to eq 'https://github.com/fake_user/fake_gem/blob/master/changelog.md#02'
        end
      end
    end
  end
end
