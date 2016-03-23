# warframe-rss-prowl
Checks warframe RSS feed (http://content.warframe.com/dynamic/rss.php) and based on a regular expression search will notify you on your device through ProwlApp (https://www.prowlapp.com/)
The script needs your Prowl API key located in the file ~/etc/prowl.cfg in order to work, or if you don't care then ignore it and it will output to console.

Script is Ruby, version 1.9.3

<pre>Usage:
./warframe-rss-prowl.rb
Example output:
Alert (6900cr - Helene (Saturn) - 59m)
Alert (8400cr - Adaro (Sedna) - 48m)
Invasion (Corpus (35K) VS. Grineer (25K) - Acheron (Pluto))
Outbreak (10000cr - Venera (Venus))
Outbreak (10000cr - Kiliken (Venus))
Outbreak (10000cr - PHORID SPAWN Fossa (Venus))
Outbreak (2x Detonite Injector - Limtoc (Phobos))

Usage:
./warframe-rss-prowl.rb corpus no
Example output:
Invasion, Corpus (35K) VS. Grineer (25K) - Acheron (Pluto)
</pre>
