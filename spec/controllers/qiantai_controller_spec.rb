require 'spec_helper'

describe QiantaiController do

  describe "GET 'ming_e'" do
    it "should be successful" do
      get 'ming_e'
      response.should be_success
    end
  end

end
