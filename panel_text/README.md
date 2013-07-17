*this plugin requires CanadaRox's readyup suite. https://github.com/CanadaRox/l4d2readyup

usage:

in confogl.cfg (or wherever else you're setting cvars):

sm_readypaneltextdelay #	- sets the delay for the print. ex: 4 seconds for above tank/witch %, 6 for below. replace #.  
sm_addreadystring "hi mom"	- adds hi mom to the panel.  
sm_addreadystring " "		- adds a blank line.  
sm_lockstrings			- locks it in place so it doesnt re-print anything.


in confogl_off.cfg:

sm_resetstringcount		- resets the count! this must be placed above "sm plugins load_unlock".
