require_relative 'lib/ancestors_visualization/version'

Gem::Specification.new do |spec|
  spec.name          = "ancestors_visualization"
  spec.version       = AncestorsVisualization::VERSION
  spec.authors       = ["tommy-012"]
  spec.email         = ["lonnlilonn@googlemail.com"]

  spec.homepage      = 'https://github.com/tommy-012/ancestors_visualization'
  spec.summary       = 'ancestors-relationship diagram for the gem.'
  spec.description   = 'Automatically generate an ancestors-relationship diagram for the gem.'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'timecop'

  spec.add_runtime_dependency 'choice' # NOTE https://github.com/defunkt/choice
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'ruby-graphviz'
end
