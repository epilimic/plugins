sockpuppet informant
====================
This is the Smurf-o-Matic 9000, codenamed informant. This plugin will log the playername, steamid, ip address, server name, server ip, and connection time to a MySQL database. 

Website
=======
https://github.com/epilimic/plugins/tree/master/informant

Upstream
========
* git@github.com:epilimic/plugins.git

Installation and usage
======================
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

LICENSE
=======
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
 Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS F
OR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

Valve, the Valve logo, Source, and the Source logo are trademarks and/or registered trademarks of Valve Corporation. All other trademarks are property of their respective owners.

