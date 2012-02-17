require 'rubygems'

HAML_GEMSPEC = Gem::Specification.new do |spec|
  spec.name = 'make_resourceful'
  spec.summary = "An elegant, structured way to build ActionPack Controllers"
  spec.version = File.read(File.dirname(__FILE__) + '/VERSION').strip
  spec.authors = ['Hampton Catlin']
  spec.email = 'hcatlin@gmail.com'
  spec.description = <<-END
      Take back control of your Controllers. Make them awesome. Make them sleek. Make them resourceful.
    END

  spec.executables = []
  spec.files = Dir['lib/**/*', 'Rakefile', "Readme.rdoc", "VERSION"]
  spec.homepage = 'http://github.com/hcatlin/make_resourceful'
  spec.test_files = Dir['spec/**/*_spec.rb']
end
