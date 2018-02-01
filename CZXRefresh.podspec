Pod::Spec.new do |s|
  s.name         = "CZXRefresh"
  s.version      = "0.0.1"
  s.summary      = "CZXRefresh can make UITableView and UICollectionView refesh or add more easier"
  s.description  = <<-DESC
                   DESC
  s.homepage     = "https://github.com/average17/CZXRefresh"
  s.license      = "MIT"
  s.author       = { "average17" => "chen82252110@foxmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/average17/CZXRefresh.git", :tag => "#{s.version}" }
  s.source_files  = "CZXRefresh/*{swift,h,m}"
  s.requires_arc = true
end
