require 'asciidoctor/extensions'
require 'i18n'

module Asciinurse
  module Locale
    class LocaleProcessor < Asciidoctor::Extensions::DocinfoProcessor

      use_dsl
      at_location :header

      def process(document)
        locale = document.attributes['locale']
        I18n.load_path = Asciinurse.find 'i18n/*.yml'
        I18n.backend.load_translations
        I18n.locale = locale
        I18n.t('document').each do |key, translation|
          document.attributes[key.to_s] = translation
        end
        nil
      end

    end

    class LocaleBlock < Asciidoctor::Extensions::BlockMacroProcessor

      use_dsl
      named :locale

      def process(parent, target, attrs)
        I18n.load_path = Asciinurse.find 'i18n/*.yml'
        I18n.backend.load_translations
        I18n.locale = target
        document = parent.document
        I18n.t('document').each do |key, translation|
          document.attributes[key.to_s] = translation
        end
        nil
      end

    end

  end
end

Asciidoctor::Extensions.register do |registry|
  registry.docinfo_processor Asciinurse::Locale::LocaleProcessor
  registry.block_macro Asciinurse::Locale::LocaleBlock
end
