require "application_system_test_case"

class KeywordMapingsTest < ApplicationSystemTestCase
  setup do
    @keyword_maping = keyword_mapings(:one)
  end

  test "visiting the index" do
    visit keyword_mapings_url
    assert_selector "h1", text: "Keyword Mapings"
  end

  test "creating a Keyword maping" do
    visit keyword_mapings_url
    click_on "New Keyword Maping"

    fill_in "Channel", with: @keyword_maping.channel_id
    fill_in "Keyword", with: @keyword_maping.keyword
    fill_in "Message", with: @keyword_maping.message
    click_on "Create Keyword maping"

    assert_text "Keyword maping was successfully created"
    click_on "Back"
  end

  test "updating a Keyword maping" do
    visit keyword_mapings_url
    click_on "Edit", match: :first

    fill_in "Channel", with: @keyword_maping.channel_id
    fill_in "Keyword", with: @keyword_maping.keyword
    fill_in "Message", with: @keyword_maping.message
    click_on "Update Keyword maping"

    assert_text "Keyword maping was successfully updated"
    click_on "Back"
  end

  test "destroying a Keyword maping" do
    visit keyword_mapings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Keyword maping was successfully destroyed"
  end
end
