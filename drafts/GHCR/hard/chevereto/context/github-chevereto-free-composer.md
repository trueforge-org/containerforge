# composer.json: rodber/chevereto-free

Source URL(s) + date: https://raw.githubusercontent.com/rodber/chevereto-free/1171863/composer.json, fetched 2026-11-27.

## Facts
- license: AGPL-3.0-only. type project. name rodber/chevereto-free.
- require: php `~7.4`, ext-exif, ext-gd, ext-json; phpmailer/phpmailer ~6.5; jbroadway/urlify ~1.1.2; mobiledetect/mobiledetectlib ^2.8; tijsverkoyen/akismet ~1.0; mlocati/ip-lib ^1.17.
- config: optimize-autoloader true; vendor-dir `app/vendor` (note: vendor is under app/, not /vendor).
- minimum-stability dev, prefer-stable true.

## Gotchas
- PHP `~7.4` means 7.4.x only.
- Vendor dir is `app/vendor`; the Dockerfile's `composer install --working-dir=/var/www/html` resolves to that.
