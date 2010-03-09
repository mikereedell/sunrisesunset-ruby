spec = Gem::Specification.new do | s |
  s.name = "RubySunrise"
  s.version = "0.1.1"
  s.author = "Mike Reedell / LuckyCatLabs"
  s.email = "mike@luckycatlabs.com"
  s.homepage = "http://www.luckycatlabs.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "Calculate the sunrise/sunset given lat/long coordinates and the date.  Computes civil, official, nautical, and astronomical sunrise/sunset."
  s.files = ["rubysunrise.gemspec"] + Dir.glob("lib/**/*")
  s.test_files = Dir.glob("{test}/**/*test.rb")
  s.has_rdoc = false
end