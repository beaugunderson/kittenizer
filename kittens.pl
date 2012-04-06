#!/usr/bin/perl

use Math::Random::Secure qw(irand);
use Digest::MD5 qw(md5_hex);

$| = 1;

my $INITIAL_BOUND = 12;
my $LOW_DIMENSION = 90;

my $COMIC_SANS = 1;
my $RICK_ROLL = 1;
my $KITTENS = 1;

my $HOST = 'nginx-server';

my $pid = $$;
my $rand = 0;
my $bound = $INITIAL_BOUND;

while (<>) {
   chomp $_;

   # Filter out some URLs from being kittened
   if ($_ =~ /placekitten\.com/i ||
      $_ =~ /google\.com/i ||
      $_ =~ /nav.*\.gif/i) {
      print "$_\n";

      next;
   }

   # RickRoll YouTube video requests
   if ($RICK_ROLL == 1 &&
      $_ =~ /(.*\.youtube\.com\/videoplayback.*)/) {
      print "http://$HOST/images/rickroll.flv\n";

      next;
   }

   # Randomly select if this request will be Comic Sans-ified
   my $cssRand = irand(15) == 0;

   # Comic Sans-ify CSS files
   if ($COMIC_SANS == 1 &&
      $cssRand == 1 &&
      $_ =~ /(.*\.css(\?.*){0,1})/i) {
      my $url = $1;
      my $digest = md5_hex($url);
      my $css = "/home/www/images/$digest.css";

      unless (-e $css) {
         system("/usr/bin/wget", "-q", "-O", "$css", "$url");

         open(CSS, ">>$css");
         print CSS "* { font-family: \"Comic Sans MS\", \"Comic Sans\", cursive ! important; }\n";
         close(CSS);
      }

      print "http://$HOST/images/$digest.css\n";

      next;
   }

   # Randomly select if this request will be kittened
   $rand = irand($bound) == 0;

   if ($KITTENS == 1 &&
      $rand == 1 &&
      $_ =~ /(.*\.(jpg|jpeg|gif|png)(\?.*){0,1})/i) {
      my $url = $1;
      my $digest = md5_hex("$url.$2");
      my $image = "/home/www/images/$digest.$2";
      my $kittenImage = "/home/www/images/$digest-kitten.$2";
      my $badImage = "/home/www/images/$digest.$2.bad";

      if (-e $kittenImage && !-e $badImage) {
         # The file already exists, use it
         $bound = $INITIAL_BOUND;

         print "http://$HOST/images/$digest-kitten.$2\n";

         next;
      } elsif (!-e $badImage) {
         system("/usr/bin/wget", "-q", "-O", "$image", "$url");

         my $width = `identify -ping -format '%w' $image`;
         my $height = `identify -ping -format '%h' $image`;

         chomp($width);
         chomp($height);

         my $max = ($width, $height)[$width < $height];
         my $min = ($width, $height)[$width > $height];

         my $aspect = $max / $min;

         # Check the image's dimensions and aspect ratio
         if ($width >= $LOW_DIMENSION &&
            $height >= $LOW_DIMENSION &&
            $aspect <= 2) {
            # Reset the chance of a kitten to the initial value
            $bound = $INITIAL_BOUND;

            my $kitten = "http://placekitten.com/$width/$height";

            system("/usr/bin/wget", "-q", "-O", "$kittenImage", "$kitten");

            print "http://$HOST/images/$digest-kitten.$2\n";

            next;
         }

         # If it was too small we create a marker file
         open(BAD, ">$badImage");
         close(BAD);
      }

      # If the image was too small increase the chance
      # of a kitten for the next request
      if ($bound > 1) {
         $bound--;
      }
   }

   print "$_\n";
}
