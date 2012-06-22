maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures xwiki"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
recipe           "xwiki", "Install the xwiki application"

supports 'ubuntu'

depends 'tomcat'
depends 'zip'