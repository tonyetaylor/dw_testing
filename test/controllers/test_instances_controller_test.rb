require 'test_helper'

class TestInstancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_instance = test_instances(:one)
  end

  test "should get index" do
    get test_instances_url
    assert_response :success
  end

  test "should get new" do
    get new_test_instance_url
    assert_response :success
  end

  test "should create test_instance" do
    assert_difference('TestInstance.count') do
      post test_instances_url, params: { test_instance: { description: @test_instance.description, expected_result: @test_instance.expected_result, sql_statement: @test_instance.sql_statement, test_run_id: @test_instance.test_run_id, title: @test_instance.title, user_id: @test_instance.user_id } }
    end

    assert_redirected_to test_instance_url(TestInstance.last)
  end

  test "should show test_instance" do
    get test_instance_url(@test_instance)
    assert_response :success
  end

  test "should get edit" do
    get edit_test_instance_url(@test_instance)
    assert_response :success
  end

  test "should update test_instance" do
    patch test_instance_url(@test_instance), params: { test_instance: { description: @test_instance.description, expected_result: @test_instance.expected_result, sql_statement: @test_instance.sql_statement, test_run_id: @test_instance.test_run_id, title: @test_instance.title, user_id: @test_instance.user_id } }
    assert_redirected_to test_instance_url(@test_instance)
  end

  test "should destroy test_instance" do
    assert_difference('TestInstance.count', -1) do
      delete test_instance_url(@test_instance)
    end

    assert_redirected_to test_instances_url
  end
end
