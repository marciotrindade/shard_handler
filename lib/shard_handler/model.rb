require 'active_record'

module ShardHandler
  # This is an abstract model that adds sharding capabilities on ActiveRecord.
  # When you need to query different shards using the same model, you must
  # inherit from this class and configure it.
  #
  # @example
  #   class Post < ShardHandler::Model
  #   end
  #
  #   Post.setup({
  #     'shard1' => {
  #       'adapter' => 'postgresql',
  #       'database' => 'shard_handler_development',
  #       'username' => 'postgres',
  #       'password' => ''
  #     }
  #   })
  #
  #   Post.using(:shard1) do
  #     Post.update_all(title: 'foo')
  #   end
  class Model < ActiveRecord::Base
    self.abstract_class = true

    class << self
      # @api private
      # @return [Handler]
      def handler
        @@handler
      end

      # This method creates an instance of {Handler} for this class. This method
      # must be called before performing any query on shards.
      #
      # @param config [Hash] a hash with database connection settings
      def setup(config)
        @@handler = Handler.new(self, config)
        @@handler.setup
      end

      # Returns the current shard name for the current Thread.
      #
      # @return [Symbol]
      def current_shard
        ThreadRegistry.current_shard
      end

      # Sets the current shard name for the current Thread.
      #
      # @param name [Symbol, String] shard name configured using {.setup}
      def current_shard=(name)
        ThreadRegistry.current_shard = name.nil? ? nil : name.to_sym
      end

      # Overrides ActiveRecord::Core#connection_handler method to return the
      # appropriate ConnectionHandler for the current shard. This is the
      # integration point between ActiveRecord and this gem.
      #
      # @api private
      # @return (see Handler#connection_handler_for)
      def connection_handler
        return super if use_master_connection?

        unless defined?(@@handler)
          fail(SetupError, 'the model was not setup')
        end

        @@handler.connection_handler_for(current_shard)
      end

      # This method will switch to the passed shard making all queries be
      # executed using the shard connection.
      #
      # @param shard [Symbol, String] shard name configured using .setup
      # @yield The block that must be executed using the shard connection
      def using(shard)
        old_shard = current_shard
        self.current_shard = shard
        yield
      ensure
        # Returns any connections in use back to the pool. It is executed only
        # if the shard name is different from the old one because one can call
        # .using multiple times in a chain, like this:
        #
        #   using(:shard1) do
        #     using(:shard1) do
        #     end
        #   end
        self.clear_active_connections! if old_shard != current_shard
        self.current_shard = old_shard
      end

      private :establish_connection

      protected

      def use_master_connection?
        current_shard.nil?
      end
    end
  end
end
