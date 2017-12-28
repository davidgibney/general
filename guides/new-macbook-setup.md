# New developer consultant MacBook setup guide

This guide is a reference for general setup of a new MacBook.


## First steps

If the MacBook is used, be sure to perform a factory reset, and inspect the battery cycle count and SSD health.  


### User Accounts


**The first user account:** 

an iCloud login, with admin privileges.  Use this account to administer the machine and install software from the App Store.  Setup 'Find My Mac'.


**The additional user accounts:** 

add other user accounts, such as one per client.  If the MacBook is Charle's, then why not user accounts of 'charles-mazda', 'charles-toyota', and 'charles-honda', if Charles is consulting for three automotive companies.  Don't give these local accounts admin powers, unless the MacBook can be managed with tools like JAMF, Netskope, and etc.



### General -- application installs

***Install...***
* System updates
* The following applications from the App Store:
	* Xcode
	* 1Password
	* Microsoft Remote Desktop
	* Microsoft OneNote
	* *And whatever other tools, such as editors for JSON and Markdown, ...* 
* Homebrew
	* ```brew install tmux git python python3 ruby rbenv ruby-build rbenv-default-gems docker coreutils moreutils findutils tree thefuck wget gpg jq homebrew/dupes/grep```
	* ```brew install gnu-sed --with-default-names```
	* ```brew install vim --override-system-vi```
	* ```brew install caskroom/cask/brew-cask```
	* ```brew cask install chefdk```
	* ```alias brewup='brew update; brew upgrade; brew cask update; brew prune; brew cleanup; brew doctor'```
* iTerm
* awscli
* Web browsers Chrome, Firefox, Brave
* Text and code editors:  Sublime, Atom, Visual Studio Code, Brackets, TextWrangler, ...
* Fix your link to Python (don't use OSX system Python) -- [good blog post](http://blog.manbolo.com/2014/09/27/use-python-effectively-on-os-x)
	* And more than that, be sure to follow the practice of using virtual environments.
* Customize your terminal:  [zsh plus plugins](https://gist.github.com/kevin-smets/8568070)
* Slack, Evernote, Virtualbox, Cyberduck

