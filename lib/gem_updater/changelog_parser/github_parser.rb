# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

module GemUpdater
  class ChangelogParser
    # ChangelogParser is responsible for parsing a changelog hosted on github.
    class GithubParser
      MARKDOWN_HEADING_PATTERN = /^#+\s+(.*?)$/
      RDOC_HEADING_PATTERN = /^===\s+(.*?)$/

      attr_reader :uri, :version

      # @param uri [String] changelog uri
      # @param version [String] version of gem
      def initialize(uri:, version:)
        @uri     = uri
        @version = version
      end

      # Finds anchor in changelog, otherwise return the base uri.
      #
      # @return [String] the URL of changelog
      def changelog
        anchor = find_anchor_from_raw_content
        anchor ? "#{uri}##{anchor}" : uri
      end

      private

      # Fetches raw markdown/RDoc content and finds anchor for the version
      #
      # @return [String, nil] anchor if found
      def find_anchor_from_raw_content
        raw_url = raw_content_url
        return unless raw_url

        begin
          content = URI.parse(raw_url).read
          parse_headings(content)
        rescue OpenURI::HTTPError
          nil
        end
      end

      # Extracts raw content URL from GitHub's X-Raw-Download response header
      #
      # @return [String] raw content URL
      def raw_content_url
        response = URI.parse(uri).open
        response.meta['x-raw-download']
      end

      # Parses markdown/RDoc content to find heading matching the version
      #
      # @param content [String] raw markdown/RDoc content
      # @return [String, nil] anchor if found
      def parse_headings(content)
        heading_patterns = [MARKDOWN_HEADING_PATTERN, RDOC_HEADING_PATTERN]

        content.each_line do |line|
          heading_text = heading_patterns.each do |pattern|
            break Regexp.last_match(1).strip if line.match(pattern)
          end
          heading_text = nil if heading_text.is_a?(Array)

          next unless heading_text&.match?(version)

          return generate_github_anchor(heading_text)
        end
        nil
      end

      # Generates GitHub-style anchor from heading text
      #
      # @param heading_text [String] the heading text
      # @return [String] GitHub-style anchor
      def generate_github_anchor(heading_text)
        # GitHub's anchor generation algorithm:
        # 1. Convert to lowercase
        # 2. Remove dots
        # 3. Replace / with --
        # 4. Replace em dashes with ---
        # 5. Remove special characters except letters (including accented), numbers, hyphens, spaces
        # 6. Replace spaces with hyphens
        # 7. Remove leading/trailing hyphens
        anchor = heading_text
                 .downcase
                 .delete('.')
                 .gsub(%r{\s*/\s*}, '--')
                 .gsub(/—/, '---') # Replace em dash with three hyphens
                 .gsub(/[^\p{L}0-9\-\s]/, '') # Keep all Unicode letters including accented
                 .gsub(/\s+/, '-')
                 .sub(/^-|-$/, '')

        anchor.empty? ? nil : anchor
      end
    end
  end
end
