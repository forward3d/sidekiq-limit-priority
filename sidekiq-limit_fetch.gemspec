Gem::Specification.new do |gem|
  gem.name          = 'sidekiq-limit_fetch'
  gem.version       = '3.1.0'
  gem.license       = 'MIT'
  gem.authors       = ['brainopia','Sub# Gupta']
  gem.email         = ['brainopia@evilmartians.com', 'reliablendn@gmail.com']
  gem.summary       = 'Sidekiq strategy to support queue limits and strict prirotiy within a queue.'
  gem.homepage      = 'https://github.com/forward3d/sidekiq-limit-priority'
  gem.description   = <<-DESCRIPTION
    Sidekiq strategy to restrict number of workers
    which are able to run specified queues simultaneously
    and ability to submit jobs with priority
  DESCRIPTION

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep %r{^spec/}
  gem.require_paths = ['lib']

  gem.add_dependency 'sidekiq', '>= 4'
  gem.add_development_dependency 'redis-namespace', '~> 1.5', '>= 1.5.2'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
end
