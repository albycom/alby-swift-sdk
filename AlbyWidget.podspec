Pod::Spec.new do |s|
    s.name             = 'AlbyWidget'
    s.version          = '0.3.10'
    s.summary          = 'Increase conversion in your e-commerce by answering all your shopper questions before they even ask.'
    s.homepage         = 'https://github.com/albycom/alby_widget_ios'
    s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author           = { 'Alby, Inc.' => 'thiago@alby.com' }
    s.source           = { :git => 'https://github.com/albycom/alby_widget_ios.git', :tag => s.version.to_s }
    s.ios.deployment_target = '15.2'
    s.platform = :ios, '15.2'
    s.swift_version = '5.0'
    
    s.source_files = 'Sources/AlbyWidget/**/*.swift'
    
    s.resources = ['Sources/AlbyWidget/Assets/*.png']
    
    s.dependency 'BottomSheetSwiftUI', '~> 3.1.1'
end
