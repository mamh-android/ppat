class ToolsController < ApplicationController
  def gerrit
      render :layout=>"tools"
  end

  def buildbot
  	render :layout=>"tools"
  end

  def rtvb
  	render :layout=>"tools"
  end

  def xref
  	render :layout=>"tools"
  end

  def oldppat
  	render :layout=>"tools"
  end

  def smoketest
  	render :layout=>"tools"
  end
end