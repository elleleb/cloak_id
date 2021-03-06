require 'spec_helper'
require File.dirname(__FILE__)+'/../../lib/cloak_id/cloak_id_encoder'

describe CloakId::CloakIdEncoder do

  it 'should raise exception when the id to be cloaked is not numeric' do
    expect {CloakId::CloakIdEncoder.cloak(id)}.to raise_error
  end

  it 'should return the base id after cloaking twice' do
    cloaked_v = CloakId::CloakIdEncoder.cloak(10000,0)
    expect(CloakId::CloakIdEncoder.cloak(cloaked_v,0)).to eql 10000

    cloaked_v = CloakId::CloakIdEncoder.cloak(0xffff25,0x1234)
    expect(CloakId::CloakIdEncoder.cloak(cloaked_v,0x1234)).to eql 0xffff25
  end

  it 'should be able to perform a base 36 encoding and decoding successfully' do
    cloaked_v = CloakId::CloakIdEncoder.cloak_base36(10000,0)
    decloaked_v = CloakId::CloakIdEncoder.decloak_base36(cloaked_v,0)
    expect(decloaked_v).to eql 10000
  end

  it 'should enforce a minimum length when using modified base 35 encoding' do
    cloaked_v = CloakId::CloakIdEncoder.cloak_mod_35(10000,0,40)

    expect(cloaked_v).to include 'ZZZZZZZZZ'
    expect(cloaked_v).to have(40).characters

    decloaked_id = CloakId::CloakIdEncoder.decloak_mod_35(cloaked_v,0)
    expect(decloaked_id).to eql 10000
  end


  it 'should not modify the cloaked id if the cloaked value is already long enough' do
    cloaked_v = CloakId::CloakIdEncoder.cloak_mod_35(10000,0,5)
    expect(cloaked_v).to_not include 'Z'
    expect(cloaked_v).to have_at_least(5).characters
  end

  it 'should make use of the configured default key when none is provided' do
    key_0_cloaked = CloakId::CloakIdEncoder.cloak_mod_35(1234)
    CloakId::CloakIdEncoder.cloak_id_default_key = 4321
    key_4321_cloaked = CloakId::CloakIdEncoder.cloak_mod_35(1234)
    key_4321_decloaked = CloakId::CloakIdEncoder.decloak_mod_35(key_4321_cloaked)

    expect(key_4321_decloaked).to eql 1234
    expect(key_0_cloaked).to_not eql key_4321_cloaked
  end
end