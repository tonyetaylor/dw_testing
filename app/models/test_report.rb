class TestReport < ApplicationRecord
  attr_accessor :file_name, :test_framework, :stack, :test_nodes, :root, :test_case_stack

  @@java_features = ['Carrier Feeds', 'Payroll', 'Auto Sync']
  @@go_features = ['Metrics Queue', 'Accounts', 'Bifrost', 'Heimdall']
  @@csharp_features = ['Benefits ACA']
  @@all_features = ['HCM-unit', 'HCM-feature', 'Permissions', 'HAT/Cortana', 'API', 'Carrier Feeds', 'Payroll', 'Auto Sync', 'Benefits ACA', 'NetGRPC', 'Metrics Queue', 'Accounts', 'Bifrost', 'Paycheck', 'Heimdall', 'Apollo']

  def self.java_features
    @@java_features
  end

  def self.csharp_features
    @@csharp_features
  end

  def self.all_features
    @@all_features
  end

  def self.go_features
    @@go_features
  end
  
  def initialize(file_name, test_framework='automated')
    @test_nodes = []
    @file_name = file_name
    @test_framework = test_framework
    @stack = []
    #special stack for C# parsing
    @test_case_stack = []
    @root = Tree.new(file_name, -1)
    @root.file_name = file_name
    @root.test_framework = test_framework
    @root.structure_marker = 'root'
  end

  def format_description(line, first_token)
    token_line = line.chomp.strip.split
    #for one-liner 'it' specs that end in }
    token_line_rare = line.chomp.strip.split('')
    if(token_line_rare[-1] == '}' || first_token == 'feature' || first_token == 'scenario')
      return token_line.tap {|tl| tl.slice!(0)}.join(' ') 
    elsif token_line.size < 3
      #account for unlabeled structure markers
      if first_token == 'feature' || first_token == 'scenario' || first_token == 'context'
        return first_token
      else
        return "unlabeled test case"
      end
    else
      return token_line.tap {|tl| tl.slice!(0); tl.slice!(-1)}.join(' ')
    end
  end

  def format_java_description(line)
    stripped_line = line.strip
    return "unlabeled test case" if (stripped_line.nil? || stripped_line.empty?)
    token_line = stripped_line.downcase.split
    first_token = token_line[0]
    second_token = token_line[1]
    third_token = token_line[2]
    first_token == 'package' ? second_token : third_token
  end

  #handles RSpec, Cucumber, Java, C# files, and Go files
  def fetch_parent(stack, node)
    stack_2 = []
    while !stack.empty?
      potential_parent = stack.pop
      potential_structure_marker = potential_parent.structure_marker.to_s.strip
      if is_parent?(potential_structure_marker, node.indentation, potential_parent.indentation)
        parent = potential_parent
        stack_2.push(parent)
        while !stack_2.empty?
          elem = stack_2.pop
          stack.push(elem)
        end
        return parent
      else
        stack_2.push(potential_parent)
      end
    end
  end

  def is_parent?(potential_parent_structure_marker, node_indentation, potential_parent_indentation)
    top_level_markers = ['root', 'feature', 'java_class', 'package', 'namespace', 'test_fixture']
    mid_level_markers = ['describe', 'context', 'c_sharp_class', 'func', 't.Run', ]
    (top_level_markers.include?(potential_parent_structure_marker)) || ( (mid_level_markers.include?(potential_parent_structure_marker)) && (node_indentation > potential_parent_indentation) )
  end

  def debug_output
    puts "stack size : #{@stack.size}"
    puts "stack contents: #{@stack.map(&:title)}"
    puts "how many children 0 : #{@stack[0].children.size if @stack[0]}"
    puts "how many children 1 : #{@stack[1].children.size if @stack[1]}"
    puts "stack1 children contents: #{@stack[1].children.map(&:title) if @stack[1]}"
    puts "stack2 children contents: #{@stack[2].children.map(&:title) if @stack[2]}"
  end

  #a stack is necessary to properly assign the parent node; this method is appropriate for RSpec/Cucumber specifications 
  def create_test_node
    parent = @root
    File.open(@file_name, "r") do |f|
      f.each_with_index do |line, index|
        
        if index == 0
          @stack = []
          @stack.push(@root)
        end
        line.chomp!
        next if line.empty? || line.nil?
        prelim_whitespace = 0
        line.each_byte do |byte|
          break if byte != 32
          prelim_whitespace += 1
        end
        stripped_line = line.strip
        next if stripped_line.nil? || stripped_line.empty?
        token_line = stripped_line.split
        #accounts for Cucumber colons
        first_token = token_line[0].gsub(/:/,' ').downcase.strip
        last_token = token_line[-1].strip

        case stripped_line
        when /^context/, /^describe/, /^Feature:/, /^Feature/, /^RSpec.describe/
          node = Tree.new(format_description(line, first_token), prelim_whitespace)
          node.file_name = @file_name
          parent = fetch_parent(@stack, node)
          if parent
            parent.children << node
            node.parent = parent
          end
          node.structure_marker = first_token
          
          @stack.push(node)
        when /^it/, /^Scenario/, /^Scenario:/
          node = Tree.new(format_description(line, first_token), prelim_whitespace)
          node.file_name = @file_name
          parent = fetch_parent(@stack, node)
          if parent
            parent.children << node
            node.parent = parent
          end
          node.structure_marker = first_token
          
          if stripped_line =~ /do$/
            @stack.push(node)
          end
        when /^def/, /do$/, /do.*$/
          node = Tree.new(first_token, prelim_whitespace)
          node.file_name = @file_name
          node.structure_marker = first_token
          
          @stack.push(node)
        when /^end/
          @stack.pop
        else
        end
      end
    end
    @root
  end

  def create_go_test_node
    #Algorithm
    # if package, it's under root, goes on stack
    # if func and starts with Test, and lookahead is func, don't put on stack
    # if func and starts with Test and lookahead is t.Run, put on stack as parent.
    # t.Runs can be scenario or its depending on indentation, so must save indentation
    @stack = []
    @stack.push(@root)
    go_regex = Regexp.union([/^package/, /^func/, /^t\.Run/, /^scenario:/, /^Convey/])
    original_file_string = File.read(@file_name)
    lines = original_file_string.split("\n")
    prelim_whitespace_hash = Hash.new
    lines = lines.each do |line|
      #separate description from marker
      line.gsub!(/\(/," ") 
      line.gsub!(","," ")
      next if line.empty? || line.nil?
      prelim_whitespace = 0
      line.each_byte do |byte|
        case byte
        when 32 
          prelim_whitespace +=1
        when 9
          prelim_whitespace +=2
        else
          break
        end
      end
      line.strip!
      prelim_whitespace_hash[line] = prelim_whitespace
    end
    relevant_lines_ary = lines.keep_if do |line|
      !go_regex.match(line).nil? && line !=""
    end
    relevant_lines_ary << nil
    relevant_lines_ary.each_cons(2) do |line, nekst|
      case line
      when /^package/
        description = line.split[1]
        node = Tree.new(description, prelim_whitespace_hash[line])
        node.file_name = @file_name
        node.structure_marker = 'package'
        parent = fetch_parent(@stack, node)
        if parent
          parent.children << node
          node.parent = parent
        end
        @stack.push(node)
      when /^func/
        description = line.split[1]
        node = Tree.new(description, prelim_whitespace_hash[line])
        node.file_name = @file_name
        parent = fetch_parent(@stack, node)
        if parent
          parent.children << node
          node.parent = parent
        end
        node.structure_marker = 'func'
        @stack.push(node)
      when /^t\.Run/, /scenario:/, /^Convey/
        if line.match(/".*?"/)
          description = line.match(/".*?"/)[0]
        else 
          description = "unlabeled test case(s)"
        end
        node = Tree.new(description, prelim_whitespace_hash[line])
        node.file_name = @file_name
        parent = fetch_parent(@stack, node)
        if parent
          parent.children << node
          node.parent = parent
        end
        node.structure_marker = 'test'
        if nekst.nil?
          break
        else
          line_indentation = prelim_whitespace_hash[line]
          nekst_indentation = prelim_whitespace_hash[nekst]
          if nekst_indentation > line_indentation 
            node.structure_marker = 'describe'
            @stack.push(node)
          elsif nekst_indentation == line_indentation 
            node.structure_marker = 'test'
          else
            node.structure_marker = 'test'
            @stack.pop
          end
        end
      else
      end
    end
    @root
  end

  #this method parses C# files; define tokens within if/else to account for possible nils
  def create_csharp_test_node
    @stack = []
    @stack.push(@root)
    @test_case_stack = []
    csharp_regex = Regexp.union([/^namespace/, /^public/, /^\[TestFixture\]/, /^\[Test\]/, /^\[TestCase/])
    original_file_string = File.read(@file_name)
    lines = original_file_string.split("\n")
    lines = lines.each do |line|
      line.gsub!("()","") 
      line.gsub!(";","")
      line.gsub!("async","") 
      line.gsub!("Task","")
      line.gsub!("void","")
      line.gsub!("class","")
      line.strip!
    end

    relevant_lines_ary = lines.keep_if do |line|
      !csharp_regex.match(line).nil? && line != ""
    end
    relevant_lines_ary.each_cons(3) do |previous, current, nekst|
      first_token = current.split[0].strip
      previous_first_token = previous.split[0].strip
      if first_token == 'namespace'
        second_token = current.split[1].strip
        node = Tree.new(second_token)
        node.file_name = @file_name
        parent = fetch_parent(@stack, node)
        if parent
          parent.children << node
          node.parent = parent
        end
        node.structure_marker = 'namespace'
        @stack.push(node)
      elsif first_token == "[TestFixture]"
        nekst_second_token = nekst.split[1].strip
        node = Tree.new(nekst_second_token)
        node.file_name = @file_name
        parent = fetch_parent(@stack, node)
        if parent
          parent.children << node
          node.parent = parent
        end
        node.structure_marker = 'test_fixture'
        @stack.push(node)
      elsif first_token == "[Test]"
        nekst_second_token = nekst.split[1].strip
        node = Tree.new(nekst_second_token)
        node.file_name = @file_name
        parent = fetch_parent(@stack, node)
        if parent
          parent.children << node
          node.parent = parent
        end
        node.structure_marker = 'test'
        @stack.push(node)
      elsif /^\[TestCase/ =~ current 
        first_token = first_token.gsub!(/[\[\]()]|TestCase/,"").strip
        node = Tree.new(first_token)
        node.file_name = @file_name
        node.structure_marker = 'test'
        @test_case_stack.push(node)
        if nekst && nekst.split[0]
          nekst_first_token = nekst.split[0].strip
        end
        if !(/^public/ =~ nekst_first_token)
          if nekst.split[1]
            nekst_second_token = nekst.split[1].strip
          end
          parent = Tree.new(nekst_second_token)
          parent.file_name = @file_name
          parent.structure_marker = 'test'
          parent_of_parent = fetch_parent(@stack, parent)
          parent.parent = parent_of_parent
          while !@test_case_stack.empty?
            test_case = @test_case_stack.pop
            parent.children << test_case
            test_case.parent = parent
          end
        end
      elsif( !(/^\[TestCase/ =~ first_token) && (/^\[TestCase/ =~ previous_first_token) )
        next
      else
      end
    end
    @root
  end

  #this method parses java files
  def create_java_test_node
    File.open(@file_name, "r") do |f|
      f.each_with_index do |line, index|
        if index == 0
          @stack = []
          @stack.push(@root)
          parent = @root
        end
        line.chomp!
        next if line.empty? || line.nil?
        prelim_whitespace = 0
        line.each_byte do |byte|
          break if byte != 32
          prelim_whitespace += 1
        end

        stripped_line = line.strip
        next if stripped_line.nil? || stripped_line.empty?

        case stripped_line
        when /^package/
          node = Tree.new(format_java_description(line), prelim_whitespace)
          node.file_name = @file_name
          parent = fetch_parent(@stack, node)
          if parent
            parent.children << node
            node.parent = parent
          end
          node.structure_marker = 'package'
          @stack.push(node)
        when /^public class/
          node = Tree.new(format_java_description(line), prelim_whitespace)
          node.file_name = @file_name
          parent = fetch_parent(@stack, node)
          if parent
            parent.children << node
            node.parent = parent
          end
          node.structure_marker = 'java_class'
          @stack.push(node)
        when /^public void/
          node = Tree.new(format_java_description(line), prelim_whitespace)
          node.file_name = @file_name
          parent = fetch_parent(@stack, node)
          if parent
            parent.children << node
            node.parent = parent
          end
          node.structure_marker = 'test'
        else
        end
      end
    end
    @root
  end

  def generate_report(test_report_file_name="test_report_#{Time.now}.txt")
    node = create_test_node
    @test_nodes << node
    File.open(test_report_file_name, "a+") do |f|
      f << node.to_s << "\n" << "\n"
    end
  end

  def self.fetch_filenames(feature)
    case feature
    when 'Heimdall'
      heimdall_filenames = Dir.glob("#{Rails.root}/heimdall/**/*_test.go")
    when 'Paycheck'
      paycheck_filenames = Dir.glob("#{Rails.root}/paycheck/spec/**/*.rb")
    when 'Bifrost'
      bifrost_filenames = Dir.glob("#{Rails.root}/bifrost/**/*_test.go")
    when 'HAT/Cortana'
      hat_filenames = Dir.glob("#{Rails.root}/hat/spec/**/*.rb")
    when 'Accounts'
      accounts_filenames = Dir.glob("#{Rails.root}/accounts/**/*_test.go")
    when 'Metrics Queue'
      metric_queue_filenames = Dir.glob("#{Rails.root}/metrics-queue/**/*.go")
    when 'Apollo'
      apollo_filenames = Dir.glob("#{Rails.root}/apollo-program/spec/**/*.rb")
    when 'NetGRPC'
      netgrpc_filenames = Dir.glob("#{Rails.root}/nsgrpc/spec/**/*.rb")
    when 'Benefits ACA'
      csharp_benefits_filenames = Dir.glob("#{Rails.root}/Namely.Payroll.RulesEngine/test/**/*.cs")
    when 'Auto Sync' 
      java_hcm_autosync_filenames = Dir.glob("#{Rails.root}/automation/src/test/java/com/namely/tests/hcm/**/*.java")
      java_little_rock_hcm_autosync_filenames = Dir.glob("#{Rails.root}/automation/src/test/java/com/namely/tests/little/rock/hcm/**/*.java")
      java_hcm_autosync_filenames.push(*java_little_rock_hcm_autosync_filenames)
    when 'Payroll'
      java_little_rock_filenames = Dir.glob("#{Rails.root}/automation/src/test/java/com/namely/tests/little/rock/payroll/**/*.java")
      java_payroll_filenames = Dir.glob("#{Rails.root}/automation/src/test/java/com/namely/tests/payroll/**/*.java")
      java_little_rock_filenames.push(*java_payroll_filenames)
    when 'Carrier Feeds'
      Dir.glob("#{Rails.root}/automation/src/test/java/com/namely/tests/carrierfeeds/*.java")
    when 'API'
      Dir.glob("#{Rails.root}/namely/spec/controllers/api/**/*.rb")
    when 'HCM-unit'
      Dir.glob("#{Rails.root}/namely/spec/**/*.rb")
    when 'HCM-feature'
      Dir.glob("#{Rails.root}/namely/features/**/*.feature")
    when 'Permissions'
      Dir.glob("#{Rails.root}/permissions/spec/**/*.rb")
    else
    end
  end

  def self.fetch_all_filenames
    filenames = []
    heimdall_filenames = Dir.glob("#{File.dirname(__FILE__)}/heimdall/**/*_test.go")
    paycheck_filenames = Dir.glob("#{File.dirname(__FILE__)}/paycheck/spec/**/*.rb")
     bifrost_filenames = Dir.glob("#{File.dirname(__FILE__)}/bifrost/**/*_test.go")
    hat_filenames = Dir.glob("#{File.dirname(__FILE__)}/hat/spec/**/*.rb")
    accounts_filenames = Dir.glob("#{File.dirname(__FILE__)}/accounts/**/*_test.go")
    metric_queue_filenames = Dir.glob("#{File.dirname(__FILE__)}/metrics-queue/**/*.go")
   
    apollo_filenames = Dir.glob("#{File.dirname(__FILE__)}/apollo-program/spec/**/*.rb")
    
    netgrpc_filenames = Dir.glob("#{File.dirname(__FILE__)}/nsgrpc/spec/**/*.rb")
    
    csharp_benefits_filenames = Dir.glob("#{File.dirname(__FILE__)}/Namely.Payroll.RulesEngine/test/**/*.cs")
  
      java_hcm_autosync_filenames = Dir.glob("#{File.dirname(__FILE__)}/automation/src/test/java/com/namely/tests/hcm/**/*.java")
      java_little_rock_hcm_autosync_filenames = Dir.glob("#{File.dirname(__FILE__)}/automation/src/test/java/com/namely/tests/little/rock/hcm/**/*.java")
      java_hcm_autosync_filenames.push(*java_little_rock_hcm_autosync_filenames)
  
      java_little_rock_filenames = Dir.glob("#{File.dirname(__FILE__)}/automation/src/test/java/com/namely/tests/little/rock/payroll/**/*.java")
      java_payroll_filenames = Dir.glob("#{File.dirname(__FILE__)}/automation/src/test/java/com/namely/tests/payroll/**/*.java")
      java_little_rock_filenames.push(*java_payroll_filenames)
    carrier_feeds_filenames = Dir.glob("#{File.dirname(__FILE__)}/automation/src/test/java/com/namely/tests/carrierfeeds/*.java")
    api_filenames = Dir.glob("#{File.dirname(__FILE__)}/namely/spec/controllers/api/**/*.rb")
    hcm_unit_filenames =
      Dir.glob("#{File.dirname(__FILE__)}/namely/spec/**/*.rb")
    hcm_feature_filenames =
      Dir.glob("#{File.dirname(__FILE__)}/namely/features/**/*.feature")
    permissions_filenames = 
      Dir.glob("#{File.dirname(__FILE__)}/permissions/spec/**/*.rb")
    filenames << heimdall_filenames << paycheck_filenames << bifrost_filenames << hat_filenames << accounts_filenames << metric_queue_filenames << apollo_filenames << netgrpc_filenames << csharp_benefits_filenames << java_hcm_autosync_filenames << java_little_rock_filenames << carrier_feeds_filenames << api_filenames << hcm_unit_filenames << hcm_feature_filenames << permissions_filenames
  end

  #todo refactor to use more general #fetch_filenames(feature)
  #this generates a report of all test cases
  def self.generate_report(report_file_name='test_report.txt')
    file_names = self.fetch_all_filenames
    file_names.each do |file_name|
      test_report = self.new(file_name)
      test_report.generate_report(report_file_name)
    end
  end

  def self.expose_nodes(feature)
    self.delete_test_nodes
    file_names = TestReport.fetch_filenames(feature)
    file_names.each do |file_name|
      test_report = TestReport.new(file_name, feature)
      if @@java_features.include? feature
        @test_nodes << test_report.create_java_test_node
      elsif @@csharp_features.include? feature
        @test_nodes << test_report.create_csharp_test_node
      elsif @@go_features.include? feature
        @test_nodes << test_report.create_go_test_node
      else
        @test_nodes << test_report.create_test_node
      end
    end
    @test_nodes
  end

  def self.test_case_count(feature)
    cases = 0
    #remember expose_nodes returns an array of test nodes
    self.expose_nodes(feature).each do |node|
      cases += node.spec_count
    end
    cases
  end

  def self.delete_test_nodes
    @test_nodes = []
  end

  def find_node(description)
    @test_nodes.each do |node|
      found = node.find_child(description)
      return found unless found.nil?
    end
    "not found"
  end

end #end class TestReport
