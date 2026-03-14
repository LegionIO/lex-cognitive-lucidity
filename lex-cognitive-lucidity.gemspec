# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_lucidity/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-lucidity'
  spec.version       = Legion::Extensions::CognitiveLucidity::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Cognitive Lucidity'
  spec.description   = 'Lucid dreaming for AI — self-aware dream processing with lucidity levels, ' \
                       'reality testing, dream steering, and false awakening detection'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-lucidity'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-lucidity'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-lucidity'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-lucidity'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-lucidity/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
end
