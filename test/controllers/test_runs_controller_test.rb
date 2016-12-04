require 'test_helper'

class TestRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_run = test_runs(:one)
  end

  test "should get index" do
    get test_runs_url
    assert_response :success
  end

  test "should get new" do
    get new_test_run_url
    assert_response :success
  end

  test "should create test_run" do
    assert_difference('TestRun.count') do
      post test_runs_url, params: { test_run: { description: @test_run.description, title: @test_run.title, user_id: @test_run.user_id } }
    end

    assert_redirected_to test_run_url(TestRun.last)
  end

  test "should show test_run" do
    get test_run_url(@test_run)
    assert_response :success
  end

  test "should get edit" do
    get edit_test_run_url(@test_run)
    assert_response :success
  end

  test "should update test_run" do
    patch test_run_url(@test_run), params: { test_run: { description: @test_run.description, title: @test_run.title, user_id: @test_run.user_id } }
    assert_redirected_to test_run_url(@test_run)
  end

  test "should destroy test_run" do
    assert_difference('TestRun.count', -1) do
      delete test_run_url(@test_run)
    end

    assert_redirected_to test_runs_url
  end
end
