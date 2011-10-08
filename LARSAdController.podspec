Pod::Spec.new do
  name     'LARSAdController'
  version  '2.0.0'
  summary  'A central manager singleton for both iAds and Google Ads.'
  homepage 'https://github.com/larsacus/LARSAdController'
  author   'Lars Anderson' => 'lars@drinkandapple.com'
  source   :git => 'https://github.com/larsacus/LARSAdController.git',
           :tag => '2.0.0'

  platforms 'iOS'
  sdk '>= 3.2'

  source_files 'LARSAdController.{h,m}'
end