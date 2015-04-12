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

  describe '#initialize' do
    context 'when url is standard' do
      it 'returns it' do
        expect( GemUpdater::SourcePageParser.new( url: 'http://example.com', version: 1 ).instance_variable_get :@uri ).to eq URI( 'http://example.com' )
      end
    end

    context 'when url is on github' do
      context 'when url is https' do
        it 'returns it' do
          expect( GemUpdater::SourcePageParser.new( url: 'https://github.com/fake_user/fake_gem', version: 1 ).instance_variable_get :@uri ).to eq URI( 'https://github.com/fake_user/fake_gem' )
        end
      end

      context 'when url is http' do
        context 'when url host is github' do
          it 'returns https version of it' do
            expect( GemUpdater::SourcePageParser.new( url: 'http://github.com/fake_user/fake_gem', version: 1 ).instance_variable_get :@uri ).to eq URI( 'https://github.com/fake_user/fake_gem' )
          end

          context 'when url host is a subdomain of github' do
            it 'returns https version of base domain' do
              expect( GemUpdater::SourcePageParser.new( url: 'http://wiki.github.com/fake_user/fake_gem', version: 1 ).instance_variable_get :@uri ).to eq URI( 'https://github.com/fake_user/fake_gem' )
            end
          end
        end
      end
    end
  end
end
