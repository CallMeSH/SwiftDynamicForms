Pod::Spec.new do |s|
  s.name        = 'SwiftDynamicForms'
  s.version     = '5.0'
  s.authors     = { 'Benoit Pereira da Silva' => 'benoit@pereira-da-silva.com' }
  s.homepage    = 'https://github.com/Chaosmose/SwiftDynamicForms'
  s.summary     = 'Dynamic Forms'
  s.source      = { :git => 'https://github.com/SwiftDynamicForms/SwiftDynamicForms.git'}
  s.license     = { :type => "LGPL", :file => "LICENSE" }
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source_files =  'Sources/*'
end

