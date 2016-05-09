Pod::Spec.new do |spec|
  spec.name         = 'GzipInputStream'
  spec.version      = '0.0.1'
  spec.license      = { :type => 'Unknown' }
  spec.homepage     = 'https://github.com/mtrbean/GzipInputStream'
  spec.authors      = { 'Eric Wong' => 'mtrbean@users.noreply.github.com' }
  spec.summary      = 'A subclass of NSInputStream that reads .gz files with reading line by line functionality'
  spec.source       = { :git => 'https://github.com/mtrbean/GzipInputStream.git', :tag => 'v0.0.1' }
  spec.source_files = 'GzipInputStream.{h,m}'
  spec.framework    = 'Foundation'
  spec.libraries    = 'z'
  spec.requires_arc = true
end
