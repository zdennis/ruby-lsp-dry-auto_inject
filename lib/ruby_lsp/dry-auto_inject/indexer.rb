module RubyLsp::DryAutoInject
  class Indexer
    def initialize(directory_path)
      @directory_path = directory_path

      @dependencies_to_resolutions = {}
    end

    def index
      reindex
    end

    def reindex
      STDERR.puts "#{self.class}##{__method__} Looking in directory=#{@directory_path} for Dry::Container::Mixin"
      dependencies_file = Dir["#{@directory_path}/**/*.rb"].find do |file|
        File.read(file).include?("Dry::Container::Mixin")
      end
      STDERR.puts "  found: #{dependencies_file}"

      parse_result = ::Prism.parse_file(dependencies_file)
      AllVisitor.new(self).visit(parse_result.value)
    end

    def add_dependency_resolves_to(dependency_name, resolves_to_name)
      @dependencies_to_resolutions[dependency_name] = resolves_to_name.to_s
    end

    def resolve_dependency(dependency_name)
      @dependencies_to_resolutions[dependency_name.to_s]
    end
  end

  class LookForDependencyRegistrations < Prism::Visitor
    attr_reader :indexer

    def initialize(indexer)
      @indexer = indexer
    end

    def visit(node)
      @root_node = node
      super(node)
    end

    def visit_call_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.name}"
      if node.name.to_s == "register"

        first_argument = node.arguments.compact_child_nodes.first
        dependency_name = case first_argument
          when Prism::StringNode then first_argument.content
          when Prism::SymbolNode then first_argument.value
        end

        dependency_resolves_to = nil

        statements_node = node.block.compact_child_nodes.first
        if dependency_name && statements_node
          child_nodes = statements_node.compact_child_nodes
          first_child_node = child_nodes&.first

          case first_child_node
          when Prism::CallNode
            case first_child_node.receiver
            when Prism::ConstantReadNode
              dependency_resolves_to = first_child_node.receiver.name
            when Prism::ConstantPathNode
              dependency_resolves_to = first_child_node.receiver.full_name
            end
          when Prism::ConstantReadNode
            dependency_resolves_to = first_child_node.name
          when Prism::ConstantPathNode
            dependency_resolves_to = first_child_node.full_name
          end

          if dependency_name && dependency_resolves_to
            STDERR.puts "Mapped #{dependency_name.inspect} to #{dependency_resolves_to}"
            indexer.add_dependency_resolves_to(dependency_name, dependency_resolves_to)
          end
        end
      end
    end
  end

  class ClassVisitor < Prism::Visitor
    attr_reader :indexer, :root_node

    def initialize(indexer)
      @indexer = indexer
      @scope = []
      @look_for_dependency_registrations = false
    end

    def visit(node)
      @root_node = node
      super(node)
    end

    def visit_class_node(node)
      if node == root_node
        @scope << node
        super(node)
      else
        STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.name}"
        ClassVisitor.new(@indexer).visit(node)
      end
    end

    def visit_module_node(node)
      if node == root_node
        @scope << node
        super(node)
      else
        STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.name}"
        ClassVisitor.new(@indexer).visit(node)
      end
    end

    def visit_call_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
      if node.name == :extend
        first_argument = node.arguments.compact_child_nodes&.first
        if first_argument.is_a?(Prism::ConstantPathNode) && first_argument.full_name.to_s == "Dry::Container::Mixin"
          LookForDependencyRegistrations.new(indexer).visit(root_node)
        end
      end
    end

    def visit_constant_and_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_operator_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_path_and_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_path_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_or_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_path_or_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_path_target_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_path_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_read_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_target_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_path_operator_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visiting #{node}: #{node.full_name}"
    end

    def visit_constant_write_node(node)
      STDERR.puts "#{self.class}##{object_id} visit #{node}: #{node.full_name}"
    end
  end

  class AllVisitor < Prism::Visitor
    attr_reader :index, :scope

    def initialize(indexer)
      @indexer = indexer
    end

    def visit_call_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_call_and_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_call_operator_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_call_or_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_call_target_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_class_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
      ClassVisitor.new(@indexer).visit(node)
    end

    def visit_module_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
      ClassVisitor.new(@indexer).visit(node)
    end

    def visit_constant_and_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_operator_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_or_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_path_and_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_path_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_path_operator_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_path_or_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_path_target_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_path_write_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_read_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_target_node(node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

    def visit_constant_write_node  (node)
      STDERR.puts "#{self.class} visiting #{node}: #{node.name}"
    end

  end
end
