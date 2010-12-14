#!/usr/bin/env perl
use strict;

my $host='https://github.com';
my @projects = @ARGV ? @ARGV : qw/eotect zrepos zscripts zcodebase vcsplace/;#zmyplace/

my %repos;

foreach my $project (@projects) {
	my $listurl = "$host/$project/repositories";
	print STDERR "downloading $listurl...\n";
	open FI,"-|","curl","--progress-bar","-L",$listurl;
	while(<FI>) {
		if(m/href\s*=\s*"\/$project\/([^\/]+)"/) {
			push @{$repos{$project}},$1;
		}
	}
	close FI;
}
if(%repos) {
	open FO,">","repos.lst";
	foreach my $project (keys %repos) {
		if($repos{$project} and @{$repos{$project}}) {
			foreach(@{$repos{$project}}) {
				print STDERR "http://github.com/$project/$_.git\n";
				print FO "http://github.com/$project/$_.git\n";
			}
		}
	}
	close FO;
	print STDERR "OK repos urls saved in repos.lst\n";
}
