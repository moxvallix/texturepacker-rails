require "test_helper"

class TexturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @texture = textures(:one)
  end

  test "should get index" do
    get textures_url
    assert_response :success
  end

  test "should get new" do
    get new_texture_url
    assert_response :success
  end

  test "should create texture" do
    assert_difference("Texture.count") do
      post textures_url, params: { texture: { name: @texture.name, origin: @texture.origin, uid: @texture.uid } }
    end

    assert_redirected_to texture_url(Texture.last)
  end

  test "should show texture" do
    get texture_url(@texture)
    assert_response :success
  end

  test "should get edit" do
    get edit_texture_url(@texture)
    assert_response :success
  end

  test "should update texture" do
    patch texture_url(@texture), params: { texture: { name: @texture.name, origin: @texture.origin, uid: @texture.uid } }
    assert_redirected_to texture_url(@texture)
  end

  test "should destroy texture" do
    assert_difference("Texture.count", -1) do
      delete texture_url(@texture)
    end

    assert_redirected_to textures_url
  end
end
