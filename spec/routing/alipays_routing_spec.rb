require "spec_helper"

describe AlipaysController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/alipays" }.should route_to(:controller => "alipays", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/alipays/new" }.should route_to(:controller => "alipays", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/alipays/1" }.should route_to(:controller => "alipays", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/alipays/1/edit" }.should route_to(:controller => "alipays", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/alipays" }.should route_to(:controller => "alipays", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/alipays/1" }.should route_to(:controller => "alipays", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/alipays/1" }.should route_to(:controller => "alipays", :action => "destroy", :id => "1")
    end

  end
end
