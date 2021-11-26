require "application_system_test_case"

class TexturesTest < ApplicationSystemTestCase
  setup do
    @texture = textures(:one)
  end

  test "visiting the index" do
    visit textures_url
    assert_selector "h1", text: "Textures"
  end

  test "should create Texture" do
    visit textures_url
    click_on "New Texture"

    fill_in "Name", with: @texture.name
    fill_in "Origin", with: @texture.origin
    fill_in "Uid", with: @texture.uid
    click_on "Create Texture"

    assert_text "Texture was successfully created"
    click_on "Back"
  end

  test "should update Texture" do
    visit textures_url
    click_on "Edit", match: :first

    fill_in "Name", with: @texture.name
    fill_in "Origin", with: @texture.origin
    fill_in "Uid", with: @texture.uid
    click_on "Update Texture"

    assert_text "Texture was successfully updated"
    click_on "Back"
  end

  test "should destroy Texture" do
    visit textures_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Texture was successfully destroyed"
  end
end
