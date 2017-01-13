require 'test_helper'

class TestPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @test_plan = test_plans(:one)
  end

  test "should get index" do
    get test_plans_url
    assert_response :success
  end

  test "should get new" do
    get new_test_plan_url
    assert_response :success
  end

  test "should create test_plan" do
    assert_difference('TestPlan.count') do
      post test_plans_url, params: { test_plan: { notes: @test_plan.notes, sprint_begin_date: @test_plan.sprint_begin_date, sprint_end_date: @test_plan.sprint_end_date, title: @test_plan.title, user_id: @test_plan.user_id } }
    end

    assert_redirected_to test_plan_url(TestPlan.last)
  end

  test "should show test_plan" do
    get test_plan_url(@test_plan)
    assert_response :success
  end

  test "should get edit" do
    get edit_test_plan_url(@test_plan)
    assert_response :success
  end

  test "should update test_plan" do
    patch test_plan_url(@test_plan), params: { test_plan: { notes: @test_plan.notes, sprint_begin_date: @test_plan.sprint_begin_date, sprint_end_date: @test_plan.sprint_end_date, title: @test_plan.title, user_id: @test_plan.user_id } }
    assert_redirected_to test_plan_url(@test_plan)
  end

  test "should destroy test_plan" do
    assert_difference('TestPlan.count', -1) do
      delete test_plan_url(@test_plan)
    end

    assert_redirected_to test_plans_url
  end
end
