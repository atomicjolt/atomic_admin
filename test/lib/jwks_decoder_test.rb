require "test_helper"

class JwksDecoderTest < ActiveSupport::TestCase
  FILE_NAME = "admin-jwks-test.json".freeze

  setup do
    @config_dir = Rails.configuration.paths["config"].existent.first
    @jwk = new_jwk("key-1")
    @token = token_for(@jwk)
    Rails.cache.delete(AtomicAdmin::JwtToken::JwksDecoder::CACHE_KEY)
  end

  teardown do
    FileUtils.rm_f(k8s_file)
    FileUtils.rm_f(config_file)
  end

  test "reads the jwks file from config/k8s" do
    write_jwks(k8s_file, @jwk)

    assert_equal "test", decoder.decode!(@token)["aud"]
  end

  test "reads the jwks file from config when config/k8s doesn't have it" do
    write_jwks(config_file, @jwk)

    assert_equal "test", decoder.decode!(@token)["aud"]
  end

  test "prefers config/k8s over config" do
    write_jwks(k8s_file, @jwk)
    write_jwks(config_file, new_jwk("other"))

    assert_equal "test", decoder.decode!(@token)["aud"]
  end

  test "picks up rotated keys from the jwks file without a restart" do
    write_jwks(k8s_file, @jwk)
    decoder.decode!(@token)

    rotated = new_jwk("key-2")
    write_jwks(k8s_file, @jwk, rotated)

    assert_equal "test", decoder.decode!(token_for(rotated))["aud"]
  end

  test "rejects tokens signed by a key not in the jwks file" do
    write_jwks(k8s_file, @jwk)

    assert_raises(JWT::DecodeError) { decoder.decode(token_for(new_jwk("other"))) }
  end

  test "raises when the jwks file is configured but missing, without trying the url" do
    with_httparty_get(->(*) { flunk "should not fetch the jwks url" }) do
      error = assert_raises(AtomicAdmin::JwtToken::MissingJwksError) { decoder.decode(@token) }
      assert_includes error.message, k8s_file
    end
  end

  test "fetches the jwks url when no file is configured" do
    response = Struct.new(:parsed_response).new(JWT::JWK::Set.new(@jwk).export.deep_stringify_keys)
    url_decoder = AtomicAdmin::JwtToken::JwksDecoder.new("https://admin.example.com/jwks.json")

    with_httparty_get(response) do
      assert_equal "test", url_decoder.decode!(@token)["aud"]
    end
  end

  private

  def decoder
    AtomicAdmin::JwtToken::JwksDecoder.new("https://admin.example.com/jwks.json", jwks_file: FILE_NAME)
  end

  def k8s_file
    File.join(@config_dir, "k8s", FILE_NAME)
  end

  def config_file
    File.join(@config_dir, FILE_NAME)
  end

  def new_jwk(kid)
    JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), { use: "sig", kid: kid })
  end

  def token_for(jwk)
    JWT.encode({ "aud" => "test" }, jwk.signing_key, "RS256", { kid: jwk[:kid] })
  end

  def write_jwks(path, *jwks)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JWT::JWK::Set.new(jwks).export.to_json)
  end

  def with_httparty_get(response)
    original = HTTParty.method(:get)
    HTTParty.define_singleton_method(:get) { |*args| response.respond_to?(:call) ? response.call(*args) : response }
    yield
  ensure
    HTTParty.define_singleton_method(:get, original)
  end
end

class VerifyAdminJwksFileTest < ActiveSupport::TestCase
  FILE_NAME = "admin-jwks-boot-test.json".freeze

  setup do
    @original = AtomicAdmin.admin_jwks_file
    @path = File.join(Rails.configuration.paths["config"].existent.first, "k8s", FILE_NAME)
  end

  teardown do
    AtomicAdmin.admin_jwks_file = @original
    FileUtils.rm_f(@path)
  end

  test "passes when no file is configured" do
    AtomicAdmin.admin_jwks_file = nil

    assert_nil AtomicAdmin.verify_admin_jwks_file!
  end

  test "passes when the configured file exists" do
    AtomicAdmin.admin_jwks_file = FILE_NAME
    FileUtils.mkdir_p(File.dirname(@path))
    File.write(@path, "{}")

    assert_equal @path, AtomicAdmin.verify_admin_jwks_file!
  end

  test "raises when the configured file is missing" do
    AtomicAdmin.admin_jwks_file = FILE_NAME

    assert_raises(AtomicAdmin::JwtToken::MissingJwksError) { AtomicAdmin.verify_admin_jwks_file! }
  end

  test "skips the check during assets tasks" do
    AtomicAdmin.admin_jwks_file = FILE_NAME
    require "rake"
    original_tasks = Rake.application.top_level_tasks.dup
    Rake.application.top_level_tasks.replace(["assets:precompile"])

    assert_nil AtomicAdmin.verify_admin_jwks_file!
  ensure
    Rake.application.top_level_tasks.replace(original_tasks) if original_tasks
  end
end
