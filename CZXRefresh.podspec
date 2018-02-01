Pod::Spec.new do |s|
  s.name         = "CZXRefresh"
  s.version      = "0.0.2"
  s.summary      = "CZXRefresh can make UITableView and UICollectionView refesh or add more easier"
  s.description  = <<-DESC
                    CZXRefresh is easy to refresh UITableVie and UICollectionView.And now, enjoy it.
                   DESC
  s.homepage     = "https://github.com/average17/CZXRefresh"
  s.license      = "MIT"
  s.author       = { "average17" => "chen82252110@foxmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/average17/CZXRefresh.git", :tag => "#{s.version}" }
  s.source_files  = "CZXRefresh/Refresh/*{swift}"
  s.requires_arc = true
end
