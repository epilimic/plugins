This is the Smurf-o-Matic 9000, codenamed informant. This plugin will log the playername, steamid, ip address, server name, server ip, and connection time all to a MySQL database.

Usage if you're connected with our main Smurf-o-Matic Database:
*  1: Edit informant.cfg with your MySQL database login information.
*  2: Upload the config to your server's /addons/sourcemod/configs/ folder.
*  3:  Upload the plugin to your plugins folder. 
*  3a:  Add "sm plugins load informant.smx" (or "sm plugins load optional/informant.smx") to confogl_personalize.cfg and it will load in every confogl based config.
*  4:  ?????
*  5:  Profit!

Usage if you're running this yourself:

*  1: Edit informant.cfg with your MySQL database login information.
*  2: Upload the config to your server's /addons/sourcemod/configs/ folder.
*  3:  Upload the plugin to your plugins folder. 
*  3a:  Add "sm plugins load informant.smx" (or "sm plugins load optional/informant.smx") to confogl_personalize.cfg and it will load in every confogl based config.
*  4: Create a MySQL database and run the SQL below to create the table.
*  5:  ?????
*  6:  Profit!

```SQL
CREATE TABLE IF NOT EXISTS `informant` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `servername` text COLLATE utf8_unicode_ci NOT NULL,
  `serverip` text COLLATE utf8_unicode_ci NOT NULL,
  `steamid` text COLLATE utf8_unicode_ci NOT NULL,
  `ipaddress` text COLLATE utf8_unicode_ci NOT NULL,
  `playername` text COLLATE utf8_unicode_ci NOT NULL,
  `connecttime` text COLLATE utf8_unicode_ci NOT NULL,
  `unixtime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
```
