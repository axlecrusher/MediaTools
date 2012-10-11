#!/usr/bin/perl

use IPC::Run qw( run timeout );

#my $neroEncOpts = "-q 0.6 -cbr 131072";

#we need to be very careful of how we handle text input.
#avoid any method that would require escaping special characters.

#quality range from 0 to 1
#1.0 lossless
#0.5 good

#use flac2aac.pl quality source destination

my $quality = $ARGV[0];
my $src = $ARGV[1];
my $dest = $ARGV[2];

my $neroEncOpts = "-q $quality";

#print "$src ===>> $dest\n";
#sleep 3;
#exit;

my $hTag = {};

open (METADATA, '-|', 'metaflac', '--export-tags-to=-', $src);
while (my $l = <METADATA>)
{
	chomp($l);
	my $i = index($l, '=');
	if ($i > -1)
	{
		my $k = substr($l,0,$i);
		$hTags->{$k} = substr($l,$i+1);
	}
}
close (METADATA);

my $cdNum = $hTags->{DISCNUMBER};
$hTags->{DATE} =~ /.*(\d{4}).*/;
my $year = $1;

my @tags = ();
push(@tags, "-meta:title=" . $hTags->{TITLE}) if ($hTags->{TITLE} ne '');
push(@tags, "-meta:track=" . $hTags->{TRACKNUMBER}) if ($hTags->{TRACKNUMBER} ne '');
push(@tags, "-meta:genre=" . $hTags->{GENRE}) if ($hTags->{GENRE} ne '');
push(@tags, "-meta:artist=" . $hTags->{ARTIST}) if ($hTags->{ARTIST} ne '');
push(@tags, "-meta:album=" . $hTags->{ALBUM}) if ($hTags->{ALBUM} ne '');
push(@tags, "-meta:album=" . $hTags->{ALBUM} . "(CD $cdNum)") if ($cdNum ne '');
push(@tags, "-meta:year=" . $year) if ($year ne '');

#print "@tags\n";
#exit(0);

#system("ffmpeg -i '$src' -ac 2 -ar 44100 -y -f wav - 2> /dev/null | neroAacEnc -ignorelength $neroEncOpts -if - -of '$dest'");

my @ffmpeg = qw(ffmpeg -i src -ac 2 -ar 44100 -y -f wav -);
$ffmpeg[2] = $src;

my @nero = split(/\s+/, "neroAacEnc -ignorelength $neroEncOpts -if - -of");
push(@nero, $dest);
print "@nero\n";
run \@ffmpeg , '2>', '/dev/null', '|', \@nero;
system('neroAacTag', $dest, @tags);

#Copyright (c) 2012 Joshua Allen
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
#of the Software, and to permit persons to whom the Software is furnished to do
#so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
