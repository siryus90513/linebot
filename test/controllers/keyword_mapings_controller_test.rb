require "test_helper"

class KeywordMapingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @keyword_maping = keyword_mapings(:one)
  end

  test "should get index" do
    get keyword_mapings_url
    assert_response :success
  end

  test "should get new" do
    get new_keyword_maping_url
    assert_response :success
  end

  test "should create keyword_maping" do
    assert_difference('KeywordMaping.count') do
      post keyword_mapings_url, params: { keyword_maping: { channel_id: @keyword_maping.channel_id, keyword: @keyword_maping.keyword, message: @keyword_maping.message } }
    end

    assert_redirected_to keyword_maping_url(KeywordMaping.last)
  end

  test "should show keyword_maping" do
    get keyword_maping_url(@keyword_maping)
    assert_response :success
  end

  test "should get edit" do
    get edit_keyword_maping_url(@keyword_maping)
    assert_response :success
  end

  test "should update keyword_maping" do
    patch keyword_maping_url(@keyword_maping), params: { keyword_maping: { channel_id: @keyword_maping.channel_id, keyword: @keyword_maping.keyword, message: @keyword_maping.message } }
    assert_redirected_to keyword_maping_url(@keyword_maping)
  end

  test "should destroy keyword_maping" do
    assert_difference('KeywordMaping.count', -1) do
      delete keyword_maping_url(@keyword_maping)
    end

    assert_redirected_to keyword_mapings_url
  end
end
