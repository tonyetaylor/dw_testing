class Tree < ApplicationRecord
  attr_accessor :parent, :children, :test_framework, :description, :structure_marker, :indentation, :file_name, :node_spec_count

  def initialize(description, indentation=0)
    unless description.nil?
      description.gsub! /"/, ''
    end
    @description = description
    @indentation = indentation
    @children = []
    @structure_marker = 'default'
    @node_spec_count = 0
  end

  def title
    @description.split("/")[-1].strip
  end

  def title_sans_suffix
    title.split(".")[0].strip
  end

  def traverse(&block)
    yield self
    @children.each {|child| child.traverse(&block)}
  end

  def to_s(indent=0)
    traverse do |node|
      sub_indent = indent + 3
      if(['describe', 'context', 'feature'].include?(node.structure_marker))
        description = node.description.to_s
        spec_count_of_node = node.spec_count.to_s
        cases_string = node.cases_string(node.spec_count)
        
        return (description + ' ' + spec_count_of_node + cases_string + "\n" + ' ' * sub_indent + node.children.map { |child| ' - ' + child.to_s(sub_indent + 3) }.join("\n" + ' ' * sub_indent))
      else
        description = node.description.to_s

        return (description + node.children.map { |child| " - " + child.to_s(sub_indent + 3) }.join("\n" + ' ' * sub_indent))
      end
    end
  end

  def cases_string(spec_count)
    spec_count == 1 ? ' case' : ' cases'
  end

  def spec_count
    @node_spec_count = 0
    traverse do |node|
      if node.structure_marker == 'it' || node.structure_marker == 'scenario' || node.structure_marker == 'test'
        @node_spec_count += 1
      end
    end
    @node_spec_count
  end

  #find a node or nodes with these three categories (1/9/17): description, structure_marker, file_name. E.g., find_child("login", "description"). NB: The /i is to make the terms case insensitive. 
  def find_child(search_term, category)
    found_nodes = []
    traverse do |node|
      case category
      when "description"
        if node.description =~ /#{Regexp.quote(search_term)}/i
          found_nodes << node
        end
      when "structure_marker"
        if node.structure_marker =~ /#{Regexp.quote(search_term)}/i
          found_nodes << node
        end
      when "file_name"
        #first steps to make search robust; replace whitespace with underscore to mimic file string
        search_term.strip!
        search_term.gsub!(/\s+/, '_')
        if node.file_name =~ /#{Regexp.quote(search_term)}/i
          found_nodes << node
        end
      else
      end
    end
    found_nodes
  end
end #end class Tree