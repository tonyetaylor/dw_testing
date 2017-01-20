class HomeController < ApplicationController
  def index
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Feature' )
    data_table.new_column('number', 'Tests')
    test_case_rows = TestReport.all_features.map { |feature| [feature, TestReport.test_case_count(feature)] }
    data_table.add_rows(test_case_rows)
    @chart = create_chart(data_table,'Tests Per Feature')

    #find new tests
    new_tests(test_case_rows)
    #copy here
    create_new_baseline(Hash[test_case_rows], "test_report.txt")
  end

  def create_new_baseline(new_count, baseline_file)
    File.open(baseline_file, "w+") do |f|
      new_count.each do |k, v|
        f << k.to_s + ": "+ v.to_s + "\n"
      end
    end
  end

  def create_chart(data_table, title)
    options = { width: 500, height: 340, title: title }
    GoogleVisualr::Interactive::LineChart.new(data_table, options)
  end

  def new_tests(new_count)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Feature')
    data_table.new_column('number', 'Tests')

    old_count = Hash.new
    if File.exist?("test_report.txt")
      old_count = Hash[*File.read("test_report.txt").split(/[:\n]+/)]
    else
      File.new("test_report.txt", "w+")
    end
    num_of_new_tests(old_count, Hash[new_count])
    new_tests = Hash[*File.read("diff.txt").split(/[:\n]+/)]
    convert_values(new_tests)
    data_table.add_rows(new_tests.to_a)
    @new_test_chart = create_chart(data_table,'New Tests Per Feature')
  end

  def convert_values(arry)
    arry.each do |k,v|
      arry[k] = arry[k].to_i
    end
  end

  def num_of_new_tests(h1, h2)
    f1 = File.new("diff.txt","a+")
    if(h1.values == h2.values)
      h2.each do |key|
        f1 << "#{key}:" + " 0\n"
      end
    else
      #puts h1.values
      puts h2.values
      f1 = File.open("diff.txt","a+")
      h2.each do |key, value|
        if(value != h1[key])
          f1 << "#{key}:" + " #{h2[key].to_i - h1[key].to_i}\n"
        end
      end
    end
  end
end