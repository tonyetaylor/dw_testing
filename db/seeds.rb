# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
test_suites = TestSuite.create([{ title: 'onboarding', description: 'welcoming employees' }, { title: 'time', description: 'clock in, clock out' }])

test_cases = TestCase.create!([{ title: 'test case 1', description: 'simple one', expected_result: '41', test_suite_id: test_suites.first.id }, { title: 'test case 2', description: 'simple two', expected_result: '42', test_suite_id: test_suites.first.id }, { title: 'test case 3', description: 'simple three', expected_result: '43', test_suite_id: test_suites.second.id }])
