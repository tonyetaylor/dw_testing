desc "Runs an external Ruby script"
task :run_ruby => :environment do
	puts "running ruby"
	filepath = Rails.root.join("lib", "external_scripts", "ruby_script.rb")
	output = `ruby #{filepath}`
	puts output
end

desc "Runs an external R script"
task :test_employee_ODS_table_r => :environment do
	puts "running R!"
	filepath = Rails.root.join("lib", "external_scripts", "create_and_test_employee_table_ODS.R")
	output = `Rscript --vanilla #{filepath}`
	puts output
end