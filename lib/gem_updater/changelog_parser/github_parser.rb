# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'

module GemUpdater
  class ChangelogParser
    # ChangelogParser is responsible for parsing a changelog hosted on github.
    class GithubParser
      REACT_DATA_XPATH = '//script[@data-target="react-app.embeddedData"]'
      REACT_PAYLOAD_TOC_PATH = %w[payload blob headerInfo toc].freeze

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
        uri + find_anchor(document).to_s
      end

      private

      # Opens changelog url and parses it.
      #
      # @return [Nokogiri::HTML4::Document] the changelog
      def document
        Nokogiri::HTML(URI.parse(uri).open, nil, Encoding::UTF_8.to_s)
      end

      # Looks into document to find it there is an anchor to new gem version.
      #
      # @param doc [Nokogiri::HTML4::Document] document
      # @return [String, nil] anchor's href
      def find_anchor(doc)
        react_data = doc.at_xpath(REACT_DATA_XPATH)
        return unless react_data

        react_content = JSON.parse(react_data.text)
        anchor = react_content
                 .dig(*REACT_PAYLOAD_TOC_PATH).to_a
                 .find { |item| item['text'].match(version) }&.[]('anchor')
        return unless anchor

        "##{anchor}"
      end
    end
  end
end
