lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'act_form/version'

Gem::Specification.new do |spec|
  spec.name          = 'act_form'
  spec.version       = ActForm::VERSION
  spec.authors       = ['zires']
  spec.email         = ['zshuaibin@gmail.com']

  spec.summary       = 'A simple way to create form/command/service objects.'
  spec.description   = 'The simple way to create form objects or command/service objects with ActiveModel.'
  spec.homepage      = 'https://github.com/simple-and-powerful/act-form'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activemodel', '>= 5.0.0'
  spec.add_runtime_dependency 'dry-schema', '>= 1.13.4'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
end
