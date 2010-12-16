spec = Gem::Specification.new do |s|
  s.name = 'ckuru-tools'
  s.version = '0.0.6'
  s.summary = "The infamous ckuru-tools gem.  A miscellaneous grab bag of ruby class extensions, utility classes, etc."
  s.description = %{The infamous ckuru-tools gem.  A miscellaneous grab bag of ruby class extensions, utility classes, etc.}
  s.files = %w{ spec lib tasks bin }.collect {|dir| Dir["./#{dir}/*"]}.flatten
  s.require_path = 'lib'
  s.author = "Bret Weinraub"
  s.email = "bret@aura-software.com"
  s.homepage = "http://www.aura-software.com"
end
