# frozen_string_literal: true

module Spec
  module Helpers
    def fake_web_dir
      '../fake_web'
    end

    def github_gem_without_changelog
      File.open File.expand_path("#{fake_web_dir}/no_changelog.html", __FILE__)
    end

    def github_gem_with_raw_changelog
      File.open File.expand_path("#{fake_web_dir}/raw_changelog.html", __FILE__)
    end

    def github_gem_with_changelog_with_anchor
      File.open File.expand_path("#{fake_web_dir}/changelog_with_anchor.html", __FILE__)
    end

    def github_changelog
      File.open File.expand_path("#{fake_web_dir}/changelog.html", __FILE__)
    end
  end
end
