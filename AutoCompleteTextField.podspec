Pod::Spec.new do |spec|
  spec.name                  = 'AutoCompleteTextField'
  spec.version               = '0.1.0'
  spec.summary               = 'A generic, reusable auto-completion text field written in Swift.'
  spec.homepage              = 'https://github.com/jpmendel/auto-complete-text-field-swift'
  spec.license               = { :type => 'MIT', :file => 'LICENSE' }
  spec.author                = { 'Jacob Mendelowitz' => '' }

  spec.ios.deployment_target = '10.0'
  spec.swift_version         = '4.2'
  spec.source                = { :git => 'https://github.com/jpmendel/auto-complete-text-field-swift.git', :tag => spec.version }
  spec.source_files          = 'AutoCompleteTextField/**/*'
end
