Pod::Spec.new do |s|
    s.name         = "LQLaunchImageInterstitials"
    s.version      = "0.0.1"
    s.summary      = "使用SDWebImage来设置启动时植入广告"
    s.homepage     = "https://github.com/lq121/LQLaunchImageInterstitials"
    s.license      = "MIT"
    s.author             = { "魑魅魍魉121" => "1210971329@qq.com" }
    s.social_media_url   = "https://github.com/lq121"
    s.platform     = :ios, "6.0"
    s.source       = { :git => "https://github.com/lq121/LQLaunchImageInterstitials.git", :tag =>"0.0.1", :commit => "d4bb1d36b4a72f2b2747d3137874f946c96543a8" }
    s.source_files  = "LQLaunchImageInterstitials/**/*.{h,m}"
    s.requires_arc = true
    s.dependency 'SDWebImage', '~> 3.8.1'
# Pod Dependencies

end