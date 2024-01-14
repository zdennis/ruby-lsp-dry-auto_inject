require "ruby_lsp/listeners/definition"

module RubyLsp
  module DryAutoInject
    class DefinitionListener < ::RubyLsp::Listeners::Definition
      attr_accessor :dry_auto_inject_indexer

      sig { params(node: Prism::CallNode).void }
      def on_call_node_enter(node)
        STDERR.puts "#{__FILE__} #{__method__}: #{node.name} receiver: #{node.inspect}"

        dependency_name = case node.receiver
          when Prism::LocalVariableReadNode
            node.receiver.name
          when nil
            node.name
          end

        if dependency_name
          resolved_to = dry_auto_inject_indexer.resolve_dependency(dependency_name)
          STDERR.puts "RESOLVED #{dependency_name} to #{resolved_to}"

          STDERR.puts "LOOKING IN INDEX: #{resolved_to.inspect}"
          if resolved_to
            @_response = find_in_index(resolved_to).tap do |result|
              STDERR.puts "FOUND IN INDEX: #{result.inspect}"
            end
          end
        end
      end
    end
  end
end

STDERR.puts 'Loaded definition'
