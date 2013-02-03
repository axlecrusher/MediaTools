#!/usr/bin/perl

my $drive = $ARGV[0];
$drive = "/dev/cdrom" if ($drive eq '');

my $ripTrack = $ARGV[1];
my $paranoidArgs = $ARGV[2];

my $cddb = `cddbget -f -I -c $drive`;

$cddb =~ /artist: (.*)/;
my $artist = $1;

$cddb =~ /title: (.*)/;
my $album = $1;

$cddb =~ /genre: (.*)/;
my $genre = $1;

$cddb =~ /year: (\d+)/;
my $year = $1;

$cddb =~ /trackno: (\d+)/;
my $trackno = $1;

my $meta = "-T ALBUM=\"$album\" -T ARTIST=\"$artist\" -T GENRE=\"$genre\" -T DATE=\"$year\"";

my $path = "cdrip/$artist/$album";
system("mkdir -p \"$path\"");

if ($ripTrack eq '')
{
	for (my $i = 1; $i<=$trackno; ++$i)
	{
		RipTrack($i);
	}
}
else
{
	RipTrack($ripTrack);
}

system("eject $drive");

sub RipTrack
{
	my ($track) = @_;
	$cddb =~ /track $track: (.*)/;
	my $trackTitle = $1;
#	print "$trackTitle\n";
	my $file = sprintf("%.2d",$track) . " - $trackTitle.flac";
	$file =~ s/\//-/g;
	$file = "$path/$file";
#	print "$file\n";
	my $mm = "$meta -T TITLE=\"$trackTitle\" -T TRACKNUMBER=\"$track\"";

	system("cdparanoia -d $drive $paranoidArgs $track - | flac -8 $mm -  > \"$file\" 2> /dev/null");
#	system("~/neroAacTag \"$file\" $mm 2> /dev/null");
}

#Copyright (c) 2013 Joshua Allen
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
