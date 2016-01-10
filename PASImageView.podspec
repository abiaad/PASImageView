Pod::Spec.new do |s|
  s.name                = "PASImageView"
  s.version             = "1.0.3"
  s.summary             = "Rounded async imageview downloader lightly cached and written in Swift"
  s.description         = "Rounded async imageview downloader lightly cached and written in Swift"
  s.homepage            = "https://github.com/abiaad/PASImageView"
  s.license             = "MIT"
  s.author              = { "Pierre Abi-aad" => "hello@abiaad.io" }
  s.social_media_url    = "http://twitter.com/abiaad"
  s.platform            = :ios
  s.platform            = :ios, "8.0"
  s.source              = { :git => "https://github.com/abiaad/PASImageView.git", :tag => "1.0.3" }
  s.source_files         = "PASImageView.swift"
end
