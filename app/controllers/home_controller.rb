class HomeController < ApplicationController
  def index
  	data_table = GoogleVisualr::DataTable.new
  	data_table.new_column('string', 'Feature' )
    data_table.new_column('number', 'Tests')
    test_case_rows = TestReport.all_features.map { |feature| [feature, TestReport.test_case_count(feature)] } 
    data_table.add_rows(test_case_rows)
    options = { width: 800, height: 440, title: 'Tests Per Feature' }
    @chart =  GoogleVisualr::Interactive::LineChart.new(data_table, options)
  end
end