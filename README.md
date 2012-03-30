kittenizer
==========

Kittenizer replaces a small percentage of webpage images with [kittens](http://www.placekitten.com/) by using Squid as a transparent proxy.

In my setup I use shorewall to redirect internal traffic headed to port 80 to a Squid proxy running on the same machine as shorewall.

I've tried to optimize for speed since images need to be retrieved to check their dimensions. These images are cached locally by the md5 of the remote URL. Whether the image is suitable for kittenizing is also cached.

My testing revealed that only images larger than 90x90 and with an aspect ratio between 1 and 1.6 are suitable for kittening.
