/*
    createinformant.sql
    Initializes a database node to serve the sourcemod informant plugin. 
    url: https://github.com/epilimic/plugins/tree/master/informant

    Created Mon Nov 25 20:04:00 PST 2013
*/

CREATE DATABASE `informant` DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `sockpuppetInformant`.`informant` (
        -- primary key
    `id`          bigint(20) unsigned          NOT NULL AUTO_INCREMENT
        -- client-generated data
,   `servername`  text COLLATE utf8_unicode_ci NOT NULL
,   `serverip`    text COLLATE utf8_unicode_ci NOT NULL
,   `steamid`     text COLLATE utf8_unicode_ci NOT NULL
,   `ipaddress`   text COLLATE utf8_unicode_ci NOT NULL
,   `playername`  text COLLATE utf8_unicode_ci NOT NULL
,   `connecttime` text COLLATE utf8_unicode_ci NOT NULL
,   `unixtime`    int(11)                      NOT NULL
,       -- constraints
,   PRIMARY KEY   (`id`)
,   UNIQUE KEY    `id` (`id`)
) ENGINE=InnoDB;

