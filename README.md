# homebrew-tap
My own homebrew tap. 

## Subversion 1.8 with Unicode Patch

Currently featuring `subversion18` (based on https://github.com/Homebrew/homebrew-versions/blob/master/subversion18.rb) with new unicode-path option, since this option was removed from `versions/subversion18`. 
*Caution:* experimental and unsupported!

```
brew tap tholu/tap
brew install --with-unicode-path tholu/tap/subversion18
```

## MariaDB 10.5.8 on Apple Silicon

Based on https://github.com/Homebrew/homebrew-core/pull/70060 and https://github.com/MariaDB/server/pull/1743.
*Caution:* RocksDB is currently disabled (not fixed for Apple Silicon yet), experimental and unsupported!

```
brew tap tholu/tap
brew install tholu/tap/mariadb
```

## Older PHP Versions

For older PHP versions, use https://github.com/shivammathur/homebrew-php - which is better maintained than this tap. I have removed my `php@5.6` formula from this repository.