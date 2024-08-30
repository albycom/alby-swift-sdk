Pod::Spec.new do |s|
    s.name             = 'AlbyWidget'
    s.version          = '0.0.1'
    s.summary          = 'A short description of BloggerBird.'
    s.homepage         = 'https://github.com/albycom/alby_widget_ios'
    s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author           = { 'Alby, Inc.' => 'thiago@alby.com' }
    s.source           = { :git => 'https://github.com/albycom/alby_widget_ios.git', :tag => s.version.to_s }
    s.ios.deployment_target = '15.2'
    s.swift_version = '5.0'
    s.source_files = 'Sources/AlbyWidget/**/*'
  end