
class CompositeManifestContainer
  def initialize
    @webpacker_container = ::React::ServerRendering::WebpackerManifestContainer.new
    @sprockets_container = sprockets_container.new
  end

  def find_asset(filename)
    if filename.starts_with? 'sprockets_'
      "\n" + @sprockets_container.find_asset(filename)
    else
      @webpacker_container.find_asset(filename)
    end
  end

  private

  def sprockets_container
    if ::React::ServerRendering::ManifestContainer.compatible?
      ::React::ServerRendering::ManifestContainer
    else
      ::React::ServerRendering::EnvironmentContainer
    end
  end
end
