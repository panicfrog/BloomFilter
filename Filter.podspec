Pod::Spec.new do |spec|
  spec.name         = "Filter"
  spec.version      = "0.0.1"
  spec.summary      = "A Bloom/Cuckoo Filter implementation in Swift."
  spec.description  = <<-DESC
    A Bloom/Cuckoo Filter implementation in Swift. with scalable and high performance.
                   DESC
  spec.homepage     = "https://github.com/panicfrog/Filter.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "yongping" => "burnedfrog@163.com" }
  spec.ios.deployment_target = "11.0"
  spec.osx.deployment_target = "10.13"
  spec.source       = { :git => "https://github.com/panicfrog/Filter.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/Filter/**/*.{swift}", "Sources/Cmurmur3/**/*.{c,h}"
  spec.public_header_files = "Sources/Cmurmur3/include/*.h"
  spec.preserve_path = 'Sources/Cmurmur3/module.modulemap'
  spec.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Filter/Sources/Cmurmur3/include/**' }
  spec.swift_version = '5.7'
end
