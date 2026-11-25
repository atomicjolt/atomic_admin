require "test_helper"
require "tempfile"

class JwksDecoderTest < ActiveSupport::TestCase
  setup do
    @jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), { use: "sig", kid: "key-1" })
    @token = JWT.encode({ "aud" => "test" }, @jwk.signing_key, "RS256", { kid: @jwk[:kid] })
    @file = Tempfile.new(["jwks", ".json"])
    write_jwks(@jwk)
    Rails.cache.delete(AtomicAdmin::JwtToken::JwksDecoder::CACHE_KEY)
  end

  teardown do
    @file.close!
  end

  test "decodes using keys from the jwks file" do
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(nil, jwks_path: @file.path)

    assert_equal "test", decoder.decode!(@token)["aud"]
  end

  test "accepts a Pathname" do
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(nil, jwks_path: Pathname.new(@file.path))

    assert_equal "test", decoder.decode!(@token)["aud"]
  end

  test "picks up rotated keys from the jwks file without a restart" do
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(nil, jwks_path: @file.path)
    decoder.decode!(@token)

    new_jwk = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), { use: "sig", kid: "key-2" })
    write_jwks(@jwk, new_jwk)
    new_token = JWT.encode({ "aud" => "test" }, new_jwk.signing_key, "RS256", { kid: new_jwk[:kid] })

    assert_equal "test", decoder.decode!(new_token)["aud"]
  end

  test "rejects tokens signed by a key not in the jwks file" do
    other = JWT::JWK.new(OpenSSL::PKey::RSA.new(2048), { use: "sig", kid: "other" })
    token = JWT.encode({ "aud" => "test" }, other.signing_key, "RS256", { kid: other[:kid] })
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(nil, jwks_path: @file.path)

    assert_raises(JWT::DecodeError) { decoder.decode(token) }
  end

  test "falls back to the jwks url when the file does not exist" do
    jwks = JWT::JWK::Set.new(@jwk).export
    response = Struct.new(:parsed_response).new(jwks.deep_stringify_keys)
    decoder = AtomicAdmin::JwtToken::JwksDecoder.new(
      "https://admin.example.com/jwks.json",
      jwks_path: "/nonexistent/jwks.json",
    )

    with_httparty_get(response) do
      assert_equal "test", decoder.decode!(@token)["aud"]
    end
  end

  private

  def with_httparty_get(response)
    original = HTTParty.method(:get)
    HTTParty.define_singleton_method(:get) { |*| response }
    yield
  ensure
    HTTParty.define_singleton_method(:get, original)
  end

  def write_jwks(*jwks)
    File.write(@file.path, JWT::JWK::Set.new(jwks).export.to_json)
  end
end
