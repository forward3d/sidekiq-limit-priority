module Sidekiq
  class Client
    class << self
      
      def enqueue_to_with_priority(priority, queue, klass, *args)
        queue = "#{queue}#{Sidekiq::LimitFetch.priority_key_boundary}#{priority}"
        klass.client_push('class' => klass, 'args' => args, 'queue' => queue)
      end

      def enqueue_to_in_with_priority(priority, queue, interval, klass, *args)
        int = interval.to_f
        now = Time.now.to_f
        ts = (int < 1_000_000_000 ? now + int : int)

        queue = "#{queue}_#{priority}"

        item = { 'class' => klass, 'args' => args, 'at' => ts, 'queue' => queue }
        item.delete('at'.freeze) if ts <= now

        klass.client_push(item)
      end
      
    end
  end
end
