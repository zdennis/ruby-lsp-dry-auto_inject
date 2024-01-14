require "ruby_lsp/addon"

module RubyLsp
  module DryAutoInject
    class Addon < ::RubyLsp::Addon
      extend T::Sig

      # Performs any activation that needs to happen once when the language server is booted
      sig { override.params(message_queue: Thread::Queue).void }
      def activate(message_queue)
        require_relative "definition_listener"
        require_relative "indexer"

        @indexer ||= RubyLsp::DryAutoInject::Indexer.new(Dir.pwd)
        @indexer.reindex
      end

      # Performs any cleanup when shutting down the server, like terminating a subprocess
      sig { override.void }
      def deactivate
      end

      # Returns the name of the addon
      sig { override.returns(String) }
      def name
        "Ruby LSP My Gem"
      end

      # Creates a new Definition listener. This method is invoked on every Definition request
      sig do
        overridable.params(
          uri: URI::Generic,
          nesting: T::Array[String],
          index: RubyIndexer::Index,
          dispatcher: Prism::Dispatcher,
        ).returns(T.nilable(Listener[T.nilable(T.any(T::Array[Interface::Location], Interface::Location))]))
      end
      def create_definition_listener(uri, nesting, index, dispatcher)
        STDERR.puts "#{__FILE__} #{__method__}"
        ::RubyLsp::DryAutoInject::DefinitionListener.new(uri, nesting, index, dispatcher, false).tap do |listener|
          listener.dry_auto_inject_indexer = @indexer
          STDERR.puts "listener: #{listener}"
        end
      end
    end
  end
end
