require 'forwardable'
require 'sidekiq'
require 'sidekiq/manager'
require 'sidekiq/api'
require 'sidekiq/client'
require_relative 'client_ext'

module Sidekiq::LimitFetch
  autoload :UnitOfWork, 'sidekiq/limit_fetch/unit_of_work'

  require_relative 'limit_fetch/instances'
  require_relative 'limit_fetch/queues'
  require_relative 'limit_fetch/global/semaphore'
  require_relative 'limit_fetch/global/selector'
  require_relative 'limit_fetch/global/monitor'
  require_relative 'extensions/queue'
  require_relative 'extensions/manager'

  extend self

  def new(_)
    self
  end

  def retrieve_work
    queue, job = redis_brpop *Queues.acquire
    Queues.release_except(queue)
    UnitOfWork.new(queue, job) if job
  end

  def bulk_requeue(*args)
    Sidekiq::BasicFetch.bulk_requeue(*args)
  end

  def priority_key_boundary
    '_priority_'
  end

  private

  def prioritized_queues(queues)
    queues.map do |queue|
      Sidekiq::LimitFetch::Queues.priorities.empty? ? queue
      : Sidekiq::LimitFetch::Queues.priorities.map { |priority| "#{queue}#{priority_key_boundary}#{priority}"}
    end.flatten
  end
  
  def original_queue(queue)
    return queue unless queue
    queue.split(priority_key_boundary)[0]
  end
  
  def redis_brpop(*args)
    return if args.size < 2
    queues = prioritized_queues(args)
    queue, job = Sidekiq.redis {|it| it.brpop *[queues, Sidekiq::BasicFetch::TIMEOUT].flatten }
    queue = original_queue(queue)
    [queue, job]
  end
end
