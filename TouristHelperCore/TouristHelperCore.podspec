Pod::Spec.new do |s|  
  s.name         = "TouristHelperCore"
  s.version      = "0.0.1"
  s.summary      = "Provides core services for Tourist Helper App"

  s.description  = <<-DESC
                   A longer description of NetworkLib in Markdown format.
                   DESC

  s.license      = 'MIT (example)'
  s.author       = { "Janidu Wanigasuriya" => "janiduw@gmail.com" }
  s.source_files  = 'TouristHelperCore', 'TouristHelperCore/**/*.{h,m}'
  s.public_header_files = 'TouristHelperCore/**/*.h'
  s.resources    = "TouristHelperCore/*.png", "TouristHelperCore/GmsInfo.plist"
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.dependency 'GoogleMaps'
  s.dependency 'AFNetworking'
  s.dependency 'CocoaLumberjack'

end  