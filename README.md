# homebrew-tap
My own homebrew tap. Currently featuring `subversion18` (based on https://github.com/Homebrew/homebrew-versions/blob/master/subversion18.rb) with new unicode-path option, since this option was removed from `versions/subversion18`. 
*Caution:* experimental and unsupported!

## Usage
```
brew tap tholu/tap
brew install --with-unicode-path tholu/tap/subversion18
```

## Older PHP Versions

For older PHP versions, rather use https://github.com/shivammathur/homebrew-php - which is better maintained than this tap. I have removed my `php@5.6` formula from this repository.